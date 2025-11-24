part of 'task_detail_bloc.dart';

/// Task detail events
abstract class TaskDetailEvent extends Equatable {
  const TaskDetailEvent();

  @override
  List<Object?> get props => [];
}

/// Load task details
class TaskDetailLoadRequested extends TaskDetailEvent {
  final String taskId;

  const TaskDetailLoadRequested({required this.taskId});

  @override
  List<Object?> get props => [taskId];
}

/// Mark assignment as done
class TaskDetailMarkAsDoneRequested extends TaskDetailEvent {
  final String assignmentId;
  final String markedDoneBy;

  const TaskDetailMarkAsDoneRequested({
    required this.assignmentId,
    required this.markedDoneBy,
  });

  @override
  List<Object?> get props => [assignmentId, markedDoneBy];
}

/// Internal: Task data received
class _TaskDataReceived extends TaskDetailEvent {
  final TaskModel task;
  final List<LabelModel> labels;
  final UserModel? creator;

  const _TaskDataReceived({
    required this.task,
    required this.labels,
    this.creator,
  });

  @override
  List<Object?> get props => [task, labels, creator];
}

/// Internal: Assignments data received
class _AssignmentsDataReceived extends TaskDetailEvent {
  final List<AssigneeWithUser> assignees;

  const _AssignmentsDataReceived({required this.assignees});

  @override
  List<Object?> get props => [assignees];
}

/// Refresh task details
class TaskDetailRefreshRequested extends TaskDetailEvent {
  const TaskDetailRefreshRequested();
}

/// Internal: Error received
class _TaskErrorReceived extends TaskDetailEvent {
  final String message;

  const _TaskErrorReceived({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Delete task
class TaskDetailDeleteRequested extends TaskDetailEvent {
  final String taskId;

  const TaskDetailDeleteRequested({required this.taskId});

  @override
  List<Object?> get props => [taskId];
}

/// Archive task (stop recurring task)
class TaskDetailArchiveRequested extends TaskDetailEvent {
  final String taskId;

  const TaskDetailArchiveRequested({required this.taskId});

  @override
  List<Object?> get props => [taskId];
}
