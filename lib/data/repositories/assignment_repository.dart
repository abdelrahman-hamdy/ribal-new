import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import '../../core/constants/firebase_constants.dart';
import '../models/assignment_model.dart';
import '../services/firestore_service.dart';

/// Assignment repository for CRUD operations
@lazySingleton
class AssignmentRepository {
  final FirestoreService _firestoreService;

  AssignmentRepository(this._firestoreService);

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

  /// Get assignment by ID
  Future<AssignmentModel?> getAssignmentById(String assignmentId) async {
    final doc = await _firestoreService.assignmentDoc(assignmentId).get();
    if (!doc.exists) return null;
    return AssignmentModel.fromFirestore(doc);
  }

  /// Stream assignment by ID
  Stream<AssignmentModel?> streamAssignment(String assignmentId) {
    return _firestoreService
        .streamDocument(_firestoreService.assignmentDoc(assignmentId))
        .map((doc) => doc.exists ? AssignmentModel.fromFirestore(doc) : null);
  }

  /// Get assignments for user on specific date
  Future<List<AssignmentModel>> getAssignmentsForUserOnDate({
    required String userId,
    required DateTime date,
  }) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

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
        .get();

    return snapshot.docs
        .map((doc) => AssignmentModel.fromFirestore(doc))
        .toList();
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

  /// Get assignments for task on specific date
  Future<List<AssignmentModel>> getAssignmentsForTaskOnDate({
    required String taskId,
    required DateTime date,
  }) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

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
        .get();

    return snapshot.docs
        .map((doc) => AssignmentModel.fromFirestore(doc))
        .toList();
  }

  /// Mark assignment as completed
  Future<void> markAsCompleted({
    required String assignmentId,
    required String markedDoneBy,
    String? attachmentUrl,
  }) async {
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
  }

  /// Mark assignment as apologized
  Future<void> markAsApologized({
    required String assignmentId,
    String? message,
  }) async {
    await _firestoreService.updateDocument(
      _firestoreService.assignmentDoc(assignmentId),
      {
        FirebaseConstants.assignmentStatus: AssignmentStatus.apologized.name,
        FirebaseConstants.assignmentApologizedAt: FieldValue.serverTimestamp(),
        FirebaseConstants.assignmentApologizeMessage: message,
      },
    );
  }

  /// Reactivate assignment (back to pending)
  Future<void> reactivateAssignment(String assignmentId) async {
    await _firestoreService.updateDocument(
      _firestoreService.assignmentDoc(assignmentId),
      {
        FirebaseConstants.assignmentStatus: AssignmentStatus.pending.name,
        FirebaseConstants.assignmentApologizedAt: null,
        FirebaseConstants.assignmentApologizeMessage: null,
      },
    );
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
    };

    for (final assignment in assignments) {
      counts[assignment.status] = (counts[assignment.status] ?? 0) + 1;
    }

    return counts;
  }
}
