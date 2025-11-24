import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../data/models/assignment_model.dart';
import '../../../../data/models/label_model.dart';
import '../../../../data/models/task_model.dart';
import '../../../../data/models/user_model.dart';
import '../../../../data/repositories/assignment_repository.dart';
import '../../../../data/repositories/label_repository.dart';
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

  AssignmentDetailBloc(
    this._assignmentRepository,
    this._taskRepository,
    this._labelRepository,
    this._userRepository,
    this._settingsRepository,
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
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      // Fetch assignment
      final assignment =
          await _assignmentRepository.getAssignmentById(event.assignmentId);

      if (assignment == null) {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: 'لم يتم العثور على المهمة',
        ));
        return;
      }

      // Fetch task details
      final task = await _taskRepository.getTaskById(assignment.taskId);

      if (task == null) {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: 'لم يتم العثور على تفاصيل المهمة',
        ));
        return;
      }

      // Fetch settings for deadline
      final settings = await _settingsRepository.getSettings();

      // Fetch labels (catch errors gracefully)
      List<LabelModel> labels = [];
      if (task.labelIds.isNotEmpty) {
        try {
          labels = await _labelRepository.getLabelsByIds(task.labelIds);
        } catch (_) {
          // Ignore label fetch errors - not critical
        }
      }

      // Fetch creator (catch permission errors gracefully)
      // Employees may not have permission to read other users' data
      UserModel? creator;
      if (task.createdBy.isNotEmpty) {
        try {
          creator = await _userRepository.getUserById(task.createdBy);
        } catch (_) {
          // Ignore creator fetch errors - not critical for employees
        }
      }

      emit(state.copyWith(
        isLoading: false,
        assignment: assignment,
        task: task,
        labels: labels,
        creator: creator,
        taskDeadline: settings.taskDeadline,
      ));
    } catch (e) {
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
