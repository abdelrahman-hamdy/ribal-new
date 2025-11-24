part of 'today_tasks_bloc.dart';

/// Today tasks state
class TodayTasksState extends Equatable {
  final List<TaskWithDetails> tasks;
  final bool isLoading;
  final String? errorMessage;

  const TodayTasksState({
    required this.tasks,
    required this.isLoading,
    this.errorMessage,
  });

  factory TodayTasksState.initial() {
    return const TodayTasksState(
      tasks: [],
      isLoading: false,
    );
  }

  // ============================================
  // ASSIGNMENT-LEVEL STATS (across all tasks)
  // ============================================

  /// Total pending assignments count (not overdue)
  int get totalPendingCount => tasks.fold(0, (sum, t) => sum + t.pendingCount);

  /// Total completed assignments count
  int get totalCompletedCount => tasks.fold(0, (sum, t) => sum + t.completedCount);

  /// Total apologized assignments count
  int get totalApologizedCount => tasks.fold(0, (sum, t) => sum + t.apologizedCount);

  /// Total overdue assignments count
  int get totalOverdueCount => tasks.fold(0, (sum, t) => sum + t.overdueCount);

  /// Total assignments for today
  int get totalAssignmentsCount => tasks.fold(0, (sum, t) => sum + t.totalAssignments);

  // ============================================
  // TASK-LEVEL STATS (task status breakdown)
  // ============================================

  /// Number of tasks with 100% completion
  int get completedTasksCount =>
      tasks.where((t) => t.status == TaskStatus.completed).length;

  /// Number of tasks in progress (some completed, some pending)
  int get inProgressTasksCount =>
      tasks.where((t) => t.status == TaskStatus.inProgress).length;

  /// Number of tasks not started (all pending)
  int get notStartedTasksCount =>
      tasks.where((t) => t.status == TaskStatus.notStarted).length;

  /// Number of tasks partially done (some completed, rest apologized)
  int get partiallyDoneTasksCount =>
      tasks.where((t) => t.status == TaskStatus.partiallyDone).length;

  /// Total tasks count
  int get totalTasksCount => tasks.length;

  TodayTasksState copyWith({
    List<TaskWithDetails>? tasks,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return TodayTasksState(
      tasks: tasks ?? this.tasks,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [tasks, isLoading, errorMessage];
}
