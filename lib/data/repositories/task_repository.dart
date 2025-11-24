import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import '../../core/constants/firebase_constants.dart';
import '../models/task_model.dart';
import '../services/firestore_service.dart';

/// Task repository for CRUD operations
@lazySingleton
class TaskRepository {
  final FirestoreService _firestoreService;

  TaskRepository(this._firestoreService);

  /// Create task
  Future<TaskModel> createTask(TaskModel task) async {
    final docRef = await _firestoreService.createDocument(
      _firestoreService.tasksCollection,
      task.toFirestore(),
    );

    return task.copyWith(id: docRef.id);
  }

  /// Get task by ID
  Future<TaskModel?> getTaskById(String taskId) async {
    final doc = await _firestoreService.taskDoc(taskId).get();
    if (!doc.exists) return null;
    return TaskModel.fromFirestore(doc);
  }

  /// Stream task by ID
  Stream<TaskModel?> streamTask(String taskId) {
    return _firestoreService
        .streamDocument(_firestoreService.taskDoc(taskId))
        .map((doc) => doc.exists ? TaskModel.fromFirestore(doc) : null);
  }

  /// Get tasks created by user
  Future<List<TaskModel>> getTasksByCreator(String userId) async {
    final snapshot = await _firestoreService.tasksCollection
        .where(FirebaseConstants.taskCreatedBy, isEqualTo: userId)
        .where(FirebaseConstants.taskIsArchived, isEqualTo: false)
        .orderBy(FirebaseConstants.taskCreatedAt, descending: true)
        .get();

    return snapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList();
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

  /// Get all active tasks (not archived)
  Future<List<TaskModel>> getActiveTasks() async {
    final snapshot = await _firestoreService.tasksCollection
        .where(FirebaseConstants.taskIsArchived, isEqualTo: false)
        .get();

    // Sort in memory instead of using Firestore orderBy (avoids index requirement)
    final tasks = snapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList();
    tasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return tasks;
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

  /// Get archived tasks
  Future<List<TaskModel>> getArchivedTasks() async {
    final snapshot = await _firestoreService.tasksCollection
        .where(FirebaseConstants.taskIsArchived, isEqualTo: true)
        .orderBy(FirebaseConstants.taskCreatedAt, descending: true)
        .get();

    return snapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList();
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

  /// Get active recurring tasks
  Future<List<TaskModel>> getActiveRecurringTasks() async {
    final snapshot = await _firestoreService.tasksCollection
        .where(FirebaseConstants.taskIsRecurring, isEqualTo: true)
        .where(FirebaseConstants.taskIsActive, isEqualTo: true)
        .where(FirebaseConstants.taskIsArchived, isEqualTo: false)
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
  }

  /// Delete task
  Future<void> deleteTask(String taskId) async {
    await _firestoreService.deleteDocument(
      _firestoreService.taskDoc(taskId),
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
