import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../core/constants/firebase_constants.dart';
import '../../core/services/hive_cache_service.dart';
import '../models/paginated_result.dart';
import '../models/task_model.dart';
import '../services/firestore_service.dart';

/// Task repository for CRUD operations with Hive caching
@lazySingleton
class TaskRepository {
  final FirestoreService _firestoreService;
  final HiveCacheService _cacheService;

  TaskRepository(this._firestoreService, this._cacheService);

  /// Invalidate cache timestamps (V2 approach - invalidates Firebase cache freshness)
  Future<void> _invalidateTaskCaches({
    bool invalidateActive = false,
    bool invalidateArchived = false,
    String? specificTaskId,
    String? creatorId,
  }) async {
    final keysToDelete = <String>[];

    if (invalidateActive) {
      keysToDelete.add('active_tasks_timestamp');
      keysToDelete.add('active_tasks_page_1_timestamp');
    }

    if (invalidateArchived) {
      keysToDelete.add('archived_tasks_timestamp');
    }

    if (specificTaskId != null) {
      keysToDelete.add('${specificTaskId}_timestamp');
    }

    if (creatorId != null) {
      keysToDelete.add('tasks_by_creator_${creatorId}_timestamp');
    }

    // Delete only the affected timestamp keys (data stays in Firebase cache)
    for (final key in keysToDelete) {
      await _cacheService.delete(
        boxName: HiveCacheService.boxTasks,
        key: key,
      );
    }
  }

  /// Create task
  Future<TaskModel> createTask(TaskModel task) async {
    final docRef = await _firestoreService.createDocument(
      _firestoreService.tasksCollection,
      task.toFirestore(),
    );

    // Invalidate active task caches and creator-specific cache
    await _invalidateTaskCaches(
      invalidateActive: true,
      creatorId: task.createdBy,
    );

    return task.copyWith(id: docRef.id);
  }

  /// Get task by ID (V2: Firebase cache + Hive TTL)
  Future<TaskModel?> getTaskById(String taskId) async {
    final cacheKey = '${taskId}_timestamp';

    // Check if Firebase cache is fresh
    final isFresh = await _cacheService.isCacheFresh(
      boxName: HiveCacheService.boxTasks,
      key: cacheKey,
      ttl: HiveCacheService.ttlMedium,
    );

    if (isFresh) {
      // Use Firebase CACHE (instant)
      try {
        final doc = await _firestoreService.taskDoc(taskId)
            .get(const GetOptions(source: Source.cache));

        if (!doc.exists) return null;
        return TaskModel.fromFirestore(doc);
      } catch (e) {
        debugPrint('[TaskRepository] Firebase cache read failed for task $taskId: $e');
      }
    }

    // Fetch from server
    final doc = await _firestoreService.taskDoc(taskId)
        .get(const GetOptions(source: Source.server));

    if (!doc.exists) return null;

    final task = TaskModel.fromFirestore(doc);

    // Mark cache as fresh
    await _cacheService.put(
      boxName: HiveCacheService.boxTasks,
      key: cacheKey,
      value: {'cached': true},
    );

    return task;
  }

  /// Batch get tasks by IDs (optimized for multiple tasks) with V2 caching
  /// Uses individual cache checks for maximum cache hit rate
  Future<Map<String, TaskModel>> getTasksByIds(List<String> taskIds) async {
    if (taskIds.isEmpty) return {};

    final overallStart = DateTime.now();
    debugPrint('[TaskRepository] 📋 getTasksByIds() V2 started - ${taskIds.length} tasks');

    final tasks = <String, TaskModel>{};
    final cachedTaskIds = <String>[];
    final staleTaskIds = <String>[];

    // Check which tasks have fresh individual cache timestamps
    for (final taskId in taskIds) {
      final cacheKey = '${taskId}_timestamp';
      final isFresh = await _cacheService.isCacheFresh(
        boxName: HiveCacheService.boxTasks,
        key: cacheKey,
        ttl: HiveCacheService.ttlMedium,
      );

      if (isFresh) {
        cachedTaskIds.add(taskId);
      } else {
        staleTaskIds.add(taskId);
      }
    }

    debugPrint('[TaskRepository] Cache status: ${cachedTaskIds.length} fresh, ${staleTaskIds.length} stale');

    // Read cached tasks from Firebase cache (instant!)
    if (cachedTaskIds.isNotEmpty) {
      final cacheReadStart = DateTime.now();
      debugPrint('[TaskRepository] 📖 Reading ${cachedTaskIds.length} tasks from Firebase CACHE');

      try {
        for (var i = 0; i < cachedTaskIds.length; i += 10) {
          final batch = cachedTaskIds.skip(i).take(10).toList();
          final snapshot = await _firestoreService.tasksCollection
              .where(FieldPath.documentId, whereIn: batch)
              .get(const GetOptions(source: Source.cache)); // 🔥 CACHE-ONLY

          for (final doc in snapshot.docs) {
            tasks[doc.id] = TaskModel.fromFirestore(doc);
          }
        }

        final duration = DateTime.now().difference(cacheReadStart);
        debugPrint('[TaskRepository] ✅ Loaded ${tasks.length} tasks from Firebase CACHE in ${duration.inMilliseconds}ms');
      } catch (e) {
        debugPrint('[TaskRepository] ⚠️ Firebase cache read failed: $e');
        // Add failed IDs back to stale list
        staleTaskIds.addAll(cachedTaskIds);
      }
    }

    // Fetch stale tasks from server
    if (staleTaskIds.isNotEmpty) {
      final serverFetchStart = DateTime.now();
      debugPrint('[TaskRepository] 🌐 Fetching ${staleTaskIds.length} tasks from Firebase SERVER');

      for (var i = 0; i < staleTaskIds.length; i += 10) {
        final batch = staleTaskIds.skip(i).take(10).toList();
        final snapshot = await _firestoreService.tasksCollection
            .where(FieldPath.documentId, whereIn: batch)
            .get(const GetOptions(source: Source.server)); // 🌐 SERVER FETCH

        for (final doc in snapshot.docs) {
          tasks[doc.id] = TaskModel.fromFirestore(doc);

          // Mark individual task as fresh
          await _cacheService.put(
            boxName: HiveCacheService.boxTasks,
            key: '${doc.id}_timestamp',
            value: {'cached': true},
          );
        }
      }

      final duration = DateTime.now().difference(serverFetchStart);
      debugPrint('[TaskRepository] ✅ Fetched ${staleTaskIds.length} tasks from SERVER in ${duration.inMilliseconds}ms');
    }

    final totalDuration = DateTime.now().difference(overallStart);
    debugPrint('[TaskRepository] 🎯 Total: Loaded ${tasks.length} tasks in ${totalDuration.inMilliseconds}ms (${cachedTaskIds.length} cached, ${staleTaskIds.length} fetched)');

    return tasks;
  }

  /// Stream task by ID
  Stream<TaskModel?> streamTask(String taskId) {
    return _firestoreService
        .streamDocument(_firestoreService.taskDoc(taskId))
        .map((doc) => doc.exists ? TaskModel.fromFirestore(doc) : null);
  }

  /// Get tasks created by user (V2: Firebase cache + Hive TTL)
  /// NOTE: Consider using getTasksByCreatorPaginated() for better performance
  Future<List<TaskModel>> getTasksByCreator(String userId) async {
    final overallStart = DateTime.now();
    debugPrint('[TaskRepository] 📋 getTasksByCreator() V2 started - userId: $userId');

    final cacheKey = 'tasks_by_creator_${userId}_timestamp';

    // Check if Firebase cache is fresh
    final isFresh = await _cacheService.isCacheFresh(
      boxName: HiveCacheService.boxTasks,
      key: cacheKey,
      ttl: HiveCacheService.ttlShort, // Tasks change frequently
    );

    if (isFresh) {
      // Use Firebase CACHE (instant, no network!)
      debugPrint('[TaskRepository] ✅ Cache FRESH - reading from Firebase cache');
      final cacheReadStart = DateTime.now();

      try {
        final snapshot = await _firestoreService.tasksCollection
            .where(FirebaseConstants.taskCreatedBy, isEqualTo: userId)
            .where(FirebaseConstants.taskIsArchived, isEqualTo: false)
            .orderBy(FirebaseConstants.taskCreatedAt, descending: true)
            .get(const GetOptions(source: Source.cache)); // 🔥 CACHE-ONLY

        final tasks = snapshot.docs
            .map((doc) => TaskModel.fromFirestore(doc))
            .toList();

        final duration = DateTime.now().difference(cacheReadStart);
        final totalDuration = DateTime.now().difference(overallStart);

        debugPrint('[TaskRepository] ✅ Loaded ${tasks.length} tasks from Firebase CACHE');
        debugPrint('[TaskRepository] Cache read: ${duration.inMilliseconds}ms');
        debugPrint('[TaskRepository] Total time: ${totalDuration.inMilliseconds}ms');

        return tasks;
      } catch (e) {
        debugPrint('[TaskRepository] ⚠️ Firebase cache read failed: $e');
      }
    }

    // Cache is stale or missing - fetch from SERVER
    debugPrint('[TaskRepository] ⏰ Cache STALE - fetching from Firebase server');
    final serverFetchStart = DateTime.now();

    final snapshot = await _firestoreService.tasksCollection
        .where(FirebaseConstants.taskCreatedBy, isEqualTo: userId)
        .where(FirebaseConstants.taskIsArchived, isEqualTo: false)
        .orderBy(FirebaseConstants.taskCreatedAt, descending: true)
        .get(const GetOptions(source: Source.server)); // 🌐 SERVER FETCH

    final tasks = snapshot.docs
        .map((doc) => TaskModel.fromFirestore(doc))
        .toList();

    // Mark cache as fresh (Firebase already cached it)
    await _cacheService.put(
      boxName: HiveCacheService.boxTasks,
      key: cacheKey,
      value: {'cached': true}, // Just metadata
    );

    final serverDuration = DateTime.now().difference(serverFetchStart);
    final totalDuration = DateTime.now().difference(overallStart);

    debugPrint('[TaskRepository] ✅ Loaded ${tasks.length} tasks from Firebase SERVER');
    debugPrint('[TaskRepository] Server fetch: ${serverDuration.inMilliseconds}ms');
    debugPrint('[TaskRepository] Total time: ${totalDuration.inMilliseconds}ms');

    return tasks;
  }

  /// Get tasks created by user with pagination
  Future<PaginatedResult<TaskModel>> getTasksByCreatorPaginated({
    required String userId,
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) async {
    var query = _firestoreService.tasksCollection
        .where(FirebaseConstants.taskCreatedBy, isEqualTo: userId)
        .where(FirebaseConstants.taskIsArchived, isEqualTo: false)
        .orderBy(FirebaseConstants.taskCreatedAt, descending: true)
        .limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snapshot = await query.get();
    final tasks = snapshot.docs
        .map((doc) => TaskModel.fromFirestore(doc))
        .toList();

    return PaginatedResult(
      items: tasks,
      lastDocument: snapshot.docs.isNotEmpty ? snapshot.docs.last : null,
      hasMore: snapshot.docs.length == limit,
    );
  }

  /// Stream tasks created by user
  Stream<List<TaskModel>> streamTasksByCreator(String userId) {
    return _firestoreService.tasksCollection
        .where(FirebaseConstants.taskCreatedBy, isEqualTo: userId)
        .where(FirebaseConstants.taskIsArchived, isEqualTo: false)
        .orderBy(FirebaseConstants.taskCreatedAt, descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList());
  }

  /// Get all active tasks (not archived) with SMART CACHING (V2)
  ///
  /// Uses Firebase's built-in cache with Hive TTL metadata:
  /// 1. Check if Firebase cache is fresh (via Hive timestamp)
  /// 2. If fresh: GetOptions(source: Source.cache) - INSTANT (0ms network)
  /// 3. If stale: GetOptions(source: Source.server) - Network fetch
  /// 4. Firebase automatically caches server result
  Future<List<TaskModel>> getActiveTasks() async {
    final overallStart = DateTime.now();
    debugPrint('[TaskRepository] 📋 getActiveTasks() V2 started');

    const cacheKey = 'active_tasks_timestamp';

    // Check if Firebase cache is fresh
    final isFresh = await _cacheService.isCacheFresh(
      boxName: HiveCacheService.boxTasks,
      key: cacheKey,
      ttl: HiveCacheService.ttlShort,
    );

    if (isFresh) {
      // Use Firebase CACHE (instant, no network!)
      debugPrint('[TaskRepository] ✅ Cache FRESH - reading from Firebase cache');
      final cacheReadStart = DateTime.now();

      try {
        final snapshot = await _firestoreService.tasksCollection
            .where(FirebaseConstants.taskIsArchived, isEqualTo: false)
            .orderBy(FirebaseConstants.taskCreatedAt, descending: true)
            .get(const GetOptions(source: Source.cache)); // 🔥 CACHE-ONLY

        final tasks = snapshot.docs
            .map((doc) => TaskModel.fromFirestore(doc))
            .toList();

        final duration = DateTime.now().difference(cacheReadStart);
        final totalDuration = DateTime.now().difference(overallStart);

        debugPrint('[TaskRepository] ✅ Loaded ${tasks.length} tasks from Firebase CACHE');
        debugPrint('[TaskRepository] Cache read: ${duration.inMilliseconds}ms');
        debugPrint('[TaskRepository] Total time: ${totalDuration.inMilliseconds}ms');

        return tasks;
      } catch (e) {
        // Cache miss or error - fall through to server fetch
        debugPrint('[TaskRepository] ⚠️ Firebase cache read failed: $e');
      }
    }

    // Cache is stale or missing - fetch from SERVER
    debugPrint('[TaskRepository] ⏰ Cache STALE - fetching from Firebase server');
    final serverFetchStart = DateTime.now();

    final snapshot = await _firestoreService.tasksCollection
        .where(FirebaseConstants.taskIsArchived, isEqualTo: false)
        .orderBy(FirebaseConstants.taskCreatedAt, descending: true)
        .get(const GetOptions(source: Source.server)); // 🌐 SERVER FETCH

    final tasks = snapshot.docs
        .map((doc) => TaskModel.fromFirestore(doc))
        .toList();

    // Mark cache as fresh (Firebase already cached it)
    await _cacheService.put(
      boxName: HiveCacheService.boxTasks,
      key: cacheKey,
      value: {'cached': true}, // Just metadata
    );

    final serverDuration = DateTime.now().difference(serverFetchStart);
    final totalDuration = DateTime.now().difference(overallStart);

    debugPrint('[TaskRepository] ✅ Loaded ${tasks.length} tasks from Firebase SERVER');
    debugPrint('[TaskRepository] Server fetch: ${serverDuration.inMilliseconds}ms');
    debugPrint('[TaskRepository] Total time: ${totalDuration.inMilliseconds}ms');

    return tasks;
  }

  /// Get active tasks with pagination (recommended for large datasets)
  /// Uses cache-first strategy for first page only
  Future<PaginatedResult<TaskModel>> getActiveTasksPaginated({
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) async {
    // Only cache first page for instant initial load
    if (startAfter == null) {
      const cacheKey = 'active_tasks_page_1';

      // Try cache first for initial page
      final cachedJson = await _cacheService.get<List>(
        boxName: HiveCacheService.boxTasks,
        key: cacheKey,
        ttl: HiveCacheService.ttlShort, // 5 min TTL
      );

      if (cachedJson != null && cachedJson.isNotEmpty) {
        // Return cached first page immediately (convert from Map<dynamic, dynamic> to Map<String, dynamic>)
        final tasks = cachedJson
            .map((json) => TaskModel.fromJson(Map<String, dynamic>.from(json as Map)))
            .toList();

        return PaginatedResult(
          items: tasks,
          lastDocument: null, // Can't restore DocumentSnapshot from cache
          hasMore: tasks.length == limit,
        );
      }
    }

    // Fetch from Firebase
    var query = _firestoreService.tasksCollection
        .where(FirebaseConstants.taskIsArchived, isEqualTo: false)
        .orderBy(FirebaseConstants.taskCreatedAt, descending: true)
        .limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snapshot = await query.get();
    final tasks = snapshot.docs
        .map((doc) => TaskModel.fromFirestore(doc))
        .toList();

    // Cache first page only
    if (startAfter == null && tasks.isNotEmpty) {
      await _cacheService.put(
        boxName: HiveCacheService.boxTasks,
        key: 'active_tasks_page_1',
        value: tasks.map((task) => task.toJson()).toList(),
      );
    }

    return PaginatedResult(
      items: tasks,
      lastDocument: snapshot.docs.isNotEmpty ? snapshot.docs.last : null,
      hasMore: snapshot.docs.length == limit,
    );
  }

  /// Stream all active tasks
  Stream<List<TaskModel>> streamActiveTasks() {
    return _firestoreService.tasksCollection
        .where(FirebaseConstants.taskIsArchived, isEqualTo: false)
        .orderBy(FirebaseConstants.taskCreatedAt, descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList());
  }

  /// Get archived tasks with SMART CACHING (V2)
  Future<List<TaskModel>> getArchivedTasks() async {
    const cacheKey = 'archived_tasks_timestamp';

    // Check if Firebase cache is fresh
    final isFresh = await _cacheService.isCacheFresh(
      boxName: HiveCacheService.boxTasks,
      key: cacheKey,
      ttl: HiveCacheService.ttlShort,
    );

    if (isFresh) {
      // Use Firebase CACHE (instant)
      try {
        final snapshot = await _firestoreService.tasksCollection
            .where(FirebaseConstants.taskIsArchived, isEqualTo: true)
            .orderBy(FirebaseConstants.taskCreatedAt, descending: true)
            .get(const GetOptions(source: Source.cache));

        return snapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList();
      } catch (e) {
        debugPrint('[TaskRepository] Firebase cache read failed for archived tasks: $e');
      }
    }

    // Fetch from server
    final snapshot = await _firestoreService.tasksCollection
        .where(FirebaseConstants.taskIsArchived, isEqualTo: true)
        .orderBy(FirebaseConstants.taskCreatedAt, descending: true)
        .get(const GetOptions(source: Source.server));

    final tasks = snapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList();

    // Mark cache as fresh
    await _cacheService.put(
      boxName: HiveCacheService.boxTasks,
      key: cacheKey,
      value: {'cached': true},
    );

    return tasks;
  }

  /// Get archived tasks with pagination
  Future<PaginatedResult<TaskModel>> getArchivedTasksPaginated({
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) async {
    var query = _firestoreService.tasksCollection
        .where(FirebaseConstants.taskIsArchived, isEqualTo: true)
        .orderBy(FirebaseConstants.taskCreatedAt, descending: true)
        .limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snapshot = await query.get();
    final tasks = snapshot.docs
        .map((doc) => TaskModel.fromFirestore(doc))
        .toList();

    return PaginatedResult(
      items: tasks,
      lastDocument: snapshot.docs.isNotEmpty ? snapshot.docs.last : null,
      hasMore: snapshot.docs.length == limit,
    );
  }

  /// Stream archived tasks
  Stream<List<TaskModel>> streamArchivedTasks() {
    return _firestoreService.tasksCollection
        .where(FirebaseConstants.taskIsArchived, isEqualTo: true)
        .orderBy(FirebaseConstants.taskCreatedAt, descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList());
  }

  /// Get active recurring tasks (limited to 50 for performance)
  Future<List<TaskModel>> getActiveRecurringTasks() async {
    final snapshot = await _firestoreService.tasksCollection
        .where(FirebaseConstants.taskIsRecurring, isEqualTo: true)
        .where(FirebaseConstants.taskIsActive, isEqualTo: true)
        .where(FirebaseConstants.taskIsArchived, isEqualTo: false)
        .limit(50) // Safety limit for free tier
        .get();

    return snapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList();
  }

  /// Update task
  Future<void> updateTask(TaskModel task) async {
    await _firestoreService.updateDocument(
      _firestoreService.taskDoc(task.id),
      {
        ...task.toFirestore(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
    );

    // Invalidate affected caches (update could affect lists, individual task, and creator)
    await _invalidateTaskCaches(
      invalidateActive: !task.isArchived,
      invalidateArchived: task.isArchived,
      specificTaskId: task.id,
      creatorId: task.createdBy,
    );
  }

  /// Toggle task recurring status
  Future<void> toggleRecurringActive(String taskId, bool isActive) async {
    await _firestoreService.updateDocument(
      _firestoreService.taskDoc(taskId),
      {
        FirebaseConstants.taskIsActive: isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      },
    );

    // Only invalidate active list (toggling doesn't change archive status)
    await _invalidateTaskCaches(
      invalidateActive: true,
      specificTaskId: taskId,
    );
  }

  /// Archive task
  Future<void> archiveTask(String taskId) async {
    await _firestoreService.updateDocument(
      _firestoreService.taskDoc(taskId),
      {
        FirebaseConstants.taskIsArchived: true,
        FirebaseConstants.taskIsActive: false,
        'updatedAt': FieldValue.serverTimestamp(),
      },
    );

    // Task moves from active to archived list
    await _invalidateTaskCaches(
      invalidateActive: true,
      invalidateArchived: true,
      specificTaskId: taskId,
    );
  }

  /// Restore task from archive (legacy - use specific methods below)
  Future<void> restoreTask(String taskId) async {
    await _firestoreService.updateDocument(
      _firestoreService.taskDoc(taskId),
      {
        FirebaseConstants.taskIsArchived: false,
        'updatedAt': FieldValue.serverTimestamp(),
      },
    );

    // Task moves from archived to active list
    await _invalidateTaskCaches(
      invalidateActive: true,
      invalidateArchived: true,
      specificTaskId: taskId,
    );
  }

  /// Restore task as recurring (publish as recurring task)
  Future<void> restoreTaskAsRecurring(String taskId) async {
    await _firestoreService.updateDocument(
      _firestoreService.taskDoc(taskId),
      {
        FirebaseConstants.taskIsArchived: false,
        FirebaseConstants.taskIsRecurring: true,
        FirebaseConstants.taskIsActive: true,
        'updatedAt': FieldValue.serverTimestamp(),
      },
    );

    // Task moves from archived to active list
    await _invalidateTaskCaches(
      invalidateActive: true,
      invalidateArchived: true,
      specificTaskId: taskId,
    );
  }

  /// Restore task for today only (publish as one-time task)
  Future<void> restoreTaskForTodayOnly(String taskId) async {
    await _firestoreService.updateDocument(
      _firestoreService.taskDoc(taskId),
      {
        FirebaseConstants.taskIsArchived: false,
        FirebaseConstants.taskIsRecurring: false,
        FirebaseConstants.taskIsActive: true,
        'updatedAt': FieldValue.serverTimestamp(),
      },
    );

    // Task moves from archived to active list
    await _invalidateTaskCaches(
      invalidateActive: true,
      invalidateArchived: true,
      specificTaskId: taskId,
    );
  }

  /// Delete task
  Future<void> deleteTask(String taskId) async {
    await _firestoreService.deleteDocument(
      _firestoreService.taskDoc(taskId),
    );

    // Could be from active or archived list, so invalidate both
    await _invalidateTaskCaches(
      invalidateActive: true,
      invalidateArchived: true,
      specificTaskId: taskId,
    );
  }

  /// Duplicate task (for copying to archive or rescheduling)
  Future<TaskModel> duplicateTask(TaskModel task, {bool archived = false}) async {
    final newTask = task.copyWith(
      id: '',
      isArchived: archived,
      isActive: !archived && task.isRecurring,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return await createTask(newTask);
  }
}
