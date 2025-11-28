import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../core/constants/firebase_constants.dart';
import '../../core/services/hive_cache_service.dart';
import '../models/note_model.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';

/// Repository for managing task notes
@injectable
class NoteRepository {
  final FirestoreService _firestoreService;
  final HiveCacheService _cacheService;

  NoteRepository(this._firestoreService, this._cacheService);

  /// Get the notes subcollection reference for an assignment
  CollectionReference<Map<String, dynamic>> _notesCollection(String assignmentId) {
    return _firestoreService.assignmentsCollection
        .doc(assignmentId)
        .collection(FirebaseConstants.notesSubcollection);
  }

  /// Create a new note for an assignment
  Future<NoteModel> createNote({
    required String assignmentId,
    required String taskId,
    required String senderId,
    required String senderName,
    required UserRole senderRole,
    required String message,
    bool isApologizeNote = false,
  }) async {
    final noteData = {
      FirebaseConstants.noteAssignmentId: assignmentId,
      FirebaseConstants.noteTaskId: taskId,
      FirebaseConstants.noteSenderId: senderId,
      FirebaseConstants.noteSenderName: senderName,
      FirebaseConstants.noteSenderRole: senderRole.name,
      FirebaseConstants.noteMessage: message,
      FirebaseConstants.noteIsApologizeNote: isApologizeNote,
      FirebaseConstants.noteCreatedAt: FieldValue.serverTimestamp(),
    };

    final docRef = await _notesCollection(assignmentId).add(noteData);
    final snapshot = await docRef.get();

    // Invalidate note count cache for this assignment
    await _invalidateNoteCountCache(assignmentId);

    return NoteModel.fromFirestore(snapshot);
  }

  /// Invalidate note count cache for an assignment
  Future<void> _invalidateNoteCountCache(String assignmentId) async {
    debugPrint('[NoteRepository] 🗑️ Invalidating note count cache for assignment: $assignmentId');
    await _cacheService.delete(
      boxName: HiveCacheService.boxAssignments,
      key: 'note_count_$assignmentId',
    );
    await _cacheService.delete(
      boxName: HiveCacheService.boxAssignments,
      key: 'note_count_${assignmentId}_timestamp',
    );
  }

  /// Stream notes for an assignment (real-time updates)
  Stream<List<NoteModel>> streamNotesForAssignment(String assignmentId) {
    return _notesCollection(assignmentId)
        .orderBy(FirebaseConstants.noteCreatedAt, descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NoteModel.fromFirestore(doc))
            .toList());
  }

  /// Get notes for an assignment (one-time fetch)
  /// Get notes for assignment (limited to 100 for performance)
  Future<List<NoteModel>> getNotesForAssignment(String assignmentId) async {
    final snapshot = await _notesCollection(assignmentId)
        .orderBy(FirebaseConstants.noteCreatedAt, descending: false)
        .limit(100) // Safety limit for free tier
        .get();

    return snapshot.docs.map((doc) => NoteModel.fromFirestore(doc)).toList();
  }

  /// Get the count of notes for an assignment
  Future<int> getNotesCountForAssignment(String assignmentId) async {
    final snapshot = await _notesCollection(assignmentId).count().get();
    return snapshot.count ?? 0;
  }

  /// Check if an assignment has any notes
  Future<bool> hasNotesForAssignment(String assignmentId) async {
    final snapshot = await _notesCollection(assignmentId).limit(1).get();
    return snapshot.docs.isNotEmpty;
  }

  /// Get notes count for multiple assignments (for task detail page)
  /// Returns a map of assignmentId -> note count
  /// V2 Caching: Hive stores actual counts (Firestore aggregate queries don't use offline cache)
  Future<Map<String, int>> getNotesCountsForAssignments(List<String> assignmentIds) async {
    if (assignmentIds.isEmpty) return {};

    final overallStart = DateTime.now();
    debugPrint('[NoteRepository] 📓 getNotesCountsForAssignments() V2 started - ${assignmentIds.length} assignments');

    final results = <String, int>{};
    final cachedIds = <String>[];
    final staleIds = <String>[];

    // Check which assignments have fresh cached counts
    for (final assignmentId in assignmentIds) {
      final cacheKey = 'note_count_${assignmentId}_timestamp';
      final isFresh = await _cacheService.isCacheFresh(
        boxName: HiveCacheService.boxAssignments,
        key: cacheKey,
        ttl: HiveCacheService.ttlShort, // Notes can be added frequently
      );

      if (isFresh) {
        cachedIds.add(assignmentId);
      } else {
        staleIds.add(assignmentId);
      }
    }

    debugPrint('[NoteRepository] Cache status: ${cachedIds.length} fresh, ${staleIds.length} stale');

    // Read cached counts from Hive (instant!)
    if (cachedIds.isNotEmpty) {
      final cacheReadStart = DateTime.now();
      debugPrint('[NoteRepository] 📖 Reading ${cachedIds.length} note counts from Hive CACHE');

      for (final assignmentId in cachedIds) {
        final cached = await _cacheService.get<Map<String, dynamic>>(
          boxName: HiveCacheService.boxAssignments,
          key: 'note_count_$assignmentId',
        );
        if (cached != null && cached['count'] != null) {
          results[assignmentId] = cached['count'] as int;
        } else {
          // Cache miss - add to stale list
          staleIds.add(assignmentId);
        }
      }

      final duration = DateTime.now().difference(cacheReadStart);
      debugPrint('[NoteRepository] ✅ Loaded ${results.length} note counts from CACHE in ${duration.inMilliseconds}ms');
    }

    // Fetch stale counts from server
    if (staleIds.isNotEmpty) {
      final serverFetchStart = DateTime.now();
      debugPrint('[NoteRepository] 🌐 Fetching ${staleIds.length} note counts from Firestore SERVER');

      // Run all count queries in parallel for better performance
      final countFutures = staleIds.map((id) =>
        getNotesCountForAssignment(id).then((noteCount) => MapEntry(id, noteCount))
      );

      final entries = await Future.wait(countFutures);

      for (final entry in entries) {
        results[entry.key] = entry.value;

        // Cache the count value and timestamp
        await _cacheService.put(
          boxName: HiveCacheService.boxAssignments,
          key: 'note_count_${entry.key}',
          value: {'count': entry.value},
        );
        await _cacheService.put(
          boxName: HiveCacheService.boxAssignments,
          key: 'note_count_${entry.key}_timestamp',
          value: {'cached': true},
        );
      }

      final duration = DateTime.now().difference(serverFetchStart);
      debugPrint('[NoteRepository] ✅ Fetched ${staleIds.length} note counts from SERVER in ${duration.inMilliseconds}ms');
    }

    final totalDuration = DateTime.now().difference(overallStart);
    debugPrint('[NoteRepository] 🎯 Total: Loaded ${results.length} note counts in ${totalDuration.inMilliseconds}ms (${cachedIds.length} cached, ${staleIds.length} fetched)');

    return results;
  }

  /// Get the latest note for an assignment (for preview)
  Future<NoteModel?> getLatestNoteForAssignment(String assignmentId) async {
    final snapshot = await _notesCollection(assignmentId)
        .orderBy(FirebaseConstants.noteCreatedAt, descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return NoteModel.fromFirestore(snapshot.docs.first);
  }

  /// Delete a note (admin only)
  Future<void> deleteNote(String assignmentId, String noteId) async {
    await _notesCollection(assignmentId).doc(noteId).delete();

    // Invalidate note count cache for this assignment
    await _invalidateNoteCountCache(assignmentId);
  }
}
