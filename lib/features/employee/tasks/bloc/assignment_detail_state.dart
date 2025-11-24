part of 'assignment_detail_bloc.dart';

class AssignmentDetailState extends Equatable {
  final bool isLoading;
  final bool isActionLoading;
  final AssignmentModel? assignment;
  final TaskModel? task;
  final List<LabelModel> labels;
  final UserModel? creator;
  final String? errorMessage;
  final String? successMessage;
  final String? taskDeadline;

  const AssignmentDetailState({
    this.isLoading = false,
    this.isActionLoading = false,
    this.assignment,
    this.task,
    this.labels = const [],
    this.creator,
    this.errorMessage,
    this.successMessage,
    this.taskDeadline,
  });

  factory AssignmentDetailState.initial() => const AssignmentDetailState();

  AssignmentDetailState copyWith({
    bool? isLoading,
    bool? isActionLoading,
    AssignmentModel? assignment,
    TaskModel? task,
    List<LabelModel>? labels,
    UserModel? creator,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
    String? taskDeadline,
  }) {
    return AssignmentDetailState(
      isLoading: isLoading ?? this.isLoading,
      isActionLoading: isActionLoading ?? this.isActionLoading,
      assignment: assignment ?? this.assignment,
      task: task ?? this.task,
      labels: labels ?? this.labels,
      creator: creator ?? this.creator,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
      taskDeadline: taskDeadline ?? this.taskDeadline,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        isActionLoading,
        assignment,
        task,
        labels,
        creator,
        errorMessage,
        successMessage,
        taskDeadline,
      ];
}
