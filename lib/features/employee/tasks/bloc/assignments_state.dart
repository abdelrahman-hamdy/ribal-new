part of 'assignments_bloc.dart';

/// Assignments state
class AssignmentsState extends Equatable {
  final String? userId;
  final List<AssignmentModel> assignments;
  final List<AssignmentModel> filteredAssignments;
  final List<AssignmentWithTask> assignmentsWithTasks;
  final List<AssignmentWithTask> filteredAssignmentsWithTasks;
  final DateTime selectedDate;
  final AssignmentStatus? filterStatus;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;
  final String? taskDeadline; // Global task deadline (e.g., "20:00")

  /// Whether the initial load has completed at least once
  /// Used to differentiate between "loading for the first time" and "empty after load"
  final bool hasLoadedOnce;

  const AssignmentsState({
    this.userId,
    this.assignments = const [],
    this.filteredAssignments = const [],
    this.assignmentsWithTasks = const [],
    this.filteredAssignmentsWithTasks = const [],
    required this.selectedDate,
    this.filterStatus,
    this.isLoading = true, // Start in loading state
    this.errorMessage,
    this.successMessage,
    this.taskDeadline,
    this.hasLoadedOnce = false,
  });

  factory AssignmentsState.initial() => AssignmentsState(
        selectedDate: KsaTimezone.today(),
        isLoading: true,
        hasLoadedOnce: false,
      );

  AssignmentsState copyWith({
    String? userId,
    List<AssignmentModel>? assignments,
    List<AssignmentModel>? filteredAssignments,
    List<AssignmentWithTask>? assignmentsWithTasks,
    List<AssignmentWithTask>? filteredAssignmentsWithTasks,
    DateTime? selectedDate,
    AssignmentStatus? filterStatus,
    bool clearFilterStatus = false,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    String? successMessage,
    bool clearSuccess = false,
    String? taskDeadline,
    bool? hasLoadedOnce,
  }) {
    return AssignmentsState(
      userId: userId ?? this.userId,
      assignments: assignments ?? this.assignments,
      filteredAssignments: filteredAssignments ?? this.filteredAssignments,
      assignmentsWithTasks: assignmentsWithTasks ?? this.assignmentsWithTasks,
      filteredAssignmentsWithTasks:
          filteredAssignmentsWithTasks ?? this.filteredAssignmentsWithTasks,
      selectedDate: selectedDate ?? this.selectedDate,
      filterStatus: clearFilterStatus ? null : (filterStatus ?? this.filterStatus),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
      taskDeadline: taskDeadline ?? this.taskDeadline,
      hasLoadedOnce: hasLoadedOnce ?? this.hasLoadedOnce,
    );
  }

  @override
  List<Object?> get props => [
        userId,
        assignments,
        filteredAssignments,
        assignmentsWithTasks,
        filteredAssignmentsWithTasks,
        selectedDate,
        filterStatus,
        isLoading,
        errorMessage,
        successMessage,
        taskDeadline,
        hasLoadedOnce,
      ];

  /// Get pending assignments count
  int get pendingCount =>
      assignments.where((a) => a.status == AssignmentStatus.pending).length;

  /// Get completed assignments count
  int get completedCount =>
      assignments.where((a) => a.status == AssignmentStatus.completed).length;

  /// Get apologized assignments count
  int get apologizedCount =>
      assignments.where((a) => a.status == AssignmentStatus.apologized).length;

  /// Get completion rate
  double get completionRate {
    if (assignments.isEmpty) return 0;
    return completedCount / assignments.length;
  }

  /// Get assignment by ID
  AssignmentModel? getAssignmentById(String id) {
    try {
      return assignments.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Check if current time is past the deadline (for today)
  bool get isDeadlinePassed {
    if (taskDeadline == null) return false;
    try {
      final now = KsaTimezone.now();
      final today = KsaTimezone.today();
      // Only check deadline for today's tasks
      final isSameDay = selectedDate.year == today.year &&
          selectedDate.month == today.month &&
          selectedDate.day == today.day;
      if (!isSameDay) return false;

      final parts = taskDeadline!.split(':');
      final deadlineDateTime = today.add(Duration(
        hours: int.parse(parts[0]),
        minutes: int.parse(parts[1]),
      ));
      return now.isAfter(deadlineDateTime);
    } catch (_) {
      return false;
    }
  }

  /// Get formatted deadline text (e.g., "20:00")
  String? get formattedDeadline => taskDeadline;
}
