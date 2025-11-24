import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/utils/ksa_timezone.dart';
import '../../../../data/models/assignment_model.dart';
import '../../../../data/models/label_model.dart';
import '../../../../data/models/task_model.dart';
import '../../../../data/models/user_model.dart';
import '../../../../data/repositories/assignment_repository.dart';
import '../../../../data/repositories/label_repository.dart';
import '../../../../data/repositories/task_repository.dart';
import '../../../../data/repositories/user_repository.dart';

part 'task_detail_event.dart';
part 'task_detail_state.dart';

/// Assignee with user details
class AssigneeWithUser {
  final AssignmentModel assignment;
  final UserModel? user;

  const AssigneeWithUser({
    required this.assignment,
    this.user,
  });

  /// Creates fake data for skeleton loading
  factory AssigneeWithUser.fake() {
    return AssigneeWithUser(
      assignment: AssignmentModel.fake(),
      user: UserModel.fake(),
    );
  }
}

@injectable
class TaskDetailBloc extends Bloc<TaskDetailEvent, TaskDetailState> {
  final TaskRepository _taskRepository;
  final AssignmentRepository _assignmentRepository;
  final LabelRepository _labelRepository;
  final UserRepository _userRepository;

  StreamSubscription? _taskSubscription;
  StreamSubscription? _assignmentsSubscription;

  TaskDetailBloc(
    this._taskRepository,
    this._assignmentRepository,
    this._labelRepository,
    this._userRepository,
  ) : super(TaskDetailState.initial()) {
    on<TaskDetailLoadRequested>(_onLoadRequested);
    on<TaskDetailRefreshRequested>(_onRefreshRequested);
    on<_TaskDataReceived>(_onTaskDataReceived);
    on<_AssignmentsDataReceived>(_onAssignmentsDataReceived);
    on<_TaskErrorReceived>(_onErrorReceived);
    on<TaskDetailMarkAsDoneRequested>(_onMarkAsDoneRequested);
    on<TaskDetailDeleteRequested>(_onDeleteRequested);
    on<TaskDetailArchiveRequested>(_onArchiveRequested);
  }

  Future<void> _onLoadRequested(
    TaskDetailLoadRequested event,
    Emitter<TaskDetailState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true, taskId: event.taskId));

    await _taskSubscription?.cancel();
    await _assignmentsSubscription?.cancel();

    // Stream task
    _taskSubscription = _taskRepository.streamTask(event.taskId).listen(
      (task) async {
        if (isClosed) return;

        if (task != null) {
          // Get labels
          final labels = await _labelRepository.getLabelsByIds(task.labelIds);

          // Get creator
          UserModel? creator;
          if (task.createdBy.isNotEmpty) {
            creator = await _userRepository.getUserById(task.createdBy);
          }

          if (isClosed) return;
          add(_TaskDataReceived(task: task, labels: labels, creator: creator));
        } else {
          add(const _TaskErrorReceived(message: 'المهمة غير موجودة'));
        }
      },
      onError: (error) {
        if (!isClosed) add(const _TaskErrorReceived(message: 'فشل في تحميل المهمة'));
      },
    );

    // Stream today's assignments for this task
    _assignmentsSubscription = _assignmentRepository
        .streamAssignmentsForTask(event.taskId)
        .listen(
      (assignments) async {
        if (isClosed) return;

        // Filter to today's assignments only (using KSA timezone)
        final todayStart = KsaTimezone.startOfToday();
        final todayEnd = todayStart.add(const Duration(days: 1));

        final todayAssignments = assignments.where((a) {
          return a.scheduledDate.isAfter(todayStart.subtract(const Duration(seconds: 1))) &&
                 a.scheduledDate.isBefore(todayEnd);
        }).toList();

        // Get user details for each assignment
        final assigneesWithUsers = <AssigneeWithUser>[];
        for (final assignment in todayAssignments) {
          if (isClosed) return;
          final user = await _userRepository.getUserById(assignment.userId);
          assigneesWithUsers.add(AssigneeWithUser(
            assignment: assignment,
            user: user,
          ));
        }

        if (isClosed) return;
        add(_AssignmentsDataReceived(assignees: assigneesWithUsers));
      },
      onError: (error) {
        if (!isClosed) add(const _TaskErrorReceived(message: 'فشل في تحميل المكلفين'));
      },
    );
  }

  Future<void> _onRefreshRequested(
    TaskDetailRefreshRequested event,
    Emitter<TaskDetailState> emit,
  ) async {
    if (state.taskId == null) return;

    // Reset assignees loading state for shimmer
    emit(state.copyWith(isAssigneesLoading: true, clearError: true));

    // Re-trigger load with existing taskId
    add(TaskDetailLoadRequested(taskId: state.taskId!));
  }

  void _onTaskDataReceived(
    _TaskDataReceived event,
    Emitter<TaskDetailState> emit,
  ) {
    emit(state.copyWith(
      task: event.task,
      labels: event.labels,
      creator: event.creator,
      isLoading: false,
    ));
  }

  void _onAssignmentsDataReceived(
    _AssignmentsDataReceived event,
    Emitter<TaskDetailState> emit,
  ) {
    emit(state.copyWith(
      assignees: event.assignees,
      isAssigneesLoading: false,
    ));
  }

  void _onErrorReceived(
    _TaskErrorReceived event,
    Emitter<TaskDetailState> emit,
  ) {
    emit(state.copyWith(
      isLoading: false,
      isAssigneesLoading: false,
      errorMessage: event.message,
    ));
  }

  Future<void> _onMarkAsDoneRequested(
    TaskDetailMarkAsDoneRequested event,
    Emitter<TaskDetailState> emit,
  ) async {
    emit(state.copyWith(
      clearError: true,
      clearSuccess: true,
      loadingAssignmentId: event.assignmentId,
    ));

    try {
      await _assignmentRepository.markAsCompleted(
        assignmentId: event.assignmentId,
        markedDoneBy: event.markedDoneBy,
      );
      emit(state.copyWith(
        successMessage: 'تم تعليم المهمة كمكتملة',
        clearLoadingAssignment: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'فشل في تحديث حالة المهمة',
        clearLoadingAssignment: true,
      ));
    }
  }

  Future<void> _onDeleteRequested(
    TaskDetailDeleteRequested event,
    Emitter<TaskDetailState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true, clearSuccess: true));

    try {
      // Cancel subscriptions before delete to prevent stream callbacks
      // from firing after the page pops and the bloc closes
      await _taskSubscription?.cancel();
      await _assignmentsSubscription?.cancel();
      _taskSubscription = null;
      _assignmentsSubscription = null;

      await _taskRepository.deleteTask(event.taskId);
      emit(state.copyWith(
        isLoading: false,
        successMessage: 'تم حذف المهمة بنجاح',
        isDeleted: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'فشل في حذف المهمة',
      ));
    }
  }

  Future<void> _onArchiveRequested(
    TaskDetailArchiveRequested event,
    Emitter<TaskDetailState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true, clearSuccess: true));

    try {
      // Cancel subscriptions before archive to prevent stream callbacks
      // from firing after the page pops and the bloc closes
      await _taskSubscription?.cancel();
      await _assignmentsSubscription?.cancel();
      _taskSubscription = null;
      _assignmentsSubscription = null;

      await _taskRepository.archiveTask(event.taskId);
      emit(state.copyWith(
        isLoading: false,
        successMessage: 'تم إيقاف المهمة وأرشفتها بنجاح',
        isArchived: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'فشل في أرشفة المهمة',
      ));
    }
  }

  @override
  Future<void> close() {
    _taskSubscription?.cancel();
    _assignmentsSubscription?.cancel();
    return super.close();
  }
}
