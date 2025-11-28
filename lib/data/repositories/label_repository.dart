import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../core/constants/firebase_constants.dart';
import '../../core/services/hive_cache_service.dart';
import '../models/label_model.dart';
import '../services/firestore_service.dart';

/// Label repository for CRUD operations with V2 caching
/// Strategy: Firebase cache + Hive TTL metadata
@lazySingleton
class LabelRepository {
  final FirestoreService _firestoreService;
  final HiveCacheService _cacheService;

  LabelRepository(this._firestoreService, this._cacheService);

  /// Create label
  Future<LabelModel> createLabel(LabelModel label) async {
    final docRef = await _firestoreService.createDocument(
      _firestoreService.labelsCollection,
      label.toFirestore(),
    );

    await _invalidateLabelCaches();
    return label.copyWith(id: docRef.id);
  }

  /// Get label by ID
  Future<LabelModel?> getLabelById(String labelId) async {
    final doc = await _firestoreService.labelDoc(labelId).get();
    if (!doc.exists) return null;
    return LabelModel.fromFirestore(doc);
  }

  /// Stream label by ID
  Stream<LabelModel?> streamLabel(String labelId) {
    return _firestoreService
        .streamDocument(_firestoreService.labelDoc(labelId))
        .map((doc) => doc.exists ? LabelModel.fromFirestore(doc) : null);
  }

  /// Get all labels (V2: Firebase cache + Hive TTL)
  Future<List<LabelModel>> getAllLabels() async {
    final overallStart = DateTime.now();
    debugPrint('[LabelRepository] 🏷️  getAllLabels() V2 started');

    const cacheKey = 'all_labels_timestamp';

    // Check if Firebase cache is fresh
    final isFresh = await _cacheService.isCacheFresh(
      boxName: HiveCacheService.boxLabels,
      key: cacheKey,
      ttl: HiveCacheService.ttlLong, // Labels rarely change
    );

    if (isFresh) {
      // Use Firebase CACHE (instant, no network!)
      debugPrint('[LabelRepository] ✅ Cache FRESH - reading from Firebase cache');
      final cacheReadStart = DateTime.now();

      try {
        final snapshot = await _firestoreService.labelsCollection
            .orderBy(FirebaseConstants.labelName)
            .limit(50) // Safety limit for free tier
            .get(const GetOptions(source: Source.cache)); // 🔥 CACHE-ONLY

        final labels = snapshot.docs
            .map((doc) => LabelModel.fromFirestore(doc))
            .toList();

        final duration = DateTime.now().difference(cacheReadStart);
        final totalDuration = DateTime.now().difference(overallStart);

        debugPrint('[LabelRepository] ✅ Loaded ${labels.length} labels from Firebase CACHE');
        debugPrint('[LabelRepository] Cache read: ${duration.inMilliseconds}ms');
        debugPrint('[LabelRepository] Total time: ${totalDuration.inMilliseconds}ms');

        return labels;
      } catch (e) {
        debugPrint('[LabelRepository] ⚠️ Firebase cache read failed: $e');
      }
    }

    // Cache is stale or missing - fetch from SERVER
    debugPrint('[LabelRepository] ⏰ Cache STALE - fetching from Firebase server');
    final serverFetchStart = DateTime.now();

    final snapshot = await _firestoreService.labelsCollection
        .orderBy(FirebaseConstants.labelName)
        .limit(50) // Safety limit for free tier
        .get(const GetOptions(source: Source.server)); // 🌐 SERVER FETCH

    final labels = snapshot.docs
        .map((doc) => LabelModel.fromFirestore(doc))
        .toList();

    // Mark cache as fresh (Firebase already cached it)
    await _cacheService.put(
      boxName: HiveCacheService.boxLabels,
      key: cacheKey,
      value: {'cached': true}, // Just metadata
    );

    final serverDuration = DateTime.now().difference(serverFetchStart);
    final totalDuration = DateTime.now().difference(overallStart);

    debugPrint('[LabelRepository] ✅ Loaded ${labels.length} labels from Firebase SERVER');
    debugPrint('[LabelRepository] Server fetch: ${serverDuration.inMilliseconds}ms');
    debugPrint('[LabelRepository] Total time: ${totalDuration.inMilliseconds}ms');

    return labels;
  }

  /// Stream all labels
  Stream<List<LabelModel>> streamAllLabels() {
    return _firestoreService.labelsCollection
        .orderBy(FirebaseConstants.labelName)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => LabelModel.fromFirestore(doc)).toList());
  }

  /// Get active labels only (V2: Firebase cache + Hive TTL)
  Future<List<LabelModel>> getActiveLabels() async {
    final overallStart = DateTime.now();
    debugPrint('[LabelRepository] 🏷️  getActiveLabels() V2 started');

    const cacheKey = 'active_labels_timestamp';

    // Check if Firebase cache is fresh
    final isFresh = await _cacheService.isCacheFresh(
      boxName: HiveCacheService.boxLabels,
      key: cacheKey,
      ttl: HiveCacheService.ttlLong,
    );

    if (isFresh) {
      debugPrint('[LabelRepository] ✅ Cache FRESH - reading from Firebase cache');
      final cacheReadStart = DateTime.now();

      try {
        final snapshot = await _firestoreService.labelsCollection
            .where(FirebaseConstants.labelIsActive, isEqualTo: true)
            .orderBy(FirebaseConstants.labelName)
            .limit(50) // Safety limit for free tier
            .get(const GetOptions(source: Source.cache));

        final labels = snapshot.docs
            .map((doc) => LabelModel.fromFirestore(doc))
            .toList();

        final duration = DateTime.now().difference(cacheReadStart);
        final totalDuration = DateTime.now().difference(overallStart);

        debugPrint('[LabelRepository] ✅ Loaded ${labels.length} active labels from Firebase CACHE');
        debugPrint('[LabelRepository] Cache read: ${duration.inMilliseconds}ms');
        debugPrint('[LabelRepository] Total time: ${totalDuration.inMilliseconds}ms');

        return labels;
      } catch (e) {
        debugPrint('[LabelRepository] ⚠️ Firebase cache read failed: $e');
      }
    }

    debugPrint('[LabelRepository] ⏰ Cache STALE - fetching from Firebase server');
    final serverFetchStart = DateTime.now();

    final snapshot = await _firestoreService.labelsCollection
        .where(FirebaseConstants.labelIsActive, isEqualTo: true)
        .orderBy(FirebaseConstants.labelName)
        .limit(50) // Safety limit for free tier
        .get(const GetOptions(source: Source.server));

    final labels = snapshot.docs
        .map((doc) => LabelModel.fromFirestore(doc))
        .toList();

    await _cacheService.put(
      boxName: HiveCacheService.boxLabels,
      key: cacheKey,
      value: {'cached': true},
    );

    final serverDuration = DateTime.now().difference(serverFetchStart);
    final totalDuration = DateTime.now().difference(overallStart);

    debugPrint('[LabelRepository] ✅ Loaded ${labels.length} active labels from Firebase SERVER');
    debugPrint('[LabelRepository] Server fetch: ${serverDuration.inMilliseconds}ms');
    debugPrint('[LabelRepository] Total time: ${totalDuration.inMilliseconds}ms');

    return labels;
  }

  /// Stream active labels
  Stream<List<LabelModel>> streamActiveLabels() {
    return _firestoreService.labelsCollection
        .where(FirebaseConstants.labelIsActive, isEqualTo: true)
        .orderBy(FirebaseConstants.labelName)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => LabelModel.fromFirestore(doc)).toList());
  }

  /// Get labels by IDs (V2: Firebase cache + Hive TTL)
  /// Uses individual cache checks for maximum cache hit rate
  Future<List<LabelModel>> getLabelsByIds(List<String> labelIds) async {
    if (labelIds.isEmpty) return [];

    final overallStart = DateTime.now();
    debugPrint('[LabelRepository] 🏷️  getLabelsByIds() V2 started - ${labelIds.length} labels');

    final labels = <LabelModel>[];
    final cachedLabelIds = <String>[];
    final staleLabelIds = <String>[];

    // Check which labels have fresh individual cache timestamps
    for (final labelId in labelIds) {
      final cacheKey = 'label_${labelId}_timestamp';
      final isFresh = await _cacheService.isCacheFresh(
        boxName: HiveCacheService.boxLabels,
        key: cacheKey,
        ttl: HiveCacheService.ttlLong,
      );

      if (isFresh) {
        cachedLabelIds.add(labelId);
      } else {
        staleLabelIds.add(labelId);
      }
    }

    debugPrint('[LabelRepository] Cache status: ${cachedLabelIds.length} fresh, ${staleLabelIds.length} stale');

    // Read cached labels from Firebase cache (instant!)
    if (cachedLabelIds.isNotEmpty) {
      final cacheReadStart = DateTime.now();
      debugPrint('[LabelRepository] 📖 Reading ${cachedLabelIds.length} labels from Firebase CACHE');

      try {
        for (var i = 0; i < cachedLabelIds.length; i += 10) {
          final chunk = cachedLabelIds.skip(i).take(10).toList();
          final snapshot = await _firestoreService.labelsCollection
              .where(FieldPath.documentId, whereIn: chunk)
              .get(const GetOptions(source: Source.cache)); // 🔥 CACHE-ONLY
          labels.addAll(
            snapshot.docs.map((doc) => LabelModel.fromFirestore(doc)),
          );
        }

        final duration = DateTime.now().difference(cacheReadStart);
        debugPrint('[LabelRepository] ✅ Loaded ${labels.length} labels from Firebase CACHE in ${duration.inMilliseconds}ms');
      } catch (e) {
        debugPrint('[LabelRepository] ⚠️ Firebase cache read failed: $e');
        // Add failed IDs back to stale list
        staleLabelIds.addAll(cachedLabelIds);
        labels.clear();
      }
    }

    // Fetch stale labels from server
    if (staleLabelIds.isNotEmpty) {
      final serverFetchStart = DateTime.now();
      debugPrint('[LabelRepository] 🌐 Fetching ${staleLabelIds.length} labels from Firebase SERVER');

      for (var i = 0; i < staleLabelIds.length; i += 10) {
        final chunk = staleLabelIds.skip(i).take(10).toList();
        final snapshot = await _firestoreService.labelsCollection
            .where(FieldPath.documentId, whereIn: chunk)
            .get(const GetOptions(source: Source.server)); // 🌐 SERVER FETCH

        for (final doc in snapshot.docs) {
          labels.add(LabelModel.fromFirestore(doc));

          // Mark individual label as fresh
          await _cacheService.put(
            boxName: HiveCacheService.boxLabels,
            key: 'label_${doc.id}_timestamp',
            value: {'cached': true},
          );
        }
      }

      final duration = DateTime.now().difference(serverFetchStart);
      debugPrint('[LabelRepository] ✅ Fetched ${staleLabelIds.length} labels from SERVER in ${duration.inMilliseconds}ms');
    }

    final totalDuration = DateTime.now().difference(overallStart);
    debugPrint('[LabelRepository] 🎯 Total: Loaded ${labels.length} labels in ${totalDuration.inMilliseconds}ms (${cachedLabelIds.length} cached, ${staleLabelIds.length} fetched)');

    return labels;
  }

  /// Update label
  Future<void> updateLabel(LabelModel label) async {
    await _firestoreService.updateDocument(
      _firestoreService.labelDoc(label.id),
      label.toFirestore(),
    );
    await _invalidateLabelCaches();
  }

  /// Toggle label active status
  Future<void> toggleLabelActive(String labelId, bool isActive) async {
    await _firestoreService.updateDocument(
      _firestoreService.labelDoc(labelId),
      {FirebaseConstants.labelIsActive: isActive},
    );
    await _invalidateLabelCaches();
  }

  /// Delete label
  Future<void> deleteLabel(String labelId) async {
    await _firestoreService.deleteDocument(
      _firestoreService.labelDoc(labelId),
    );
    await _invalidateLabelCaches();
  }

  /// Check if label name exists
  Future<bool> labelNameExists(String name, {String? excludeId}) async {
    final snapshot = await _firestoreService.labelsCollection
        .where(FirebaseConstants.labelName, isEqualTo: name)
        .get();

    if (excludeId != null) {
      return snapshot.docs.any((doc) => doc.id != excludeId);
    }
    return snapshot.docs.isNotEmpty;
  }

  // ===========================================
  // CACHE INVALIDATION
  // ===========================================

  /// Invalidate label caches (only timestamps, data stays in Firebase cache)
  Future<void> _invalidateLabelCaches() async {
    debugPrint('[LabelRepository] 🗑️  Invalidating label caches...');

    final keysToDelete = [
      'all_labels_timestamp',
      'active_labels_timestamp',
    ];

    for (final key in keysToDelete) {
      await _cacheService.delete(
        boxName: HiveCacheService.boxLabels,
        key: key,
      );
    }

    debugPrint('[LabelRepository] ✅ Label caches invalidated');
  }
}
