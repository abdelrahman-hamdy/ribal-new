part of 'assignments_bloc.dart';

/// Assignments events
abstract class AssignmentsEvent extends Equatable {
  const AssignmentsEvent();

  @override
  List<Object?> get props => [];
}

/// Load assignments for user
class AssignmentsLoadRequested extends AssignmentsEvent {
  final String userId;

  const AssignmentsLoadRequested({required this.userId});

  @override
  List<Object?> get props => [userId];
}

/// Internal event when stream emits new assignments data
class _AssignmentsStreamUpdated extends AssignmentsEvent {
  final String userId;
  final List<AssignmentWithTask> assignmentsWithTasks;
  final String? taskDeadline;

  const _AssignmentsStreamUpdated({
    required this.userId,
    required this.assignmentsWithTasks,
    this.taskDeadline,
  });

  @override
  List<Object?> get props => [userId, assignmentsWithTasks, taskDeadline];
}

/// Internal event when stream encounters an error
class _AssignmentsStreamError extends AssignmentsEvent {
  final String errorMessage;

  const _AssignmentsStreamError({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}

/// Mark assignment as completed
class AssignmentMarkCompletedRequested extends AssignmentsEvent {
  final String assignmentId;
  final String markedDoneBy;

  const AssignmentMarkCompletedRequested({
    required this.assignmentId,
    required this.markedDoneBy,
  });

  @override
  List<Object?> get props => [assignmentId, markedDoneBy];
}

/// Apologize for assignment
class AssignmentApologizeRequested extends AssignmentsEvent {
  final String assignmentId;
  final String? message;

  const AssignmentApologizeRequested({
    required this.assignmentId,
    this.message,
  });

  @override
  List<Object?> get props => [assignmentId, message];
}

/// Reactivate apologized assignment
class AssignmentReactivateRequested extends AssignmentsEvent {
  final String assignmentId;

  const AssignmentReactivateRequested({required this.assignmentId});

  @override
  List<Object?> get props => [assignmentId];
}

/// Change selected date
class AssignmentsDateChanged extends AssignmentsEvent {
  final DateTime date;

  const AssignmentsDateChanged({required this.date});

  @override
  List<Object?> get props => [date];
}

/// Filter assignments by status
class AssignmentsFilterChanged extends AssignmentsEvent {
  final AssignmentStatus? status;

  const AssignmentsFilterChanged({this.status});

  @override
  List<Object?> get props => [status];
}
