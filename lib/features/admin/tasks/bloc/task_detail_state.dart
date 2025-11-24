part of 'task_detail_bloc.dart';

/// Task detail state
class TaskDetailState extends Equatable {
  final String? taskId;
  final TaskModel? task;
  final List<LabelModel> labels;
  final UserModel? creator;
  final List<AssigneeWithUser> assignees;
  final bool isLoading;
  final bool isAssigneesLoading;
  final String? loadingAssignmentId;
  final String? errorMessage;
  final String? successMessage;
  final bool isDeleted;
  final bool isArchived;

  const TaskDetailState({
    this.taskId,
    this.task,
    required this.labels,
    this.creator,
    required this.assignees,
    required this.isLoading,
    this.isAssigneesLoading = true,
    this.loadingAssignmentId,
    this.errorMessage,
    this.successMessage,
    this.isDeleted = false,
    this.isArchived = false,
  });

  factory TaskDetailState.initial() {
    return const TaskDetailState(
      labels: [],
      assignees: [],
      isLoading: false,
      isAssigneesLoading: true,
    );
  }

  /// Pending assignments count
  int get pendingCount =>
      assignees.where((a) => a.assignment.status == AssignmentStatus.pending).length;

  /// Completed assignments count
  int get completedCount =>
      assignees.where((a) => a.assignment.status == AssignmentStatus.completed).length;

  /// Apologized assignments count
  int get apologizedCount =>
      assignees.where((a) => a.assignment.status == AssignmentStatus.apologized).length;

  TaskDetailState copyWith({
    String? taskId,
    TaskModel? task,
    List<LabelModel>? labels,
    UserModel? creator,
    List<AssigneeWithUser>? assignees,
    bool? isLoading,
    bool? isAssigneesLoading,
    String? loadingAssignmentId,
    String? errorMessage,
    String? successMessage,
    bool? isDeleted,
    bool? isArchived,
    bool clearError = false,
    bool clearSuccess = false,
    bool clearLoadingAssignment = false,
  }) {
    return TaskDetailState(
      taskId: taskId ?? this.taskId,
      task: task ?? this.task,
      labels: labels ?? this.labels,
      creator: creator ?? this.creator,
      assignees: assignees ?? this.assignees,
      isLoading: isLoading ?? this.isLoading,
      isAssigneesLoading: isAssigneesLoading ?? this.isAssigneesLoading,
      loadingAssignmentId: clearLoadingAssignment ? null : (loadingAssignmentId ?? this.loadingAssignmentId),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
      isDeleted: isDeleted ?? this.isDeleted,
      isArchived: isArchived ?? this.isArchived,
    );
  }

  @override
  List<Object?> get props => [
        taskId,
        task,
        labels,
        creator,
        assignees,
        isLoading,
        isAssigneesLoading,
        loadingAssignmentId,
        errorMessage,
        successMessage,
        isDeleted,
        isArchived,
      ];
}
