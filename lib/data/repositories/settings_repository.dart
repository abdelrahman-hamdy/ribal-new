import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../core/constants/firebase_constants.dart';
import '../../core/services/hive_cache_service.dart';
import '../models/settings_model.dart';
import '../services/firestore_service.dart';

/// Settings repository for app configuration with V2 caching
/// Strategy: Firebase cache + Hive TTL metadata
@lazySingleton
class SettingsRepository {
  final FirestoreService _firestoreService;
  final HiveCacheService _cacheService;

  SettingsRepository(this._firestoreService, this._cacheService);

  /// Get global settings (V2: Firebase cache + Hive TTL)
  Future<SettingsModel> getSettings() async {
    final overallStart = DateTime.now();
    debugPrint('[SettingsRepository] ⚙️ getSettings() V2 started');

    const cacheKey = 'global_settings_timestamp';

    // Check if Firebase cache is fresh
    final isFresh = await _cacheService.isCacheFresh(
      boxName: HiveCacheService.boxSettings,
      key: cacheKey,
      ttl: HiveCacheService.ttlLong, // Settings rarely change
    );

    if (isFresh) {
      debugPrint('[SettingsRepository] ✅ Cache FRESH - reading from Firebase cache');
      final cacheReadStart = DateTime.now();

      try {
        final doc = await _firestoreService.globalSettingsDoc
            .get(const GetOptions(source: Source.cache)); // 🔥 CACHE-ONLY

        final duration = DateTime.now().difference(cacheReadStart);
        final totalDuration = DateTime.now().difference(overallStart);

        if (!doc.exists) {
          debugPrint('[SettingsRepository] ⚠️ Settings doc does not exist, using defaults');
          debugPrint('[SettingsRepository] Total time: ${totalDuration.inMilliseconds}ms');
          return SettingsModel.defaults();
        }

        final settings = SettingsModel.fromFirestore(doc);
        debugPrint('[SettingsRepository] ✅ Loaded settings from Firebase CACHE');
        debugPrint('[SettingsRepository] Cache read: ${duration.inMilliseconds}ms');
        debugPrint('[SettingsRepository] Total time: ${totalDuration.inMilliseconds}ms');

        return settings;
      } catch (e) {
        debugPrint('[SettingsRepository] ⚠️ Firebase cache read failed: $e');
      }
    }

    // Cache is stale or missing - fetch from SERVER
    debugPrint('[SettingsRepository] ⏰ Cache STALE - fetching from Firebase server');
    final serverFetchStart = DateTime.now();

    final doc = await _firestoreService.globalSettingsDoc
        .get(const GetOptions(source: Source.server)); // 🌐 SERVER FETCH

    if (!doc.exists) {
      debugPrint('[SettingsRepository] ⚠️ Settings doc does not exist, using defaults');
      return SettingsModel.defaults();
    }

    final settings = SettingsModel.fromFirestore(doc);

    // Mark cache as fresh (Firebase already cached it)
    await _cacheService.put(
      boxName: HiveCacheService.boxSettings,
      key: cacheKey,
      value: {'cached': true}, // Just metadata
    );

    final serverDuration = DateTime.now().difference(serverFetchStart);
    final totalDuration = DateTime.now().difference(overallStart);

    debugPrint('[SettingsRepository] ✅ Loaded settings from Firebase SERVER');
    debugPrint('[SettingsRepository] Server fetch: ${serverDuration.inMilliseconds}ms');
    debugPrint('[SettingsRepository] Total time: ${totalDuration.inMilliseconds}ms');

    return settings;
  }

  /// Stream global settings
  Stream<SettingsModel> streamSettings() {
    return _firestoreService
        .streamDocument(_firestoreService.globalSettingsDoc)
        .map((doc) {
      if (!doc.exists) return SettingsModel.defaults();
      return SettingsModel.fromFirestore(doc);
    });
  }

  /// Invalidate settings cache to force fresh fetch
  Future<void> _invalidateSettingsCache() async {
    await _cacheService.delete(
      boxName: HiveCacheService.boxSettings,
      key: 'global_settings_timestamp',
    );
    debugPrint('[SettingsRepository] 🗑️ Settings cache invalidated');
  }

  /// Update recurring task time
  Future<void> updateRecurringTaskTime(String time) async {
    await _firestoreService.setDocument(
      _firestoreService.globalSettingsDoc,
      {FirebaseConstants.settingsRecurringTaskTime: time},
      merge: true,
    );
    await _invalidateSettingsCache();
  }

  /// Update task deadline
  Future<void> updateTaskDeadline(String time) async {
    await _firestoreService.setDocument(
      _firestoreService.globalSettingsDoc,
      {FirebaseConstants.settingsTaskDeadline: time},
      merge: true,
    );
    await _invalidateSettingsCache();
  }

  /// Update all settings
  Future<void> updateSettings(SettingsModel settings) async {
    await _firestoreService.setDocument(
      _firestoreService.globalSettingsDoc,
      settings.toFirestore(),
      merge: true,
    );
    await _invalidateSettingsCache();
  }
}
