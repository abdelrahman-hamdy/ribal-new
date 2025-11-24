import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import '../../core/constants/firebase_constants.dart';
import '../../core/utils/ksa_timezone.dart';
import '../models/assignment_model.dart';
import '../services/firestore_service.dart';

/// Statistics data class
class StatisticsData {
  final int totalTasks;
  final int totalAssignments;
  final int completedAssignments;
  final int pendingAssignments;
  final int apologizedAssignments;
  final double completionRate;
  final double apologizeRate;
  final Map<String, int> assignmentsByUser;
  final Map<String, int> completionsByUser;

  const StatisticsData({
    required this.totalTasks,
    required this.totalAssignments,
    required this.completedAssignments,
    required this.pendingAssignments,
    required this.apologizedAssignments,
    required this.completionRate,
    required this.apologizeRate,
    required this.assignmentsByUser,
    required this.completionsByUser,
  });

  factory StatisticsData.empty() => const StatisticsData(
        totalTasks: 0,
        totalAssignments: 0,
        completedAssignments: 0,
        pendingAssignments: 0,
        apologizedAssignments: 0,
        completionRate: 0,
        apologizeRate: 0,
        assignmentsByUser: {},
        completionsByUser: {},
      );
}

/// User performance data
class UserPerformance {
  final String userId;
  final int totalAssignments;
  final int completedAssignments;
  final int apologizedAssignments;
  final double completionRate;

  const UserPerformance({
    required this.userId,
    required this.totalAssignments,
    required this.completedAssignments,
    required this.apologizedAssignments,
    required this.completionRate,
  });
}

/// Statistics repository for analytics
@lazySingleton
class StatisticsRepository {
  final FirestoreService _firestoreService;

  StatisticsRepository(this._firestoreService);

  /// Get statistics for date range
  Future<StatisticsData> getStatistics({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    // Get tasks created in range
    final tasksSnapshot = await _firestoreService.tasksCollection
        .where(
          FirebaseConstants.taskCreatedAt,
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
        )
        .where(
          FirebaseConstants.taskCreatedAt,
          isLessThanOrEqualTo: Timestamp.fromDate(endDate),
        )
        .get();

    final totalTasks = tasksSnapshot.docs.length;

    // Get assignments scheduled in range
    final assignmentsSnapshot = await _firestoreService.assignmentsCollection
        .where(
          FirebaseConstants.assignmentScheduledDate,
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
        )
        .where(
          FirebaseConstants.assignmentScheduledDate,
          isLessThanOrEqualTo: Timestamp.fromDate(endDate),
        )
        .get();

    final assignments = assignmentsSnapshot.docs
        .map((doc) => AssignmentModel.fromFirestore(doc))
        .toList();

    final totalAssignments = assignments.length;
    final completedAssignments =
        assignments.where((a) => a.status == AssignmentStatus.completed).length;
    final pendingAssignments =
        assignments.where((a) => a.status == AssignmentStatus.pending).length;
    final apologizedAssignments =
        assignments.where((a) => a.status == AssignmentStatus.apologized).length;

    final completionRate = totalAssignments > 0
        ? (completedAssignments / totalAssignments) * 100
        : 0.0;
    final apologizeRate = totalAssignments > 0
        ? (apologizedAssignments / totalAssignments) * 100
        : 0.0;

    // Calculate per-user statistics
    final assignmentsByUser = <String, int>{};
    final completionsByUser = <String, int>{};

    for (final assignment in assignments) {
      assignmentsByUser[assignment.userId] =
          (assignmentsByUser[assignment.userId] ?? 0) + 1;

      if (assignment.status == AssignmentStatus.completed) {
        completionsByUser[assignment.userId] =
            (completionsByUser[assignment.userId] ?? 0) + 1;
      }
    }

    return StatisticsData(
      totalTasks: totalTasks,
      totalAssignments: totalAssignments,
      completedAssignments: completedAssignments,
      pendingAssignments: pendingAssignments,
      apologizedAssignments: apologizedAssignments,
      completionRate: completionRate,
      apologizeRate: apologizeRate,
      assignmentsByUser: assignmentsByUser,
      completionsByUser: completionsByUser,
    );
  }

  /// Get today's statistics (using KSA timezone)
  Future<StatisticsData> getTodayStatistics() async {
    final startOfDay = KsaTimezone.startOfToday();
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return getStatistics(startDate: startOfDay, endDate: endOfDay);
  }

  /// Get this week's statistics (Sunday to Saturday, using KSA timezone)
  Future<StatisticsData> getWeekStatistics() async {
    final startOfWeek = KsaTimezone.startOfWeek();
    final endOfWeek = KsaTimezone.endOfWeek();

    return getStatistics(startDate: startOfWeek, endDate: endOfWeek);
  }

  /// Get this month's statistics (using KSA timezone)
  Future<StatisticsData> getMonthStatistics() async {
    final startOfMonth = KsaTimezone.startOfMonth();
    final endOfMonth = KsaTimezone.endOfMonth();

    return getStatistics(startDate: startOfMonth, endDate: endOfMonth);
  }

  /// Get user performance for date range
  Future<List<UserPerformance>> getUserPerformance({
    required DateTime startDate,
    required DateTime endDate,
    List<String>? userIds,
  }) async {
    var query = _firestoreService.assignmentsCollection
        .where(
          FirebaseConstants.assignmentScheduledDate,
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
        )
        .where(
          FirebaseConstants.assignmentScheduledDate,
          isLessThanOrEqualTo: Timestamp.fromDate(endDate),
        );

    if (userIds != null && userIds.isNotEmpty && userIds.length <= 10) {
      query = query.where(
        FirebaseConstants.assignmentUserId,
        whereIn: userIds,
      );
    }

    final snapshot = await query.get();
    final assignments = snapshot.docs
        .map((doc) => AssignmentModel.fromFirestore(doc))
        .toList();

    // Group by user
    final userMap = <String, List<AssignmentModel>>{};
    for (final assignment in assignments) {
      userMap.putIfAbsent(assignment.userId, () => []).add(assignment);
    }

    // Calculate performance
    final performances = <UserPerformance>[];
    for (final entry in userMap.entries) {
      final userAssignments = entry.value;
      final total = userAssignments.length;
      final completed = userAssignments
          .where((a) => a.status == AssignmentStatus.completed)
          .length;
      final apologized = userAssignments
          .where((a) => a.status == AssignmentStatus.apologized)
          .length;

      performances.add(UserPerformance(
        userId: entry.key,
        totalAssignments: total,
        completedAssignments: completed,
        apologizedAssignments: apologized,
        completionRate: total > 0 ? (completed / total) * 100 : 0,
      ));
    }

    // Sort by completion rate descending
    performances.sort((a, b) => b.completionRate.compareTo(a.completionRate));

    return performances;
  }

  /// Get user statistics for specific user
  Future<UserPerformance> getUserStatistics({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final performances = await getUserPerformance(
      startDate: startDate,
      endDate: endDate,
      userIds: [userId],
    );

    if (performances.isEmpty) {
      return UserPerformance(
        userId: userId,
        totalAssignments: 0,
        completedAssignments: 0,
        apologizedAssignments: 0,
        completionRate: 0,
      );
    }

    return performances.first;
  }
}
