import 'assignment_model.dart';

/// Task-level status (derived from assignments)
/// This is different from AssignmentStatus which is per-user
enum TaskStatus {
  /// No assignments exist for this task (on this date)
  noAssignments,

  /// 0% completed - all assignments are pending
  notStarted,

  /// Some completed, some still pending (1-99%)
  inProgress,

  /// 100% completed - all assignments are done
  completed,

  /// Some completed, rest apologized (no pending left)
  partiallyDone,
}

/// Extension methods for TaskStatus
extension TaskStatusX on TaskStatus {
  String get name {
    switch (this) {
      case TaskStatus.noAssignments:
        return 'no_assignments';
      case TaskStatus.notStarted:
        return 'not_started';
      case TaskStatus.inProgress:
        return 'in_progress';
      case TaskStatus.completed:
        return 'completed';
      case TaskStatus.partiallyDone:
        return 'partially_done';
    }
  }

  String get displayNameAr {
    switch (this) {
      case TaskStatus.noAssignments:
        return 'لا توجد تكليفات';
      case TaskStatus.notStarted:
        return 'لم تبدأ';
      case TaskStatus.inProgress:
        return 'جاري التنفيذ';
      case TaskStatus.completed:
        return 'مكتملة';
      case TaskStatus.partiallyDone:
        return 'مكتملة جزئياً';
    }
  }

  /// Short label for compact display
  String get shortLabelAr {
    switch (this) {
      case TaskStatus.noAssignments:
        return 'لا تكليفات';
      case TaskStatus.notStarted:
        return 'لم تبدأ';
      case TaskStatus.inProgress:
        return 'جاري';
      case TaskStatus.completed:
        return 'مكتملة';
      case TaskStatus.partiallyDone:
        return 'جزئية';
    }
  }

  bool get isCompleted => this == TaskStatus.completed;
  bool get isInProgress => this == TaskStatus.inProgress;
  bool get isNotStarted => this == TaskStatus.notStarted;
  bool get isPartiallyDone => this == TaskStatus.partiallyDone;
  bool get hasNoAssignments => this == TaskStatus.noAssignments;
}

/// Represents the progress of a task across all its assignments
class TaskProgress {
  final int totalAssignments;
  final int completedCount;
  final int pendingCount;
  final int apologizedCount;

  const TaskProgress({
    required this.totalAssignments,
    required this.completedCount,
    required this.pendingCount,
    required this.apologizedCount,
  });

  /// Create from a list of assignments
  factory TaskProgress.fromAssignments(List<AssignmentModel> assignments) {
    if (assignments.isEmpty) {
      return const TaskProgress(
        totalAssignments: 0,
        completedCount: 0,
        pendingCount: 0,
        apologizedCount: 0,
      );
    }

    return TaskProgress(
      totalAssignments: assignments.length,
      completedCount:
          assignments.where((a) => a.status == AssignmentStatus.completed).length,
      pendingCount:
          assignments.where((a) => a.status == AssignmentStatus.pending).length,
      apologizedCount:
          assignments.where((a) => a.status == AssignmentStatus.apologized).length,
    );
  }

  /// Empty progress (no assignments)
  static const TaskProgress empty = TaskProgress(
    totalAssignments: 0,
    completedCount: 0,
    pendingCount: 0,
    apologizedCount: 0,
  );

  /// Completion rate as a decimal (0.0 - 1.0)
  double get completionRate {
    if (totalAssignments == 0) return 0;
    return completedCount / totalAssignments;
  }

  /// Completion percentage (0 - 100)
  int get completionPercentage => (completionRate * 100).round();

  /// Derive the task-level status from assignment stats
  TaskStatus get status {
    if (totalAssignments == 0) return TaskStatus.noAssignments;
    if (completedCount == totalAssignments) return TaskStatus.completed;
    if (completedCount == 0 && apologizedCount == 0) return TaskStatus.notStarted;
    if (pendingCount == 0 && completedCount > 0) return TaskStatus.partiallyDone;
    return TaskStatus.inProgress;
  }

  /// Whether there are any pending assignments
  bool get hasPending => pendingCount > 0;

  /// Whether all assignments are completed
  bool get isFullyCompleted => completedCount == totalAssignments && totalAssignments > 0;

  /// Whether all assignments are apologized
  bool get isFullyApologized =>
      apologizedCount == totalAssignments && totalAssignments > 0;

  /// Progress text for display (e.g., "5/10 مكتمل")
  String get progressTextAr {
    if (totalAssignments == 0) return 'لا توجد تكليفات';
    return '$completedCount/$totalAssignments مكتمل';
  }

  /// Detailed breakdown text
  String get breakdownTextAr {
    final parts = <String>[];
    if (completedCount > 0) parts.add('$completedCount مكتمل');
    if (pendingCount > 0) parts.add('$pendingCount قيد الانتظار');
    if (apologizedCount > 0) parts.add('$apologizedCount معتذر');
    return parts.join(' • ');
  }

  @override
  String toString() {
    return 'TaskProgress(total: $totalAssignments, completed: $completedCount, '
        'pending: $pendingCount, apologized: $apologizedCount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TaskProgress &&
        other.totalAssignments == totalAssignments &&
        other.completedCount == completedCount &&
        other.pendingCount == pendingCount &&
        other.apologizedCount == apologizedCount;
  }

  @override
  int get hashCode {
    return Object.hash(
      totalAssignments,
      completedCount,
      pendingCount,
      apologizedCount,
    );
  }
}
