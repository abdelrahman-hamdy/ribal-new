import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../core/constants/firebase_constants.dart';
import '../../core/services/hive_cache_service.dart';
import '../models/assignment_model.dart';
import '../models/paginated_result.dart';
import '../services/firestore_service.dart';

/// Assignment repository for CRUD operations with Hive caching
@lazySingleton
class AssignmentRepository {
  final FirestoreService _firestoreService;
  final HiveCacheService _cacheService;

  AssignmentRepository(this._firestoreService, this._cacheService);

  /// Invalidate cache timestamps (V2 approach - invalidates Firebase cache freshness)
  Future<void> _invalidateAssignmentCaches({
    String? userId,
    String? taskId,
    DateTime? date,
    bool invalidateBatchCache = false,
    String? specificAssignmentId,
  }) async {
    final keysToDelete = <String>[];

    // User-specific date cache timestamp
    if (userId != null && date != null) {
      final dateKey = '${date.year}-${date.month}-${date.day}';
      keysToDelete.add('assignments_${userId}_${dateKey}_timestamp');
    }

    // Task-specific date cache timestamp
    if (taskId != null && date != null) {
      final dateKey = '${date.year}-${date.month}-${date.day}';
      keysToDelete.add('assignments_task_${taskId}_${dateKey}_timestamp');
    }

    // Paginated cache timestamp (first page only)
    if (userId != null) {
      keysToDelete.add('assignments_paginated_${userId}_page_1_timestamp');
    }

    // Batch fetch cache timestamp for tasks on date
    if (invalidateBatchCache && date != null) {
      final dateKey = '${date.year}-${date.month}-${date.day}';
      keysToDelete.add('assignments_tasks_batch_${dateKey}_timestamp');
    }

    // Individual assignment cache timestamp AND data
    if (specificAssignmentId != null) {
      keysToDelete.add('${specificAssignmentId}_timestamp');
      keysToDelete.add(specificAssignmentId); // Also delete the actual cached assignment data
    }

    // Delete the affected cache keys (timestamps and specific assignment data)
    for (final key in keysToDelete) {
      await _cacheService.delete(
        boxName: HiveCacheService.boxAssignments,
        key: key,
      );
    }
  }

  /// Create assignment
  Future<AssignmentModel> createAssignment(AssignmentModel assignment) async {
    final docRef = await _firestoreService.createDocument(
      _firestoreService.assignmentsCollection,
      assignment.toFirestore(),
    );

    return assignment.copyWith(id: docRef.id);
  }

  /// Create multiple assignments (batch)
  Future<List<AssignmentModel>> createAssignments(
    List<AssignmentModel> assignments,
  ) async {
    final batch = _firestoreService.batch;
    final createdAssignments = <AssignmentModel>[];

    for (final assignment in assignments) {
      final docRef = _firestoreService.assignmentsCollection.doc();
      batch.set(docRef, assignment.toFirestore());
      createdAssignments.add(assignment.copyWith(id: docRef.id));
    }

    await batch.commit();
    return createdAssignments;
  }

  /// Get assignment by ID with cache-first strategy
  Future<AssignmentModel?> getAssignmentById(String assignmentId) async {
    // Try cache first
    final cachedJson = await _cacheService.get<Map<String, dynamic>>(
      boxName: HiveCacheService.boxAssignments,
      key: assignmentId,
      ttl: HiveCacheService.ttlShort,
    );

    if (cachedJson != null) {
      return AssignmentModel.fromJson(cachedJson);
    }

    // Fetch from Firebase if cache miss
    final doc = await _firestoreService.assignmentDoc(assignmentId).get();
    if (!doc.exists) return null;

    final assignment = AssignmentModel.fromFirestore(doc);

    // Cache the result
    await _cacheService.put(
      boxName: HiveCacheService.boxAssignments,
      key: assignmentId,
      value: assignment.toJson(),
    );

    return assignment;
  }

  /// Stream assignment by ID
  Stream<AssignmentModel?> streamAssignment(String assignmentId) {
    return _firestoreService
        .streamDocument(_firestoreService.assignmentDoc(assignmentId))
        .map((doc) => doc.exists ? AssignmentModel.fromFirestore(doc) : null);
  }

  /// Get assignments for user on specific date with SMART CACHING (V2)
  Future<List<AssignmentModel>> getAssignmentsForUserOnDate({
    required String userId,
    required DateTime date,
  }) async {
    final overallStart = DateTime.now();
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    final dateKey = '${date.year}-${date.month}-${date.day}';
    final cacheKey = 'assignments_${userId}_${dateKey}_timestamp';

    debugPrint('[AssignmentRepository] 📋 getAssignmentsForUserOnDate() started - userId: $userId, date: $dateKey');

    // Check if Firebase cache is fresh
    final cacheCheckStart = DateTime.now();
    final isFresh = await _cacheService.isCacheFresh(
      boxName: HiveCacheService.boxAssignments,
      key: cacheKey,
      ttl: HiveCacheService.ttlShort,
    );
    final cacheCheckDuration = DateTime.now().difference(cacheCheckStart);
    debugPrint('[AssignmentRepository] Cache check took: ${cacheCheckDuration.inMilliseconds}ms');

    if (isFresh) {
      // Use Firebase CACHE (instant)
      debugPrint('[AssignmentRepository] ✅ Cache FRESH - reading from Firebase cache');
      final cacheReadStart = DateTime.now();

      try {
        final snapshot = await _firestoreService.assignmentsCollection
            .where(FirebaseConstants.assignmentUserId, isEqualTo: userId)
            .where(
              FirebaseConstants.assignmentScheduledDate,
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
            )
            .where(
              FirebaseConstants.assignmentScheduledDate,
              isLessThan: Timestamp.fromDate(endOfDay),
            )
            .orderBy(FirebaseConstants.assignmentScheduledDate)
            .get(const GetOptions(source: Source.cache));

        final assignments = snapshot.docs
            .map((doc) => AssignmentModel.fromFirestore(doc))
            .toList();

        final cacheReadDuration = DateTime.now().difference(cacheReadStart);
        final totalDuration = DateTime.now().difference(overallStart);

        debugPrint('[AssignmentRepository] ✅ Loaded ${assignments.length} assignments from Firebase CACHE');
        debugPrint('[AssignmentRepository] Cache read: ${cacheReadDuration.inMilliseconds}ms');
        debugPrint('[AssignmentRepository] Total time: ${totalDuration.inMilliseconds}ms');

        return assignments;
      } catch (e) {
        debugPrint('[AssignmentRepository] ⚠️ Firebase cache read failed: $e');
      }
    }

    // Fetch from server
    debugPrint('[AssignmentRepository] ⏰ Cache STALE - fetching from Firebase server');
    final serverFetchStart = DateTime.now();

    final snapshot = await _firestoreService.assignmentsCollection
        .where(FirebaseConstants.assignmentUserId, isEqualTo: userId)
        .where(
          FirebaseConstants.assignmentScheduledDate,
          isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
        )
        .where(
          FirebaseConstants.assignmentScheduledDate,
          isLessThan: Timestamp.fromDate(endOfDay),
        )
        .orderBy(FirebaseConstants.assignmentScheduledDate)
        .get(const GetOptions(source: Source.server));

    final assignments = snapshot.docs
        .map((doc) => AssignmentModel.fromFirestore(doc))
        .toList();

    // Mark cache as fresh
    await _cacheService.put(
      boxName: HiveCacheService.boxAssignments,
      key: cacheKey,
      value: {'cached': true},
    );

    final serverFetchDuration = DateTime.now().difference(serverFetchStart);
    final totalDuration = DateTime.now().difference(overallStart);

    debugPrint('[AssignmentRepository] ✅ Loaded ${assignments.length} assignments from Firebase SERVER');
    debugPrint('[AssignmentRepository] Server fetch: ${serverFetchDuration.inMilliseconds}ms');
    debugPrint('[AssignmentRepository] Total time: ${totalDuration.inMilliseconds}ms');

    return assignments;
  }

  /// Get assignments for user (paginated, all dates) with cache-first strategy
  Future<PaginatedResult<AssignmentModel>> getAssignmentsForUserPaginated({
    required String userId,
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) async {
    // Only cache first page for instant initial load
    if (startAfter == null) {
      final cacheKey = 'assignments_paginated_${userId}_page_1';

      // Try cache first for initial page
      final cachedJson = await _cacheService.get<List>(
        boxName: HiveCacheService.boxAssignments,
        key: cacheKey,
        ttl: HiveCacheService.ttlShort, // 5 min TTL
      );

      if (cachedJson != null && cachedJson.isNotEmpty) {
        // Return cached first page immediately (convert from Map<dynamic, dynamic> to Map<String, dynamic>)
        final assignments = cachedJson
            .map((json) => AssignmentModel.fromJson(Map<String, dynamic>.from(json as Map)))
            .toList();

        return PaginatedResult(
          items: assignments,
          lastDocument: null, // Can't restore DocumentSnapshot from cache
          hasMore: assignments.length == limit,
        );
      }
    }

    // Fetch from Firebase
    var query = _firestoreService.assignmentsCollection
        .where(FirebaseConstants.assignmentUserId, isEqualTo: userId)
        .orderBy(FirebaseConstants.assignmentScheduledDate, descending: true)
        .limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snapshot = await query.get();
    final assignments = snapshot.docs
        .map((doc) => AssignmentModel.fromFirestore(doc))
        .toList();

    // Cache first page only
    if (startAfter == null && assignments.isNotEmpty) {
      await _cacheService.put(
        boxName: HiveCacheService.boxAssignments,
        key: 'assignments_paginated_${userId}_page_1',
        value: assignments.map((a) => a.toJson()).toList(),
      );
    }

    return PaginatedResult(
      items: assignments,
      lastDocument: snapshot.docs.isNotEmpty ? snapshot.docs.last : null,
      hasMore: snapshot.docs.length == limit,
    );
  }

  /// Stream assignments for user on specific date
  Stream<List<AssignmentModel>> streamAssignmentsForUserOnDate({
    required String userId,
    required DateTime date,
  }) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _firestoreService.assignmentsCollection
        .where(FirebaseConstants.assignmentUserId, isEqualTo: userId)
        .where(
          FirebaseConstants.assignmentScheduledDate,
          isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
        )
        .where(
          FirebaseConstants.assignmentScheduledDate,
          isLessThan: Timestamp.fromDate(endOfDay),
        )
        .orderBy(FirebaseConstants.assignmentScheduledDate)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AssignmentModel.fromFirestore(doc))
            .toList());
  }

  /// Get assignments for task
  Future<List<AssignmentModel>> getAssignmentsForTask(String taskId) async {
    final snapshot = await _firestoreService.assignmentsCollection
        .where(FirebaseConstants.assignmentTaskId, isEqualTo: taskId)
        .get();

    // Sort in memory to avoid index requirement
    final assignments = snapshot.docs
        .map((doc) => AssignmentModel.fromFirestore(doc))
        .toList();
    assignments.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return assignments;
  }

  /// Stream assignments for task
  Stream<List<AssignmentModel>> streamAssignmentsForTask(String taskId) {
    return _firestoreService.assignmentsCollection
        .where(FirebaseConstants.assignmentTaskId, isEqualTo: taskId)
        .snapshots()
        .map((snapshot) {
          // Sort in memory to avoid index requirement
          final assignments = snapshot.docs
              .map((doc) => AssignmentModel.fromFirestore(doc))
              .toList();
          assignments.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return assignments;
        });
  }

  /// Get assignments for task on specific date with SMART CACHING (V2)
  Future<List<AssignmentModel>> getAssignmentsForTaskOnDate({
    required String taskId,
    required DateTime date,
  }) async {
    final overallStart = DateTime.now();
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    final dateKey = '${date.year}-${date.month}-${date.day}';
    final cacheKey = 'assignments_task_${taskId}_${dateKey}_timestamp';

    debugPrint('[AssignmentRepository] 📋 getAssignmentsForTaskOnDate() V2 started - taskId: $taskId, date: $dateKey');

    // Check if Firebase cache is fresh
    final cacheCheckStart = DateTime.now();
    final isFresh = await _cacheService.isCacheFresh(
      boxName: HiveCacheService.boxAssignments,
      key: cacheKey,
      ttl: HiveCacheService.ttlShort, // Assignments change frequently
    );
    final cacheCheckDuration = DateTime.now().difference(cacheCheckStart);
    debugPrint('[AssignmentRepository] Cache check took: ${cacheCheckDuration.inMilliseconds}ms');

    if (isFresh) {
      // Use Firebase CACHE (instant)
      debugPrint('[AssignmentRepository] ✅ Cache FRESH - reading from Firebase cache');
      final cacheReadStart = DateTime.now();

      try {
        final snapshot = await _firestoreService.assignmentsCollection
            .where(FirebaseConstants.assignmentTaskId, isEqualTo: taskId)
            .where(
              FirebaseConstants.assignmentScheduledDate,
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
            )
            .where(
              FirebaseConstants.assignmentScheduledDate,
              isLessThan: Timestamp.fromDate(endOfDay),
            )
            .get(const GetOptions(source: Source.cache)); // 🔥 CACHE-ONLY

        final assignments = snapshot.docs
            .map((doc) => AssignmentModel.fromFirestore(doc))
            .toList();

        final cacheReadDuration = DateTime.now().difference(cacheReadStart);
        final totalDuration = DateTime.now().difference(overallStart);

        debugPrint('[AssignmentRepository] ✅ Loaded ${assignments.length} assignments from Firebase CACHE');
        debugPrint('[AssignmentRepository] Cache read: ${cacheReadDuration.inMilliseconds}ms');
        debugPrint('[AssignmentRepository] Total time: ${totalDuration.inMilliseconds}ms');

        return assignments;
      } catch (e) {
        debugPrint('[AssignmentRepository] ⚠️ Firebase cache read failed: $e');
      }
    }

    // Cache is stale or missing - fetch from SERVER
    debugPrint('[AssignmentRepository] ⏰ Cache STALE - fetching from Firebase server');
    final serverFetchStart = DateTime.now();

    final snapshot = await _firestoreService.assignmentsCollection
        .where(FirebaseConstants.assignmentTaskId, isEqualTo: taskId)
        .where(
          FirebaseConstants.assignmentScheduledDate,
          isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
        )
        .where(
          FirebaseConstants.assignmentScheduledDate,
          isLessThan: Timestamp.fromDate(endOfDay),
        )
        .get(const GetOptions(source: Source.server)); // 🌐 SERVER FETCH

    final assignments = snapshot.docs
        .map((doc) => AssignmentModel.fromFirestore(doc))
        .toList();

    // Mark cache as fresh (Firebase already cached it)
    await _cacheService.put(
      boxName: HiveCacheService.boxAssignments,
      key: cacheKey,
      value: {'cached': true}, // Just metadata
    );

    final serverFetchDuration = DateTime.now().difference(serverFetchStart);
    final totalDuration = DateTime.now().difference(overallStart);

    debugPrint('[AssignmentRepository] ✅ Loaded ${assignments.length} assignments from Firebase SERVER');
    debugPrint('[AssignmentRepository] Server fetch: ${serverFetchDuration.inMilliseconds}ms');
    debugPrint('[AssignmentRepository] Total time: ${totalDuration.inMilliseconds}ms');

    return assignments;
  }

  /// Get all assignments for multiple tasks on specific date with SMART CACHING (V2)
  /// Returns a map of taskId -> list of assignments
  Future<Map<String, List<AssignmentModel>>> getAssignmentsForTasksOnDate({
    required List<String> taskIds,
    required DateTime date,
  }) async {
    if (taskIds.isEmpty) return {};

    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    final dateKey = '${date.year}-${date.month}-${date.day}';
    final cacheKey = 'assignments_tasks_batch_${dateKey}_timestamp';

    // Check if Firebase cache is fresh
    final isFresh = await _cacheService.isCacheFresh(
      boxName: HiveCacheService.boxAssignments,
      key: cacheKey,
      ttl: HiveCacheService.ttlShort,
    );

    final result = <String, List<AssignmentModel>>{};

    if (isFresh) {
      // Use Firebase CACHE (instant)
      try {
        for (var i = 0; i < taskIds.length; i += 10) {
          final batch = taskIds.skip(i).take(10).toList();

          final snapshot = await _firestoreService.assignmentsCollection
              .where(FirebaseConstants.assignmentTaskId, whereIn: batch)
              .where(
                FirebaseConstants.assignmentScheduledDate,
                isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
              )
              .where(
                FirebaseConstants.assignmentScheduledDate,
                isLessThan: Timestamp.fromDate(endOfDay),
              )
              .get(const GetOptions(source: Source.cache));

          for (final doc in snapshot.docs) {
            final assignment = AssignmentModel.fromFirestore(doc);
            result.putIfAbsent(assignment.taskId, () => []).add(assignment);
          }
        }

        // Ensure all task IDs have at least an empty list
        for (final taskId in taskIds) {
          result.putIfAbsent(taskId, () => []);
        }

        return result;
      } catch (e) {
        debugPrint('[AssignmentRepository] Firebase cache batch read failed: $e');
      }
    }

    // Fetch from server
    for (var i = 0; i < taskIds.length; i += 10) {
      final batch = taskIds.skip(i).take(10).toList();

      final snapshot = await _firestoreService.assignmentsCollection
          .where(FirebaseConstants.assignmentTaskId, whereIn: batch)
          .where(
            FirebaseConstants.assignmentScheduledDate,
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
          )
          .where(
            FirebaseConstants.assignmentScheduledDate,
            isLessThan: Timestamp.fromDate(endOfDay),
          )
          .get(const GetOptions(source: Source.server));

      for (final doc in snapshot.docs) {
        final assignment = AssignmentModel.fromFirestore(doc);
        result.putIfAbsent(assignment.taskId, () => []).add(assignment);
      }
    }

    // Ensure all task IDs have at least an empty list
    for (final taskId in taskIds) {
      result.putIfAbsent(taskId, () => []);
    }

    // Mark cache as fresh
    await _cacheService.put(
      boxName: HiveCacheService.boxAssignments,
      key: cacheKey,
      value: {'cached': true},
    );

    return result;
  }

  /// Mark assignment as completed
  Future<void> markAsCompleted({
    required String assignmentId,
    required String markedDoneBy,
    String? attachmentUrl,
  }) async {
    // Get assignment first to know which caches to invalidate
    final assignment = await getAssignmentById(assignmentId);

    final updateData = <String, dynamic>{
      FirebaseConstants.assignmentStatus: AssignmentStatus.completed.name,
      FirebaseConstants.assignmentCompletedAt: FieldValue.serverTimestamp(),
      FirebaseConstants.assignmentMarkedDoneBy: markedDoneBy,
    };

    // Add attachment URL if provided
    if (attachmentUrl != null) {
      updateData[FirebaseConstants.assignmentAttachmentUrl] = attachmentUrl;
    }

    await _firestoreService.updateDocument(
      _firestoreService.assignmentDoc(assignmentId),
      updateData,
    );

    // Targeted cache invalidation
    if (assignment != null) {
      await _invalidateAssignmentCaches(
        userId: assignment.userId,
        taskId: assignment.taskId,
        date: assignment.scheduledDate,
        invalidateBatchCache: true,
        specificAssignmentId: assignmentId,
      );
    }
  }

  /// Mark assignment as apologized
  Future<void> markAsApologized({
    required String assignmentId,
    String? message,
  }) async {
    // Get assignment first to know which caches to invalidate
    final assignment = await getAssignmentById(assignmentId);

    await _firestoreService.updateDocument(
      _firestoreService.assignmentDoc(assignmentId),
      {
        FirebaseConstants.assignmentStatus: AssignmentStatus.apologized.name,
        FirebaseConstants.assignmentApologizedAt: FieldValue.serverTimestamp(),
        FirebaseConstants.assignmentApologizeMessage: message,
      },
    );

    // Targeted cache invalidation
    if (assignment != null) {
      await _invalidateAssignmentCaches(
        userId: assignment.userId,
        taskId: assignment.taskId,
        date: assignment.scheduledDate,
        invalidateBatchCache: true,
        specificAssignmentId: assignmentId,
      );
    }
  }

  /// Reactivate assignment (back to pending)
  Future<void> reactivateAssignment(String assignmentId) async {
    // Get assignment first to know which caches to invalidate
    final assignment = await getAssignmentById(assignmentId);

    await _firestoreService.updateDocument(
      _firestoreService.assignmentDoc(assignmentId),
      {
        FirebaseConstants.assignmentStatus: AssignmentStatus.pending.name,
        FirebaseConstants.assignmentApologizedAt: null,
        FirebaseConstants.assignmentApologizeMessage: null,
      },
    );

    // Targeted cache invalidation
    if (assignment != null) {
      await _invalidateAssignmentCaches(
        userId: assignment.userId,
        taskId: assignment.taskId,
        date: assignment.scheduledDate,
        invalidateBatchCache: true,
        specificAssignmentId: assignmentId,
      );
    }
  }

  /// Delete assignment
  Future<void> deleteAssignment(String assignmentId) async {
    await _firestoreService.deleteDocument(
      _firestoreService.assignmentDoc(assignmentId),
    );
  }

  /// Delete all assignments for task
  Future<void> deleteAssignmentsForTask(String taskId) async {
    final snapshot = await _firestoreService.assignmentsCollection
        .where(FirebaseConstants.assignmentTaskId, isEqualTo: taskId)
        .get();

    final batch = _firestoreService.batch;
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  /// Get assignments count by status for user on date
  Future<Map<AssignmentStatus, int>> getAssignmentCountsByStatus({
    required String userId,
    required DateTime date,
  }) async {
    final assignments = await getAssignmentsForUserOnDate(
      userId: userId,
      date: date,
    );

    final counts = <AssignmentStatus, int>{
      AssignmentStatus.pending: 0,
      AssignmentStatus.completed: 0,
      AssignmentStatus.apologized: 0,
      AssignmentStatus.overdue: 0,
    };

    for (final assignment in assignments) {
      counts[assignment.status] = (counts[assignment.status] ?? 0) + 1;
    }

    return counts;
  }
}
