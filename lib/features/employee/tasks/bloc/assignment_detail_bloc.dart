import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../data/models/assignment_model.dart';
import '../../../../data/models/label_model.dart';
import '../../../../data/models/task_model.dart';
import '../../../../data/models/user_model.dart';
import '../../../../data/repositories/assignment_repository.dart';
import '../../../../data/repositories/label_repository.dart';
import '../../../../data/repositories/note_repository.dart';
import '../../../../data/repositories/settings_repository.dart';
import '../../../../data/repositories/task_repository.dart';
import '../../../../data/repositories/user_repository.dart';

part 'assignment_detail_event.dart';
part 'assignment_detail_state.dart';

@injectable
class AssignmentDetailBloc
    extends Bloc<AssignmentDetailEvent, AssignmentDetailState> {
  final AssignmentRepository _assignmentRepository;
  final TaskRepository _taskRepository;
  final LabelRepository _labelRepository;
  final UserRepository _userRepository;
  final SettingsRepository _settingsRepository;
  final NoteRepository _noteRepository;

  AssignmentDetailBloc(
    this._assignmentRepository,
    this._taskRepository,
    this._labelRepository,
    this._userRepository,
    this._settingsRepository,
    this._noteRepository,
  ) : super(AssignmentDetailState.initial()) {
    on<AssignmentDetailLoadRequested>(_onLoadRequested);
    on<AssignmentDetailMarkCompletedRequested>(_onMarkCompletedRequested);
    on<AssignmentDetailApologizeRequested>(_onApologizeRequested);
    on<AssignmentDetailReactivateRequested>(_onReactivateRequested);
  }

  Future<void> _onLoadRequested(
    AssignmentDetailLoadRequested event,
    Emitter<AssignmentDetailState> emit,
  ) async {
    final overallStart = DateTime.now();
    debugPrint('[AssignmentDetailBloc] 🚀 _onLoadRequested() started - assignmentId: ${event.assignmentId}');

    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      // Fetch assignment
      final assignmentStart = DateTime.now();
      final assignment =
          await _assignmentRepository.getAssignmentById(event.assignmentId);
      final assignmentDuration = DateTime.now().difference(assignmentStart);
      debugPrint('[AssignmentDetailBloc] 📝 Assignment fetch took: ${assignmentDuration.inMilliseconds}ms');

      if (assignment == null) {
        debugPrint('[AssignmentDetailBloc] ⚠️ Assignment not found');
        emit(state.copyWith(
          isLoading: false,
          errorMessage: 'لم يتم العثور على المهمة',
        ));
        return;
      }

      // Fetch task details
      final taskStart = DateTime.now();
      final task = await _taskRepository.getTaskById(assignment.taskId);
      final taskDuration = DateTime.now().difference(taskStart);
      debugPrint('[AssignmentDetailBloc] 📋 Task fetch took: ${taskDuration.inMilliseconds}ms');

      if (task == null) {
        debugPrint('[AssignmentDetailBloc] ⚠️ Task not found');
        emit(state.copyWith(
          isLoading: false,
          errorMessage: 'لم يتم العثور على تفاصيل المهمة',
        ));
        return;
      }

      // Fetch settings for deadline
      final settingsStart = DateTime.now();
      final settings = await _settingsRepository.getSettings();
      final settingsDuration = DateTime.now().difference(settingsStart);
      debugPrint('[AssignmentDetailBloc] ⚙️ Settings fetch took: ${settingsDuration.inMilliseconds}ms');

      // Fetch labels (catch errors gracefully)
      final labelsStart = DateTime.now();
      List<LabelModel> labels = [];
      if (task.labelIds.isNotEmpty) {
        try {
          labels = await _labelRepository.getLabelsByIds(task.labelIds);
        } catch (_) {
          // Ignore label fetch errors - not critical
        }
      }
      final labelsDuration = DateTime.now().difference(labelsStart);
      debugPrint('[AssignmentDetailBloc] 🏷️ Labels fetch took: ${labelsDuration.inMilliseconds}ms (${labels.length} labels)');

      // Fetch creator (catch permission errors gracefully)
      // Employees may not have permission to read other users' data
      final creatorStart = DateTime.now();
      UserModel? creator;
      if (task.createdBy.isNotEmpty) {
        try {
          creator = await _userRepository.getUserById(task.createdBy);
        } catch (_) {
          // Ignore creator fetch errors - not critical for employees
        }
      }
      final creatorDuration = DateTime.now().difference(creatorStart);
      debugPrint('[AssignmentDetailBloc] 👤 Creator fetch took: ${creatorDuration.inMilliseconds}ms');

      final totalDuration = DateTime.now().difference(overallStart);
      debugPrint('[AssignmentDetailBloc] 🎯 TOTAL _onLoadRequested took: ${totalDuration.inMilliseconds}ms');

      emit(state.copyWith(
        isLoading: false,
        assignment: assignment,
        task: task,
        labels: labels,
        creator: creator,
        taskDeadline: settings.taskDeadline,
      ));
    } catch (e, stackTrace) {
      debugPrint('[AssignmentDetailBloc] ❌ Error in _onLoadRequested: $e');
      debugPrint('[AssignmentDetailBloc] Stack trace: $stackTrace');
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'فشل في تحميل تفاصيل المهمة',
      ));
    }
  }

  Future<void> _onMarkCompletedRequested(
    AssignmentDetailMarkCompletedRequested event,
    Emitter<AssignmentDetailState> emit,
  ) async {
    emit(state.copyWith(isActionLoading: true, clearError: true, clearSuccess: true));

    try {
      await _assignmentRepository.markAsCompleted(
        assignmentId: event.assignmentId,
        markedDoneBy: event.markedDoneBy,
        attachmentUrl: event.attachmentUrl,
      );

      // Refresh assignment
      final updatedAssignment =
          await _assignmentRepository.getAssignmentById(event.assignmentId);

      emit(state.copyWith(
        isActionLoading: false,
        assignment: updatedAssignment,
        successMessage: 'تم تسليم المهمة بنجاح',
      ));
    } catch (e) {
      emit(state.copyWith(
        isActionLoading: false,
        errorMessage: 'فشل في تسليم المهمة',
      ));
    }
  }

  Future<void> _onApologizeRequested(
    AssignmentDetailApologizeRequested event,
    Emitter<AssignmentDetailState> emit,
  ) async {
    emit(state.copyWith(isActionLoading: true, clearError: true, clearSuccess: true));

    try {
      await _assignmentRepository.markAsApologized(
        assignmentId: event.assignmentId,
        message: event.message,
      );

      // Create apologize note if message is provided
      if (event.message != null &&
          event.message!.isNotEmpty &&
          event.senderId != null &&
          event.senderName != null &&
          event.senderRole != null) {
        // Get the task ID from state
        final taskId = state.task?.id;
        if (taskId != null) {
          await _noteRepository.createNote(
            assignmentId: event.assignmentId,
            taskId: taskId,
            senderId: event.senderId!,
            senderName: event.senderName!,
            senderRole: event.senderRole!,
            message: event.message!,
            isApologizeNote: true,
          );
        }
      }

      // Refresh assignment
      final updatedAssignment =
          await _assignmentRepository.getAssignmentById(event.assignmentId);

      emit(state.copyWith(
        isActionLoading: false,
        assignment: updatedAssignment,
        successMessage: 'تم الاعتذار عن المهمة',
      ));
    } catch (e) {
      emit(state.copyWith(
        isActionLoading: false,
        errorMessage: 'فشل في الاعتذار',
      ));
    }
  }

  Future<void> _onReactivateRequested(
    AssignmentDetailReactivateRequested event,
    Emitter<AssignmentDetailState> emit,
  ) async {
    emit(state.copyWith(isActionLoading: true, clearError: true, clearSuccess: true));

    try {
      await _assignmentRepository.reactivateAssignment(event.assignmentId);

      // Refresh assignment
      final updatedAssignment =
          await _assignmentRepository.getAssignmentById(event.assignmentId);

      emit(state.copyWith(
        isActionLoading: false,
        assignment: updatedAssignment,
        successMessage: 'تم إعادة تفعيل المهمة',
      ));
    } catch (e) {
      emit(state.copyWith(
        isActionLoading: false,
        errorMessage: 'فشل في إعادة تفعيل المهمة',
      ));
    }
  }
}
