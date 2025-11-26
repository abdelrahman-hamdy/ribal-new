part of 'today_tasks_bloc.dart';

/// Today tasks events
abstract class TodayTasksEvent extends Equatable {
  const TodayTasksEvent();

  @override
  List<Object?> get props => [];
}

/// Load today's tasks
/// If [creatorId] is provided, only tasks created by that user are loaded
class TodayTasksLoadRequested extends TodayTasksEvent {
  final String? creatorId;

  const TodayTasksLoadRequested({this.creatorId});

  @override
  List<Object?> get props => [creatorId];
}

/// Refresh today's tasks
/// If [creatorId] is provided, only tasks created by that user are loaded
class TodayTasksRefreshRequested extends TodayTasksEvent {
  final String? creatorId;

  const TodayTasksRefreshRequested({this.creatorId});

  @override
  List<Object?> get props => [creatorId];
}

/// Internal event: Settings changed, refresh tasks with new deadline
class _TodayTasksSettingsChanged extends TodayTasksEvent {
  final SettingsModel settings;

  const _TodayTasksSettingsChanged(this.settings);

  @override
  List<Object?> get props => [settings];
}
