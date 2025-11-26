import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/utils/ksa_timezone.dart';
import '../../../../data/models/assignment_model.dart';
import '../../../../data/models/task_model.dart';
import '../../../../data/models/user_model.dart';
import '../../../../data/repositories/assignment_repository.dart';
import '../../../../data/repositories/settings_repository.dart';
import '../../../../data/repositories/task_repository.dart';
import '../../../../data/repositories/user_repository.dart';

part 'assignments_event.dart';
part 'assignments_state.dart';

@injectable
class AssignmentsBloc extends Bloc<AssignmentsEvent, AssignmentsState> {
  final AssignmentRepository _assignmentRepository;
  final TaskRepository _taskRepository;
  final SettingsRepository _settingsRepository;
  final UserRepository _userRepository;

  /// Cache for task details to avoid repeated fetches
  final Map<String, TaskModel> _taskCache = {};

  /// Cache for user details to avoid repeated fetches
  final Map<String, UserModel> _userCache = {};

  AssignmentsBloc(
    this._assignmentRepository,
    this._taskRepository,
    this._settingsRepository,
    this._userRepository,
  ) : super(AssignmentsState.initial()) {
    on<AssignmentsLoadRequested>(_onLoadRequested);
    on<AssignmentMarkCompletedRequested>(_onMarkCompletedRequested);
    on<AssignmentApologizeRequested>(_onApologizeRequested);
    on<AssignmentReactivateRequested>(_onReactivateRequested);
    on<AssignmentsDateChanged>(_onDateChanged);
    on<AssignmentsFilterChanged>(_onFilterChanged);
  }

  Future<void> _onLoadRequested(
    AssignmentsLoadRequested event,
    Emitter<AssignmentsState> emit,
  ) async {
    final overallStart = DateTime.now();
    debugPrint('[AssignmentsBloc] 🚀 _onLoadRequested() started');

    final emitStart = DateTime.now();
    emit(state.copyWith(isLoading: true, clearError: true, userId: event.userId));
    final emitDuration = DateTime.now().difference(emitStart);
    debugPrint('[AssignmentsBloc] ⏱️ Initial emit took: ${emitDuration.inMilliseconds}ms');

    try {
      // Fetch settings for deadline
      final settingsStart = DateTime.now();
      final settings = await _settingsRepository.getSettings();
      final settingsDuration = DateTime.now().difference(settingsStart);
      debugPrint('[AssignmentsBloc] ⚙️ Settings fetch took: ${settingsDuration.inMilliseconds}ms');

      // Use cache-first strategy - NO STREAMS!
      final assignmentsStart = DateTime.now();
      final assignments = await _assignmentRepository.getAssignmentsForUserOnDate(
        userId: event.userId,
        date: state.selectedDate,
      );
      final assignmentsDuration = DateTime.now().difference(assignmentsStart);
      debugPrint('[AssignmentsBloc] 📋 Assignments fetch took: ${assignmentsDuration.inMilliseconds}ms');

      // Fetch task details for each assignment
      final taskDetailsStart = DateTime.now();
      final assignmentsWithTasks = await _fetchTaskDetailsForAssignments(assignments);
      final taskDetailsDuration = DateTime.now().difference(taskDetailsStart);
      debugPrint('[AssignmentsBloc] 📝 Task details fetch took: ${taskDetailsDuration.inMilliseconds}ms');

      final mappingStart = DateTime.now();
      final rawAssignments = assignmentsWithTasks.map((a) => a.assignment).toList();
      final mappingDuration = DateTime.now().difference(mappingStart);
      debugPrint('[AssignmentsBloc] 🗺️ Mapping took: ${mappingDuration.inMilliseconds}ms');

      final filterStart = DateTime.now();
      final filteredAssignments = _applyFilter(rawAssignments, state.filterStatus);
      final filteredAssignmentsWithTasks = _applyFilterWithTasks(assignmentsWithTasks, state.filterStatus);
      final filterDuration = DateTime.now().difference(filterStart);
      debugPrint('[AssignmentsBloc] 🔍 Filtering took: ${filterDuration.inMilliseconds}ms');

      final finalEmitStart = DateTime.now();
      emit(state.copyWith(
        userId: event.userId,
        assignments: rawAssignments,
        assignmentsWithTasks: assignmentsWithTasks,
        filteredAssignments: filteredAssignments,
        filteredAssignmentsWithTasks: filteredAssignmentsWithTasks,
        isLoading: false,
        taskDeadline: settings.taskDeadline,
        hasLoadedOnce: true,
      ));
      final finalEmitDuration = DateTime.now().difference(finalEmitStart);
      debugPrint('[AssignmentsBloc] ⏱️ Final emit took: ${finalEmitDuration.inMilliseconds}ms');

      final totalDuration = DateTime.now().difference(overallStart);
      debugPrint('[AssignmentsBloc] ✅ TOTAL _onLoadRequested took: ${totalDuration.inMilliseconds}ms');
    } catch (e) {
      debugPrint('[AssignmentsBloc] ❌ Error in _onLoadRequested: $e');
      emit(state.copyWith(
        isLoading: false,
        hasLoadedOnce: true,
        errorMessage: 'فشل في تحميل المهام',
      ));
    }
  }


  /// Fetch task details for a list of assignments (OPTIMIZED: batch fetching)
  Future<List<AssignmentWithTask>> _fetchTaskDetailsForAssignments(
    List<AssignmentModel> assignments,
  ) async {
    if (assignments.isEmpty) return [];

    final fetchStart = DateTime.now();
    debugPrint('[AssignmentsBloc] 📋 Fetching task details for ${assignments.length} assignments');

    // Extract all unique task IDs that need to be fetched
    final taskIdsToFetch = <String>[];
    for (final assignment in assignments) {
      if (!_taskCache.containsKey(assignment.taskId)) {
        taskIdsToFetch.add(assignment.taskId);
      }
    }

    // BATCH FETCH all missing tasks at once (eliminates N+1 query!)
    if (taskIdsToFetch.isNotEmpty) {
      debugPrint('[AssignmentsBloc] 🔄 Batch fetching ${taskIdsToFetch.length} tasks');
      final tasksMap = await _taskRepository.getTasksByIds(taskIdsToFetch);
      _taskCache.addAll(tasksMap);
    }

    // Extract all unique creator IDs from tasks
    final creatorIdsToFetch = <String>[];
    for (final task in _taskCache.values) {
      if (task.createdBy.isNotEmpty && !_userCache.containsKey(task.createdBy)) {
        creatorIdsToFetch.add(task.createdBy);
      }
    }

    // BATCH FETCH all missing creators at once (eliminates N+1 query!)
    if (creatorIdsToFetch.isNotEmpty) {
      debugPrint('[AssignmentsBloc] 👥 Batch fetching ${creatorIdsToFetch.length} creators');
      final creatorsMap = await _userRepository.getUsersByIds(creatorIdsToFetch);
      _userCache.addAll(creatorsMap);
    }

    // Build result from pre-fetched maps (instant lookups!)
    final result = <AssignmentWithTask>[];
    for (final assignment in assignments) {
      final task = _taskCache[assignment.taskId];
      if (task != null) {
        final creator = _userCache[task.createdBy];
        final creatorName = creator?.fullName ?? 'غير معروف';

        result.add(AssignmentWithTask(
          assignment: assignment,
          taskTitle: task.title,
          taskDescription: task.description,
          taskLabelIds: task.labelIds,
          taskAttachmentUrl: task.attachmentUrl,
          taskAttachmentRequired: task.attachmentRequired,
          taskCreatorId: task.createdBy,
          taskCreatorName: creatorName,
        ));
      }
    }

    final duration = DateTime.now().difference(fetchStart);
    debugPrint('[AssignmentsBloc] ✅ Built ${result.length} assignments with task details in ${duration.inMilliseconds}ms');

    return result;
  }

  Future<void> _onMarkCompletedRequested(
    AssignmentMarkCompletedRequested event,
    Emitter<AssignmentsState> emit,
  ) async {
    emit(state.copyWith(clearError: true, clearSuccess: true));

    try {
      await _assignmentRepository.markAsCompleted(
        assignmentId: event.assignmentId,
        markedDoneBy: event.markedDoneBy,
      );
      emit(state.copyWith(
        successMessage: 'تم تسليم المهمة بنجاح',
      ));

      // Reload data after mutation (cache was cleared, will fetch fresh data)
      if (state.userId != null && !isClosed) {
        add(AssignmentsLoadRequested(userId: state.userId!));
      }
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'فشل في تسليم المهمة',
      ));
    }
  }

  Future<void> _onApologizeRequested(
    AssignmentApologizeRequested event,
    Emitter<AssignmentsState> emit,
  ) async {
    emit(state.copyWith(clearError: true, clearSuccess: true));

    try {
      await _assignmentRepository.markAsApologized(
        assignmentId: event.assignmentId,
        message: event.message,
      );
      emit(state.copyWith(
        successMessage: 'تم الاعتذار عن المهمة',
      ));

      // Reload data after mutation (cache was cleared, will fetch fresh data)
      if (state.userId != null && !isClosed) {
        add(AssignmentsLoadRequested(userId: state.userId!));
      }
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'فشل في الاعتذار',
      ));
    }
  }

  Future<void> _onReactivateRequested(
    AssignmentReactivateRequested event,
    Emitter<AssignmentsState> emit,
  ) async {
    emit(state.copyWith(clearError: true, clearSuccess: true));

    try {
      await _assignmentRepository.reactivateAssignment(event.assignmentId);
      emit(state.copyWith(
        successMessage: 'تم إعادة تفعيل المهمة',
      ));

      // Reload data after mutation (cache was cleared, will fetch fresh data)
      if (state.userId != null && !isClosed) {
        add(AssignmentsLoadRequested(userId: state.userId!));
      }
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'فشل في إعادة تفعيل المهمة',
      ));
    }
  }

  Future<void> _onDateChanged(
    AssignmentsDateChanged event,
    Emitter<AssignmentsState> emit,
  ) async {
    emit(state.copyWith(selectedDate: event.date, isLoading: true, clearError: true));

    try {
      if (state.userId != null) {
        // Use cache-first strategy - NO STREAMS!
        final assignments = await _assignmentRepository.getAssignmentsForUserOnDate(
          userId: state.userId!,
          date: event.date,
        );

        // Fetch task details for each assignment
        final assignmentsWithTasks = await _fetchTaskDetailsForAssignments(assignments);

        final rawAssignments = assignmentsWithTasks.map((a) => a.assignment).toList();

        emit(state.copyWith(
          assignments: rawAssignments,
          assignmentsWithTasks: assignmentsWithTasks,
          filteredAssignments: _applyFilter(rawAssignments, state.filterStatus),
          filteredAssignmentsWithTasks: _applyFilterWithTasks(assignmentsWithTasks, state.filterStatus),
          isLoading: false,
          hasLoadedOnce: true,
        ));
      }
    } catch (e) {
      debugPrint('[AssignmentsBloc] Error in _onDateChanged: $e');
      emit(state.copyWith(
        isLoading: false,
        hasLoadedOnce: true,
        errorMessage: 'فشل في تحميل المهام',
      ));
    }
  }

  void _onFilterChanged(
    AssignmentsFilterChanged event,
    Emitter<AssignmentsState> emit,
  ) {
    emit(state.copyWith(
      filterStatus: event.status,
      clearFilterStatus: event.status == null,
      filteredAssignments: _applyFilter(state.assignments, event.status),
      filteredAssignmentsWithTasks:
          _applyFilterWithTasks(state.assignmentsWithTasks, event.status),
    ));
  }

  List<AssignmentModel> _applyFilter(
    List<AssignmentModel> assignments,
    AssignmentStatus? status,
  ) {
    if (status == null) return assignments;
    return assignments.where((a) => a.status == status).toList();
  }

  List<AssignmentWithTask> _applyFilterWithTasks(
    List<AssignmentWithTask> assignments,
    AssignmentStatus? status,
  ) {
    if (status == null) return assignments;
    return assignments.where((a) => a.assignment.status == status).toList();
  }

  @override
  Future<void> close() {
    // Clear caches on close to prevent memory leaks
    _taskCache.clear();
    _userCache.clear();
    return super.close();
  }
}
