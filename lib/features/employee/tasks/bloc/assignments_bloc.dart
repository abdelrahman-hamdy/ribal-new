import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/utils/ksa_timezone.dart';
import '../../../../data/models/assignment_model.dart';
import '../../../../data/models/task_model.dart';
import '../../../../data/repositories/assignment_repository.dart';
import '../../../../data/repositories/settings_repository.dart';
import '../../../../data/repositories/task_repository.dart';

part 'assignments_event.dart';
part 'assignments_state.dart';

@injectable
class AssignmentsBloc extends Bloc<AssignmentsEvent, AssignmentsState> {
  final AssignmentRepository _assignmentRepository;
  final TaskRepository _taskRepository;
  final SettingsRepository _settingsRepository;
  StreamSubscription? _assignmentsSubscription;

  /// Cache for task details to avoid repeated fetches
  final Map<String, TaskModel> _taskCache = {};

  AssignmentsBloc(
    this._assignmentRepository,
    this._taskRepository,
    this._settingsRepository,
  ) : super(AssignmentsState.initial()) {
    on<AssignmentsLoadRequested>(_onLoadRequested);
    on<_AssignmentsStreamUpdated>(_onStreamUpdated);
    on<_AssignmentsStreamError>(_onStreamError);
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
    emit(state.copyWith(isLoading: true, clearError: true, userId: event.userId));

    try {
      // Fetch settings for deadline
      final settings = await _settingsRepository.getSettings();

      await _assignmentsSubscription?.cancel();

      _assignmentsSubscription = _assignmentRepository
          .streamAssignmentsForUserOnDate(
            userId: event.userId,
            date: state.selectedDate,
          )
          .asyncMap((assignments) async {
        // Fetch task details for each assignment
        final assignmentsWithTasks =
            await _fetchTaskDetailsForAssignments(assignments);
        return assignmentsWithTasks;
      }).listen(
        (assignmentsWithTasks) {
          // Dispatch internal event instead of calling emit directly
          add(_AssignmentsStreamUpdated(
            userId: event.userId,
            assignmentsWithTasks: assignmentsWithTasks,
            taskDeadline: settings.taskDeadline,
          ));
        },
        onError: (error) {
          add(const _AssignmentsStreamError(errorMessage: 'فشل في تحميل المهام'));
        },
      );
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'فشل في تحميل المهام',
      ));
    }
  }

  void _onStreamUpdated(
    _AssignmentsStreamUpdated event,
    Emitter<AssignmentsState> emit,
  ) {
    final rawAssignments =
        event.assignmentsWithTasks.map((a) => a.assignment).toList();
    emit(state.copyWith(
      userId: event.userId,
      assignments: rawAssignments,
      assignmentsWithTasks: event.assignmentsWithTasks,
      filteredAssignments: _applyFilter(rawAssignments, state.filterStatus),
      filteredAssignmentsWithTasks:
          _applyFilterWithTasks(event.assignmentsWithTasks, state.filterStatus),
      isLoading: false,
      taskDeadline: event.taskDeadline,
    ));
  }

  void _onStreamError(
    _AssignmentsStreamError event,
    Emitter<AssignmentsState> emit,
  ) {
    emit(state.copyWith(
      isLoading: false,
      errorMessage: event.errorMessage,
    ));
  }

  /// Fetch task details for a list of assignments
  Future<List<AssignmentWithTask>> _fetchTaskDetailsForAssignments(
    List<AssignmentModel> assignments,
  ) async {
    final result = <AssignmentWithTask>[];

    for (final assignment in assignments) {
      // Check cache first
      TaskModel? task = _taskCache[assignment.taskId];

      if (task == null) {
        // Fetch from repository
        task = await _taskRepository.getTaskById(assignment.taskId);
        if (task != null) {
          _taskCache[assignment.taskId] = task;
        }
      }

      if (task != null) {
        result.add(AssignmentWithTask(
          assignment: assignment,
          taskTitle: task.title,
          taskDescription: task.description,
          taskLabelIds: task.labelIds,
          taskAttachmentUrl: task.attachmentUrl,
          taskAttachmentRequired: task.attachmentRequired,
          taskCreatorId: task.createdBy,
        ));
      }
    }

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
    emit(state.copyWith(selectedDate: event.date, isLoading: true));

    if (state.userId != null) {
      await _assignmentsSubscription?.cancel();

      final userId = state.userId!;
      _assignmentsSubscription = _assignmentRepository
          .streamAssignmentsForUserOnDate(
            userId: userId,
            date: event.date,
          )
          .asyncMap((assignments) async {
        // Fetch task details for each assignment
        final assignmentsWithTasks =
            await _fetchTaskDetailsForAssignments(assignments);
        return assignmentsWithTasks;
      }).listen(
        (assignmentsWithTasks) {
          // Dispatch internal event instead of calling emit directly
          add(_AssignmentsStreamUpdated(
            userId: userId,
            assignmentsWithTasks: assignmentsWithTasks,
          ));
        },
        onError: (error) {
          add(const _AssignmentsStreamError(errorMessage: 'فشل في تحميل المهام'));
        },
      );
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
    _assignmentsSubscription?.cancel();
    return super.close();
  }
}
