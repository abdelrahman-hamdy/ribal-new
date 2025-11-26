import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import '../../core/constants/firebase_constants.dart';
import '../../core/services/hive_cache_service.dart';
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
  final int overdueAssignments;
  final double completionRate;
  final double apologizeRate;
  final double overdueRate;
  final Map<String, int> assignmentsByUser;
  final Map<String, int> completionsByUser;

  const StatisticsData({
    required this.totalTasks,
    required this.totalAssignments,
    required this.completedAssignments,
    required this.pendingAssignments,
    required this.apologizedAssignments,
    required this.overdueAssignments,
    required this.completionRate,
    required this.apologizeRate,
    required this.overdueRate,
    required this.assignmentsByUser,
    required this.completionsByUser,
  });

  /// Combined "failed" count (apologized + overdue)
  int get failedAssignments => apologizedAssignments + overdueAssignments;

  /// Combined "failed" rate
  double get failedRate => apologizeRate + overdueRate;

  factory StatisticsData.empty() => const StatisticsData(
        totalTasks: 0,
        totalAssignments: 0,
        completedAssignments: 0,
        pendingAssignments: 0,
        apologizedAssignments: 0,
        overdueAssignments: 0,
        completionRate: 0,
        apologizeRate: 0,
        overdueRate: 0,
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
  final int overdueAssignments;
  final double completionRate;

  const UserPerformance({
    required this.userId,
    required this.totalAssignments,
    required this.completedAssignments,
    required this.apologizedAssignments,
    required this.overdueAssignments,
    required this.completionRate,
  });

  /// Combined "failed" count (apologized + overdue)
  int get failedAssignments => apologizedAssignments + overdueAssignments;
}

/// Statistics repository for analytics
@lazySingleton
class StatisticsRepository {
  final FirestoreService _firestoreService;
  final HiveCacheService _cacheService;

  StatisticsRepository(this._firestoreService, this._cacheService);

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
    final overdueAssignments =
        assignments.where((a) => a.status == AssignmentStatus.overdue).length;

    final completionRate = totalAssignments > 0
        ? (completedAssignments / totalAssignments) * 100
        : 0.0;
    final apologizeRate = totalAssignments > 0
        ? (apologizedAssignments / totalAssignments) * 100
        : 0.0;
    final overdueRate = totalAssignments > 0
        ? (overdueAssignments / totalAssignments) * 100
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
      overdueAssignments: overdueAssignments,
      completionRate: completionRate,
      apologizeRate: apologizeRate,
      overdueRate: overdueRate,
      assignmentsByUser: assignmentsByUser,
      completionsByUser: completionsByUser,
    );
  }

  /// Get today's statistics (using KSA timezone) with caching
  Future<StatisticsData> getTodayStatistics() async {
    const cacheKey = 'statistics_today';

    // Try cache first (using tasks box for statistics)
    final cachedJson = await _cacheService.get<Map<String, dynamic>>(
      boxName: HiveCacheService.boxTasks,
      key: cacheKey,
      ttl: HiveCacheService.ttlShort, // 5 min TTL for frequently changing data
    );

    if (cachedJson != null) {
      return _statisticsDataFromJson(cachedJson);
    }

    // Fetch from Firebase if cache miss
    final startOfDay = KsaTimezone.startOfToday();
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final stats = await getStatistics(startDate: startOfDay, endDate: endOfDay);

    // Cache the result
    await _cacheService.put(
      boxName: HiveCacheService.boxTasks,
      key: cacheKey,
      value: _statisticsDataToJson(stats),
    );

    return stats;
  }

  /// Get this week's statistics (Sunday to Saturday, using KSA timezone) with caching
  Future<StatisticsData> getWeekStatistics() async {
    const cacheKey = 'statistics_week';

    // Try cache first (using tasks box for statistics)
    final cachedJson = await _cacheService.get<Map<String, dynamic>>(
      boxName: HiveCacheService.boxTasks,
      key: cacheKey,
      ttl: HiveCacheService.ttlMedium, // 30 min TTL
    );

    if (cachedJson != null) {
      return _statisticsDataFromJson(cachedJson);
    }

    // Fetch from Firebase if cache miss
    final startOfWeek = KsaTimezone.startOfWeek();
    final endOfWeek = KsaTimezone.endOfWeek();

    final stats = await getStatistics(startDate: startOfWeek, endDate: endOfWeek);

    // Cache the result
    await _cacheService.put(
      boxName: HiveCacheService.boxTasks,
      key: cacheKey,
      value: _statisticsDataToJson(stats),
    );

    return stats;
  }

  /// Get this month's statistics (using KSA timezone) with caching
  Future<StatisticsData> getMonthStatistics() async {
    const cacheKey = 'statistics_month';

    // Try cache first (using tasks box for statistics)
    final cachedJson = await _cacheService.get<Map<String, dynamic>>(
      boxName: HiveCacheService.boxTasks,
      key: cacheKey,
      ttl: HiveCacheService.ttlMedium, // 30 min TTL
    );

    if (cachedJson != null) {
      return _statisticsDataFromJson(cachedJson);
    }

    // Fetch from Firebase if cache miss
    final startOfMonth = KsaTimezone.startOfMonth();
    final endOfMonth = KsaTimezone.endOfMonth();

    final stats = await getStatistics(startDate: startOfMonth, endDate: endOfMonth);

    // Cache the result
    await _cacheService.put(
      boxName: HiveCacheService.boxTasks,
      key: cacheKey,
      value: _statisticsDataToJson(stats),
    );

    return stats;
  }

  /// Helper: Convert StatisticsData to JSON for caching
  Map<String, dynamic> _statisticsDataToJson(StatisticsData stats) {
    return {
      'totalTasks': stats.totalTasks,
      'totalAssignments': stats.totalAssignments,
      'completedAssignments': stats.completedAssignments,
      'pendingAssignments': stats.pendingAssignments,
      'apologizedAssignments': stats.apologizedAssignments,
      'overdueAssignments': stats.overdueAssignments,
      'completionRate': stats.completionRate,
      'apologizeRate': stats.apologizeRate,
      'overdueRate': stats.overdueRate,
      'assignmentsByUser': stats.assignmentsByUser,
      'completionsByUser': stats.completionsByUser,
    };
  }

  /// Helper: Convert JSON to StatisticsData for caching
  StatisticsData _statisticsDataFromJson(Map<String, dynamic> json) {
    return StatisticsData(
      totalTasks: json['totalTasks'] as int,
      totalAssignments: json['totalAssignments'] as int,
      completedAssignments: json['completedAssignments'] as int,
      pendingAssignments: json['pendingAssignments'] as int,
      apologizedAssignments: json['apologizedAssignments'] as int,
      overdueAssignments: (json['overdueAssignments'] as int?) ?? 0,
      completionRate: (json['completionRate'] as num).toDouble(),
      apologizeRate: (json['apologizeRate'] as num).toDouble(),
      overdueRate: (json['overdueRate'] as num?)?.toDouble() ?? 0.0,
      assignmentsByUser: Map<String, int>.from(json['assignmentsByUser'] as Map),
      completionsByUser: Map<String, int>.from(json['completionsByUser'] as Map),
    );
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
      final overdue = userAssignments
          .where((a) => a.status == AssignmentStatus.overdue)
          .length;

      performances.add(UserPerformance(
        userId: entry.key,
        totalAssignments: total,
        completedAssignments: completed,
        apologizedAssignments: apologized,
        overdueAssignments: overdue,
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
        overdueAssignments: 0,
        completionRate: 0,
      );
    }

    return performances.first;
  }
}
