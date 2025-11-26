import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:injectable/injectable.dart';

/// Centralized Hive cache service for local data persistence
///
/// Provides a clean API for caching and retrieving data with TTL (Time To Live) support.
/// Uses JSON serialization to store complex objects.
///
/// Strategy:
/// 1. Check cache first (instant response)
/// 2. If cache miss or expired, fetch from Firebase
/// 3. Update cache in background
///
/// Boxes:
/// - tasks_cache: Stores task data
/// - assignments_cache: Stores assignment data
/// - labels_cache: Stores label data
/// - users_cache: Stores user data
/// - settings_cache: Stores app settings data
/// - cache_metadata: Stores TTL and timestamps for cache invalidation
@lazySingleton
class HiveCacheService {
  Box? _tasksBox;
  Box? _assignmentsBox;
  Box? _labelsBox;
  Box? _usersBox;
  Box? _settingsBox;
  Box? _metadataBox;

  /// Initialize all Hive boxes
  /// Call this once during app initialization
  Future<void> initialize() async {
    await Hive.initFlutter();

    // Open all boxes
    _tasksBox = await Hive.openBox('tasks_cache');
    _assignmentsBox = await Hive.openBox('assignments_cache');
    _labelsBox = await Hive.openBox('labels_cache');
    _usersBox = await Hive.openBox('users_cache');
    _settingsBox = await Hive.openBox('settings_cache');
    _metadataBox = await Hive.openBox('cache_metadata');
  }

  // ===========================================
  // CACHE OPERATIONS
  // ===========================================

  /// Get cached data with TTL check
  ///
  /// Returns null if:
  /// - Key doesn't exist
  /// - Cache is expired (based on TTL)
  Future<T?> get<T>({
    required String boxName,
    required String key,
    Duration? ttl,
  }) async {
    final startTime = DateTime.now();
    final box = _getBox(boxName);
    if (box == null) {
      debugPrint('[HiveCache] ❌ Box not found: $boxName');
      return null;
    }

    // Check if cache exists
    if (!box.containsKey(key)) {
      debugPrint('[HiveCache] ⚠️  Cache MISS: $boxName/$key (key not found)');
      return null;
    }

    // Check TTL if provided
    if (ttl != null) {
      final metadata = _metadataBox?.get('${boxName}_$key');
      if (metadata != null && metadata is Map) {
        final cachedAt = DateTime.parse(metadata['cachedAt'] as String);
        final now = DateTime.now();
        final age = now.difference(cachedAt);

        if (age > ttl) {
          // Cache expired, remove it
          await box.delete(key);
          await _metadataBox?.delete('${boxName}_$key');
          debugPrint('[HiveCache] ⏰ Cache EXPIRED: $boxName/$key (age: ${age.inSeconds}s, ttl: ${ttl.inSeconds}s)');
          return null;
        }
      }
    }

    final rawValue = box.get(key);
    if (rawValue == null) {
      final duration = DateTime.now().difference(startTime);
      debugPrint('[HiveCache] ❌ Cache MISS: $boxName/$key (read time: ${duration.inMilliseconds}ms)');
      return null;
    }

    // Handle Map type conversion (Hive stores as Map<dynamic, dynamic>)
    T? value;
    if (rawValue is Map) {
      // Convert Map<dynamic, dynamic> to Map<String, dynamic>
      try {
        value = Map<String, dynamic>.from(rawValue) as T?;
      } catch (e) {
        // If conversion fails, try direct cast
        debugPrint('[HiveCache] ⚠️ Map conversion failed, using direct cast: $e');
        value = rawValue as T?;
      }
    } else {
      value = rawValue as T?;
    }

    final duration = DateTime.now().difference(startTime);
    debugPrint('[HiveCache] ✅ Cache HIT: $boxName/$key (read time: ${duration.inMilliseconds}ms)');
    return value;
  }

  /// Get multiple items at once (batch get)
  Future<Map<String, T>> getAll<T>({
    required String boxName,
    required List<String> keys,
    Duration? ttl,
  }) async {
    final results = <String, T>{};

    for (final key in keys) {
      final value = await get<T>(boxName: boxName, key: key, ttl: ttl);
      if (value != null) {
        results[key] = value;
      }
    }

    return results;
  }

  /// Put data into cache with timestamp
  Future<void> put({
    required String boxName,
    required String key,
    required dynamic value,
  }) async {
    final startTime = DateTime.now();
    final box = _getBox(boxName);
    if (box == null) {
      debugPrint('[HiveCache] ❌ Cannot write - Box not found: $boxName');
      return;
    }

    await box.put(key, value);

    // Store metadata for TTL tracking
    await _metadataBox?.put('${boxName}_$key', {
      'cachedAt': DateTime.now().toIso8601String(),
    });

    final duration = DateTime.now().difference(startTime);
    debugPrint('[HiveCache] 💾 Cache WRITE: $boxName/$key (write time: ${duration.inMilliseconds}ms)');
  }

  /// Put multiple items at once (batch put)
  Future<void> putAll({
    required String boxName,
    required Map<String, dynamic> entries,
  }) async {
    final box = _getBox(boxName);
    if (box == null) return;

    final now = DateTime.now().toIso8601String();

    await box.putAll(entries);

    // Store metadata for all entries
    final metadataEntries = <String, Map<String, String>>{};
    for (final key in entries.keys) {
      metadataEntries['${boxName}_$key'] = {'cachedAt': now};
    }
    await _metadataBox?.putAll(metadataEntries);
  }

  /// Delete a single cached item
  Future<void> delete({
    required String boxName,
    required String key,
  }) async {
    final box = _getBox(boxName);
    await box?.delete(key);
    await _metadataBox?.delete('${boxName}_$key');
  }

  /// Delete multiple items at once (batch delete)
  Future<void> deleteAll({
    required String boxName,
    required List<String> keys,
  }) async {
    final box = _getBox(boxName);
    if (box == null) return;

    await box.deleteAll(keys);

    final metadataKeys = keys.map((k) => '${boxName}_$k').toList();
    await _metadataBox?.deleteAll(metadataKeys);
  }

  /// Clear entire box (use with caution!)
  Future<void> clearBox(String boxName) async {
    final box = _getBox(boxName);
    await box?.clear();

    // Clear metadata for this box
    final keysToDelete = <String>[];
    _metadataBox?.keys.forEach((key) {
      if (key.toString().startsWith('${boxName}_')) {
        keysToDelete.add(key.toString());
      }
    });
    await _metadataBox?.deleteAll(keysToDelete);
  }

  /// Clear all caches (nuclear option)
  Future<void> clearAllCaches() async {
    await _tasksBox?.clear();
    await _assignmentsBox?.clear();
    await _labelsBox?.clear();
    await _usersBox?.clear();
    await _settingsBox?.clear();
    await _metadataBox?.clear();
  }

  // ===========================================
  // BOX NAME CONSTANTS
  // ===========================================

  static const String boxTasks = 'tasks_cache';
  static const String boxAssignments = 'assignments_cache';
  static const String boxLabels = 'labels_cache';
  static const String boxUsers = 'users_cache';
  static const String boxSettings = 'settings_cache';

  // ===========================================
  // TTL CONSTANTS (Recommended durations)
  // ===========================================

  /// Short TTL for frequently changing data (5 minutes)
  static const Duration ttlShort = Duration(minutes: 5);

  /// Medium TTL for moderately changing data (30 minutes)
  static const Duration ttlMedium = Duration(minutes: 30);

  /// Long TTL for rarely changing data (2 hours)
  static const Duration ttlLong = Duration(hours: 2);

  /// Extra long TTL for static data (24 hours)
  static const Duration ttlExtraLong = Duration(hours: 24);

  // ===========================================
  // HELPER METHODS
  // ===========================================

  /// Get box by name
  Box? _getBox(String boxName) {
    switch (boxName) {
      case boxTasks:
        return _tasksBox;
      case boxAssignments:
        return _assignmentsBox;
      case boxLabels:
        return _labelsBox;
      case boxUsers:
        return _usersBox;
      case boxSettings:
        return _settingsBox;
      default:
        return null;
    }
  }

  /// Check if cache exists and is fresh
  Future<bool> isCacheFresh({
    required String boxName,
    required String key,
    required Duration ttl,
  }) async {
    final box = _getBox(boxName);
    if (box == null || !box.containsKey(key)) return false;

    final metadata = _metadataBox?.get('${boxName}_$key');
    if (metadata == null || metadata is! Map) return false;

    final cachedAt = DateTime.parse(metadata['cachedAt'] as String);
    final now = DateTime.now();

    return now.difference(cachedAt) <= ttl;
  }

  /// Get cache age
  Future<Duration?> getCacheAge({
    required String boxName,
    required String key,
  }) async {
    final metadata = _metadataBox?.get('${boxName}_$key');
    if (metadata == null || metadata is! Map) return null;

    final cachedAt = DateTime.parse(metadata['cachedAt'] as String);
    return DateTime.now().difference(cachedAt);
  }

  /// Get cache statistics for debugging
  Map<String, int> getCacheStats() {
    return {
      'tasks': _tasksBox?.length ?? 0,
      'assignments': _assignmentsBox?.length ?? 0,
      'labels': _labelsBox?.length ?? 0,
      'users': _usersBox?.length ?? 0,
    };
  }

  /// Dispose and close all boxes
  Future<void> dispose() async {
    await _tasksBox?.close();
    await _assignmentsBox?.close();
    await _labelsBox?.close();
    await _usersBox?.close();
    await _metadataBox?.close();
  }
}
