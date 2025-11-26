import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../utils/ksa_timezone.dart';
import '../../../../../data/models/assignment_model.dart';
import '../../../../../data/models/label_model.dart';
import '../../../../../data/models/settings_model.dart';
import '../../../../../data/models/task_model.dart';
import '../../../../../data/models/task_progress.dart';
import '../../../../../data/models/user_model.dart';
import '../../../../../data/repositories/assignment_repository.dart';
import '../../../../../data/repositories/label_repository.dart';
import '../../../../../data/repositories/settings_repository.dart';
import '../../../../../data/repositories/task_repository.dart';
import '../../../../../data/repositories/user_repository.dart';

part 'today_tasks_event.dart';
part 'today_tasks_state.dart';

/// Data class for a task with all its related info
class TaskWithDetails {
  final TaskModel task;
  final List<LabelModel> labels;
  final UserModel? creator;
  final List<AssignmentModel> todayAssignments;
  final DateTime? deadline;

  const TaskWithDetails({
    required this.task,
    required this.labels,
    this.creator,
    required this.todayAssignments,
    this.deadline,
  });

  /// Get task progress from today's assignments (with deadline for overdue calc)
  TaskProgress get progress =>
      TaskProgress.fromAssignments(todayAssignments, deadline: deadline);

  /// Get derived task status
  TaskStatus get status => progress.status;

  /// Count of pending assignments (not overdue)
  int get pendingCount => progress.pendingCount;

  /// Count of completed assignments
  int get completedCount => progress.completedCount;

  /// Count of apologized assignments
  int get apologizedCount => progress.apologizedCount;

  /// Count of overdue assignments (status=overdue + pending past deadline)
  int get overdueCount => progress.overdueCount;

  /// Total assignments count
  int get totalAssignments => progress.totalAssignments;
}

@injectable
class TodayTasksBloc extends Bloc<TodayTasksEvent, TodayTasksState> {
  final TaskRepository _taskRepository;
  final AssignmentRepository _assignmentRepository;
  final LabelRepository _labelRepository;
  final UserRepository _userRepository;
  final SettingsRepository _settingsRepository;

  StreamSubscription<SettingsModel>? _settingsSubscription;
  String? _currentCreatorId;
  SettingsModel? _lastSettings;

  TodayTasksBloc(
    this._taskRepository,
    this._assignmentRepository,
    this._labelRepository,
    this._userRepository,
    this._settingsRepository,
  ) : super(TodayTasksState.initial()) {
    on<TodayTasksLoadRequested>(_onLoadRequested);
    on<TodayTasksRefreshRequested>(_onRefreshRequested);
    on<_TodayTasksSettingsChanged>(_onSettingsChanged);

    // Listen to settings changes and refresh tasks when times change
    _settingsSubscription = _settingsRepository.streamSettings().listen(
      (settings) {
        // Only refresh if settings actually changed and we have loaded once
        if (_lastSettings != null &&
            state.hasLoadedOnce &&
            (_lastSettings!.recurringTaskTime != settings.recurringTaskTime ||
                _lastSettings!.taskDeadline != settings.taskDeadline)) {
          debugPrint('[TodayTasksBloc] ⚙️ Settings changed, refreshing tasks...');
          if (!isClosed) {
            add(_TodayTasksSettingsChanged(settings));
          }
        }
        _lastSettings = settings;
      },
    );
  }

  @override
  Future<void> close() {
    _settingsSubscription?.cancel();
    return super.close();
  }

  Future<void> _onLoadRequested(
    TodayTasksLoadRequested event,
    Emitter<TodayTasksState> emit,
  ) async {
    // Store creatorId for settings-triggered refreshes
    _currentCreatorId = event.creatorId;
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      final tasks = await _loadTodayTasks(creatorId: event.creatorId);
      emit(state.copyWith(
        tasks: tasks,
        isLoading: false,
        hasLoadedOnce: true,
      ));
    } catch (e, stackTrace) {
      // Log the actual error for debugging
      debugPrint('[TodayTasksBloc] Error loading tasks: $e');
      debugPrint('[TodayTasksBloc] Stack trace: $stackTrace');
      emit(state.copyWith(
        isLoading: false,
        hasLoadedOnce: true,
        errorMessage: 'فشل في تحميل مهام اليوم',
      ));
    }
  }

  Future<void> _onSettingsChanged(
    _TodayTasksSettingsChanged event,
    Emitter<TodayTasksState> emit,
  ) async {
    // Refresh tasks with the new settings (new deadline)
    try {
      final tasks = await _loadTodayTasks(creatorId: _currentCreatorId);
      emit(state.copyWith(tasks: tasks));
      debugPrint('[TodayTasksBloc] ✅ Tasks refreshed after settings change');
    } catch (e, stackTrace) {
      debugPrint('[TodayTasksBloc] Error refreshing after settings change: $e');
      debugPrint('[TodayTasksBloc] Stack trace: $stackTrace');
    }
  }

  Future<void> _onRefreshRequested(
    TodayTasksRefreshRequested event,
    Emitter<TodayTasksState> emit,
  ) async {
    try {
      final tasks = await _loadTodayTasks(creatorId: event.creatorId);
      emit(state.copyWith(tasks: tasks));
    } catch (e, stackTrace) {
      debugPrint('[TodayTasksBloc] Error refreshing tasks: $e');
      debugPrint('[TodayTasksBloc] Stack trace: $stackTrace');
      emit(state.copyWith(errorMessage: 'فشل في تحديث مهام اليوم'));
    }
  }

  Future<List<TaskWithDetails>> _loadTodayTasks({String? creatorId}) async {
    final overallStart = DateTime.now();
    debugPrint('[TodayTasksBloc] 🚀 _loadTodayTasks() started (creatorId: ${creatorId ?? "all"})');

    // Use KSA timezone for "today"
    final today = KsaTimezone.today();

    // Get settings to calculate deadline
    final settings = await _settingsRepository.getSettings();
    final deadline = settings.todayDeadline;
    debugPrint('[TodayTasksBloc] ⏰ Deadline for today: $deadline');

    // Get tasks - either all or filtered by creator
    final tasksStart = DateTime.now();
    final List<TaskModel> allTasks;
    if (creatorId != null) {
      allTasks = await _taskRepository.getTasksByCreator(creatorId);
    } else {
      allTasks = await _taskRepository.getActiveTasks();
    }
    final tasksDuration = DateTime.now().difference(tasksStart);
    debugPrint('[TodayTasksBloc] 📋 Tasks fetch took: ${tasksDuration.inMilliseconds}ms (${allTasks.length} tasks)');

    // Get all labels for lookup
    final labelsStart = DateTime.now();
    final allLabels = await _labelRepository.getAllLabels();
    final labelsMap = {for (var l in allLabels) l.id: l};
    final labelsDuration = DateTime.now().difference(labelsStart);
    debugPrint('[TodayTasksBloc] 🏷️ Labels fetch took: ${labelsDuration.inMilliseconds}ms (${allLabels.length} labels)');

    // Batch fetch all creators (performance optimization)
    final creatorsStart = DateTime.now();
    final creatorIds = allTasks
        .where((t) => t.createdBy.isNotEmpty)
        .map((t) => t.createdBy)
        .toSet()
        .toList();
    final creatorsMap = await _userRepository.getUsersByIds(creatorIds);
    final creatorsDuration = DateTime.now().difference(creatorsStart);
    debugPrint('[TodayTasksBloc] 👥 Creators fetch took: ${creatorsDuration.inMilliseconds}ms (${creatorIds.length} users)');

    // BATCH fetch all assignments for all tasks at once (eliminates N+1 query!)
    final assignmentsStart = DateTime.now();
    final taskIds = allTasks.map((t) => t.id).toList();
    final assignmentsMap = await _assignmentRepository.getAssignmentsForTasksOnDate(
      taskIds: taskIds,
      date: today,
    );
    final assignmentsDuration = DateTime.now().difference(assignmentsStart);
    final totalAssignments = assignmentsMap.values.fold<int>(0, (sum, list) => sum + list.length);
    debugPrint('[TodayTasksBloc] 📝 Assignments fetch took: ${assignmentsDuration.inMilliseconds}ms (${totalAssignments} assignments for ${taskIds.length} tasks)');

    // Build TaskWithDetails for each task
    final buildStart = DateTime.now();
    final tasksWithDetails = <TaskWithDetails>[];

    for (final task in allTasks) {
      // Get today's assignments from pre-fetched map (instant lookup!)
      final todayAssignments = assignmentsMap[task.id] ?? [];

      // Get task labels
      final taskLabels = task.labelIds
          .map((id) => labelsMap[id])
          .whereType<LabelModel>()
          .toList();

      // Get creator from pre-fetched map
      final creator = task.createdBy.isNotEmpty ? creatorsMap[task.createdBy] : null;

      tasksWithDetails.add(TaskWithDetails(
        task: task,
        labels: taskLabels,
        creator: creator,
        todayAssignments: todayAssignments,
        deadline: deadline,
      ));
    }

    // Sort by creation date (newest first)
    tasksWithDetails.sort((a, b) => b.task.createdAt.compareTo(a.task.createdAt));

    final buildDuration = DateTime.now().difference(buildStart);
    debugPrint('[TodayTasksBloc] 🔨 Build & sort took: ${buildDuration.inMilliseconds}ms');

    final totalDuration = DateTime.now().difference(overallStart);
    debugPrint('[TodayTasksBloc] ✅ TOTAL _loadTodayTasks took: ${totalDuration.inMilliseconds}ms');

    return tasksWithDetails;
  }
}
