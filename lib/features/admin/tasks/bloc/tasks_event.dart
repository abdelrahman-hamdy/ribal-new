part of 'tasks_bloc.dart';

/// Tasks events
abstract class TasksEvent extends Equatable {
  const TasksEvent();

  @override
  List<Object?> get props => [];
}

/// Load active tasks
class TasksLoadRequested extends TasksEvent {
  const TasksLoadRequested();
}

/// Load archived tasks
class TasksLoadArchivedRequested extends TasksEvent {
  const TasksLoadArchivedRequested();
}

/// Create new task
class TaskCreateRequested extends TasksEvent {
  final String title;
  final String description;
  final List<String> labelIds;
  final String? attachmentUrl;
  final bool isRecurring;
  final bool attachmentRequired;
  final AssigneeSelection assigneeSelection;
  final List<String> selectedGroupIds;
  final List<String> selectedUserIds;
  final String createdBy;

  const TaskCreateRequested({
    required this.title,
    required this.description,
    this.labelIds = const [],
    this.attachmentUrl,
    this.isRecurring = false,
    this.attachmentRequired = false,
    required this.assigneeSelection,
    this.selectedGroupIds = const [],
    this.selectedUserIds = const [],
    required this.createdBy,
  });

  @override
  List<Object?> get props => [
        title,
        description,
        labelIds,
        attachmentUrl,
        isRecurring,
        attachmentRequired,
        assigneeSelection,
        selectedGroupIds,
        selectedUserIds,
        createdBy,
      ];
}

/// Update task
class TaskUpdateRequested extends TasksEvent {
  final TaskModel task;

  const TaskUpdateRequested({required this.task});

  @override
  List<Object?> get props => [task];
}

/// Archive task
class TaskArchiveRequested extends TasksEvent {
  final String taskId;

  const TaskArchiveRequested({required this.taskId});

  @override
  List<Object?> get props => [taskId];
}

/// Restore task from archive
class TaskRestoreRequested extends TasksEvent {
  final String taskId;

  const TaskRestoreRequested({required this.taskId});

  @override
  List<Object?> get props => [taskId];
}

/// Delete task
class TaskDeleteRequested extends TasksEvent {
  final String taskId;

  const TaskDeleteRequested({required this.taskId});

  @override
  List<Object?> get props => [taskId];
}

/// Toggle recurring task active status
class TaskToggleRecurringRequested extends TasksEvent {
  final String taskId;
  final bool isActive;

  const TaskToggleRecurringRequested({
    required this.taskId,
    required this.isActive,
  });

  @override
  List<Object?> get props => [taskId, isActive];
}

/// Search tasks
class TasksSearchRequested extends TasksEvent {
  final String query;

  const TasksSearchRequested({required this.query});

  @override
  List<Object?> get props => [query];
}

/// Clear search
class TasksSearchCleared extends TasksEvent {
  const TasksSearchCleared();
}

/// Filter tasks
class TasksFilterChanged extends TasksEvent {
  final bool? filterRecurring;

  const TasksFilterChanged({this.filterRecurring});

  @override
  List<Object?> get props => [filterRecurring];
}

/// Publish archived task as recurring
class TaskPublishAsRecurringRequested extends TasksEvent {
  final String taskId;

  const TaskPublishAsRecurringRequested({required this.taskId});

  @override
  List<Object?> get props => [taskId];
}

/// Publish archived task for today only
class TaskPublishForTodayRequested extends TasksEvent {
  final String taskId;

  const TaskPublishForTodayRequested({required this.taskId});

  @override
  List<Object?> get props => [taskId];
}
