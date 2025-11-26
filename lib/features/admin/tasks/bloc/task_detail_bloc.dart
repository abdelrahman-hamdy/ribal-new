import 'dart:async';

import 'package:flutter/foundation.dart';
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
import '../../../../data/repositories/note_repository.dart';
import '../../../../data/repositories/task_repository.dart';
import '../../../../data/repositories/user_repository.dart';

part 'task_detail_event.dart';
part 'task_detail_state.dart';

/// Assignee with user details
class AssigneeWithUser {
  final AssignmentModel assignment;
  final UserModel? user;
  final int notesCount;

  const AssigneeWithUser({
    required this.assignment,
    this.user,
    this.notesCount = 0,
  });

  /// Creates fake data for skeleton loading
  factory AssigneeWithUser.fake() {
    return AssigneeWithUser(
      assignment: AssignmentModel.fake(),
      user: UserModel.fake(),
      notesCount: 0,
    );
  }
}

@injectable
class TaskDetailBloc extends Bloc<TaskDetailEvent, TaskDetailState> {
  final TaskRepository _taskRepository;
  final AssignmentRepository _assignmentRepository;
  final LabelRepository _labelRepository;
  final UserRepository _userRepository;
  final NoteRepository _noteRepository;

  TaskDetailBloc(
    this._taskRepository,
    this._assignmentRepository,
    this._labelRepository,
    this._userRepository,
    this._noteRepository,
  ) : super(TaskDetailState.initial()) {
    on<TaskDetailLoadRequested>(_onLoadRequested);
    on<TaskDetailRefreshRequested>(_onRefreshRequested);
    on<TaskDetailMarkAsDoneRequested>(_onMarkAsDoneRequested);
    on<TaskDetailDeleteRequested>(_onDeleteRequested);
    on<TaskDetailArchiveRequested>(_onArchiveRequested);
  }

  Future<void> _onLoadRequested(
    TaskDetailLoadRequested event,
    Emitter<TaskDetailState> emit,
  ) async {
    final overallStart = DateTime.now();
    debugPrint('[TaskDetailBloc] 🚀 _onLoadRequested() started - taskId: ${event.taskId}');

    emit(state.copyWith(isLoading: true, clearError: true, taskId: event.taskId));

    try {
      // Fetch task
      final taskStart = DateTime.now();
      final task = await _taskRepository.getTaskById(event.taskId);
      final taskDuration = DateTime.now().difference(taskStart);
      debugPrint('[TaskDetailBloc] 📋 Task fetch took: ${taskDuration.inMilliseconds}ms');

      if (task == null) {
        debugPrint('[TaskDetailBloc] ⚠️ Task not found');
        emit(state.copyWith(
          isLoading: false,
          errorMessage: 'المهمة غير موجودة',
        ));
        return;
      }

      // Get labels (cached)
      final labelsStart = DateTime.now();
      final labels = await _labelRepository.getLabelsByIds(task.labelIds);
      final labelsDuration = DateTime.now().difference(labelsStart);
      debugPrint('[TaskDetailBloc] 🏷️ Labels fetch took: ${labelsDuration.inMilliseconds}ms (${labels.length} labels)');

      // Get creator (cached)
      final creatorStart = DateTime.now();
      UserModel? creator;
      if (task.createdBy.isNotEmpty) {
        creator = await _userRepository.getUserById(task.createdBy);
      }
      final creatorDuration = DateTime.now().difference(creatorStart);
      debugPrint('[TaskDetailBloc] 👤 Creator fetch took: ${creatorDuration.inMilliseconds}ms');

      // Update task info
      final firstEmitDuration = DateTime.now().difference(overallStart);
      debugPrint('[TaskDetailBloc] ✅ Task info loaded in: ${firstEmitDuration.inMilliseconds}ms');

      emit(state.copyWith(
        task: task,
        labels: labels,
        creator: creator,
        isLoading: false,
      ));

      // Load today's assignments separately to avoid blocking task display
      emit(state.copyWith(isAssigneesLoading: true));

      final assigneesStart = DateTime.now();
      final today = KsaTimezone.today();

      final assignmentsFetchStart = DateTime.now();
      final assignments = await _assignmentRepository.getAssignmentsForTaskOnDate(
        taskId: event.taskId,
        date: today,
      );
      final assignmentsFetchDuration = DateTime.now().difference(assignmentsFetchStart);
      debugPrint('[TaskDetailBloc] 📝 Assignments fetch took: ${assignmentsFetchDuration.inMilliseconds}ms (${assignments.length} assignments)');

      // Batch fetch all users
      final usersStart = DateTime.now();
      final userIds = assignments.map((a) => a.userId).toSet().toList();
      final usersMap = await _userRepository.getUsersByIds(userIds);
      final usersDuration = DateTime.now().difference(usersStart);
      debugPrint('[TaskDetailBloc] 👥 Users fetch took: ${usersDuration.inMilliseconds}ms (${userIds.length} users)');

      // Batch fetch all note counts
      final notesStart = DateTime.now();
      final assignmentIds = assignments.map((a) => a.id).toList();
      final noteCounts = await _noteRepository.getNotesCountsForAssignments(assignmentIds);
      final notesDuration = DateTime.now().difference(notesStart);
      debugPrint('[TaskDetailBloc] 📓 Note counts fetch took: ${notesDuration.inMilliseconds}ms (${assignmentIds.length} assignments)');

      // Build assignees with users list
      final buildStart = DateTime.now();
      final assigneesWithUsers = assignments
          .map((assignment) => AssigneeWithUser(
                assignment: assignment,
                user: usersMap[assignment.userId],
                notesCount: noteCounts[assignment.id] ?? 0,
              ))
          .toList();
      final buildDuration = DateTime.now().difference(buildStart);
      debugPrint('[TaskDetailBloc] 🔨 Build assignees took: ${buildDuration.inMilliseconds}ms');

      final assigneesTotalDuration = DateTime.now().difference(assigneesStart);
      debugPrint('[TaskDetailBloc] ✅ Assignees loaded in: ${assigneesTotalDuration.inMilliseconds}ms');

      emit(state.copyWith(
        assignees: assigneesWithUsers,
        isAssigneesLoading: false,
      ));

      final totalDuration = DateTime.now().difference(overallStart);
      debugPrint('[TaskDetailBloc] 🎯 TOTAL _onLoadRequested took: ${totalDuration.inMilliseconds}ms');
    } catch (e, stackTrace) {
      debugPrint('[TaskDetailBloc] ❌ Error in _onLoadRequested: $e');
      debugPrint('[TaskDetailBloc] Stack trace: $stackTrace');
      emit(state.copyWith(
        isLoading: false,
        isAssigneesLoading: false,
        errorMessage: 'فشل في تحميل المهمة',
      ));
    }
  }

  Future<void> _onRefreshRequested(
    TaskDetailRefreshRequested event,
    Emitter<TaskDetailState> emit,
  ) async {
    if (state.taskId == null || isClosed) return;

    // Re-trigger load with existing taskId
    add(TaskDetailLoadRequested(taskId: state.taskId!));
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

      // Reload data after mutation (cache was cleared, will fetch fresh data)
      if (state.taskId != null && !isClosed) {
        add(TaskDetailLoadRequested(taskId: state.taskId!));
      }
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
}
