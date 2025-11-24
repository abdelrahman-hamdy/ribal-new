import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../utils/ksa_timezone.dart';
import '../../../../../data/models/assignment_model.dart';
import '../../../../../data/models/label_model.dart';
import '../../../../../data/models/task_model.dart';
import '../../../../../data/models/task_progress.dart';
import '../../../../../data/models/user_model.dart';
import '../../../../../data/repositories/assignment_repository.dart';
import '../../../../../data/repositories/label_repository.dart';
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

  const TaskWithDetails({
    required this.task,
    required this.labels,
    this.creator,
    required this.todayAssignments,
  });

  /// Get task progress from today's assignments
  TaskProgress get progress => TaskProgress.fromAssignments(todayAssignments);

  /// Get derived task status
  TaskStatus get status => progress.status;

  /// Count of pending assignments (not overdue)
  int get pendingCount => progress.pendingCount;

  /// Count of completed assignments
  int get completedCount => progress.completedCount;

  /// Count of apologized assignments
  int get apologizedCount => progress.apologizedCount;

  /// Count of overdue assignments (pending past deadline)
  /// For now, this is 0 - would need deadline tracking on tasks
  int get overdueCount => 0;

  /// Total assignments count
  int get totalAssignments => progress.totalAssignments;
}

@injectable
class TodayTasksBloc extends Bloc<TodayTasksEvent, TodayTasksState> {
  final TaskRepository _taskRepository;
  final AssignmentRepository _assignmentRepository;
  final LabelRepository _labelRepository;
  final UserRepository _userRepository;

  TodayTasksBloc(
    this._taskRepository,
    this._assignmentRepository,
    this._labelRepository,
    this._userRepository,
  ) : super(TodayTasksState.initial()) {
    on<TodayTasksLoadRequested>(_onLoadRequested);
    on<TodayTasksRefreshRequested>(_onRefreshRequested);
  }

  Future<void> _onLoadRequested(
    TodayTasksLoadRequested event,
    Emitter<TodayTasksState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      final tasks = await _loadTodayTasks(creatorId: event.creatorId);
      emit(state.copyWith(
        tasks: tasks,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'فشل في تحميل مهام اليوم',
      ));
    }
  }

  Future<void> _onRefreshRequested(
    TodayTasksRefreshRequested event,
    Emitter<TodayTasksState> emit,
  ) async {
    try {
      final tasks = await _loadTodayTasks(creatorId: event.creatorId);
      emit(state.copyWith(tasks: tasks));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'فشل في تحديث مهام اليوم'));
    }
  }

  Future<List<TaskWithDetails>> _loadTodayTasks({String? creatorId}) async {
    // Use KSA timezone for "today"
    final today = KsaTimezone.today();

    // Get tasks - either all or filtered by creator
    final List<TaskModel> allTasks;
    if (creatorId != null) {
      allTasks = await _taskRepository.getTasksByCreator(creatorId);
    } else {
      allTasks = await _taskRepository.getActiveTasks();
    }

    // Get all labels for lookup
    final allLabels = await _labelRepository.getAllLabels();
    final labelsMap = {for (var l in allLabels) l.id: l};

    // For each task, get today's assignments (if any)
    final tasksWithDetails = <TaskWithDetails>[];

    for (final task in allTasks) {
      // Try to get today's assignments (may be empty if Cloud Function hasn't run)
      final todayAssignments = await _assignmentRepository.getAssignmentsForTaskOnDate(
        taskId: task.id,
        date: today,
      );

      // Get task labels
      final taskLabels = task.labelIds
          .map((id) => labelsMap[id])
          .whereType<LabelModel>()
          .toList();

      // Get creator
      UserModel? creator;
      if (task.createdBy.isNotEmpty) {
        creator = await _userRepository.getUserById(task.createdBy);
      }

      tasksWithDetails.add(TaskWithDetails(
        task: task,
        labels: taskLabels,
        creator: creator,
        todayAssignments: todayAssignments,
      ));
    }

    // Sort by creation date (newest first)
    tasksWithDetails.sort((a, b) => b.task.createdAt.compareTo(a.task.createdAt));

    return tasksWithDetails;
  }
}
