import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../data/models/task_model.dart';
import '../../../../data/repositories/task_repository.dart';

part 'tasks_event.dart';
part 'tasks_state.dart';

@injectable
class TasksBloc extends Bloc<TasksEvent, TasksState> {
  final TaskRepository _taskRepository;

  TasksBloc(this._taskRepository) : super(TasksState.initial()) {
    on<TasksLoadRequested>(_onLoadRequested);
    on<TasksLoadArchivedRequested>(_onLoadArchivedRequested);
    on<TaskCreateRequested>(_onCreateRequested);
    on<TaskUpdateRequested>(_onUpdateRequested);
    on<TaskArchiveRequested>(_onArchiveRequested);
    on<TaskRestoreRequested>(_onRestoreRequested);
    on<TaskDeleteRequested>(_onDeleteRequested);
    on<TaskToggleRecurringRequested>(_onToggleRecurringRequested);
    on<TasksSearchRequested>(_onSearchRequested);
    on<TasksSearchCleared>(_onSearchCleared);
    on<TasksFilterChanged>(_onFilterChanged);
    on<TaskPublishAsRecurringRequested>(_onPublishAsRecurringRequested);
    on<TaskPublishForTodayRequested>(_onPublishForTodayRequested);
  }

  Future<void> _onLoadRequested(
    TasksLoadRequested event,
    Emitter<TasksState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      // Use cache-first strategy - NO STREAMS!
      final tasks = await _taskRepository.getActiveTasks();

      emit(state.copyWith(
        tasks: tasks,
        filteredTasks: _applyFilters(tasks, state.searchQuery, state.filterRecurring),
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'فشل في تحميل المهام',
      ));
    }
  }

  Future<void> _onLoadArchivedRequested(
    TasksLoadArchivedRequested event,
    Emitter<TasksState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      // Use cache-first strategy - NO STREAMS!
      final tasks = await _taskRepository.getArchivedTasks();

      emit(state.copyWith(
        archivedTasks: tasks,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'فشل في تحميل الأرشيف',
      ));
    }
  }

  Future<void> _onCreateRequested(
    TaskCreateRequested event,
    Emitter<TasksState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true, clearSuccess: true));

    try {
      final task = TaskModel(
        id: '',
        title: event.title,
        description: event.description,
        labelIds: event.labelIds,
        attachmentUrl: event.attachmentUrl,
        isRecurring: event.isRecurring,
        isActive: true,
        isArchived: false,
        attachmentRequired: event.attachmentRequired,
        assigneeSelection: event.assigneeSelection,
        selectedGroupIds: event.selectedGroupIds,
        selectedUserIds: event.selectedUserIds,
        createdBy: event.createdBy,
        // Denormalized creator info (avoids extra user fetch when displaying)
        creatorName: event.creatorName,
        creatorEmail: event.creatorEmail,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _taskRepository.createTask(task);

      // Note: Assignments will be created by Cloud Function triggered on task creation

      emit(state.copyWith(
        isLoading: false,
        successMessage: 'تم إنشاء المهمة بنجاح',
      ));

      // Reload data after mutation to get fresh data
      if (!isClosed) add(const TasksLoadRequested());
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'فشل في إنشاء المهمة',
      ));
    }
  }

  Future<void> _onUpdateRequested(
    TaskUpdateRequested event,
    Emitter<TasksState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true, clearSuccess: true));

    try {
      await _taskRepository.updateTask(event.task);
      emit(state.copyWith(
        isLoading: false,
        successMessage: 'تم تحديث المهمة بنجاح',
      ));

      // Reload data after mutation to get fresh data
      if (!isClosed) add(const TasksLoadRequested());
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'فشل في تحديث المهمة',
      ));
    }
  }

  Future<void> _onArchiveRequested(
    TaskArchiveRequested event,
    Emitter<TasksState> emit,
  ) async {
    emit(state.copyWith(clearError: true, clearSuccess: true));

    try {
      await _taskRepository.archiveTask(event.taskId);
      emit(state.copyWith(
        successMessage: 'تم أرشفة المهمة بنجاح',
      ));

      // Reload data after mutation to get fresh data
      if (!isClosed) add(const TasksLoadRequested());
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'فشل في أرشفة المهمة',
      ));
    }
  }

  Future<void> _onRestoreRequested(
    TaskRestoreRequested event,
    Emitter<TasksState> emit,
  ) async {
    emit(state.copyWith(clearError: true, clearSuccess: true));

    try {
      await _taskRepository.restoreTask(event.taskId);
      emit(state.copyWith(
        successMessage: 'تم استعادة المهمة بنجاح',
      ));

      // Reload archived tasks after restore
      if (!isClosed) add(const TasksLoadArchivedRequested());
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'فشل في استعادة المهمة',
      ));
    }
  }

  Future<void> _onDeleteRequested(
    TaskDeleteRequested event,
    Emitter<TasksState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true, clearSuccess: true));

    try {
      // Note: Assignments deletion should be handled by Cloud Function or cascade delete
      await _taskRepository.deleteTask(event.taskId);
      emit(state.copyWith(
        isLoading: false,
        successMessage: 'تم حذف المهمة بنجاح',
      ));

      // Reload data after deletion
      if (!isClosed) add(const TasksLoadRequested());
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'فشل في حذف المهمة',
      ));
    }
  }

  Future<void> _onToggleRecurringRequested(
    TaskToggleRecurringRequested event,
    Emitter<TasksState> emit,
  ) async {
    emit(state.copyWith(clearError: true, clearSuccess: true));

    try {
      await _taskRepository.toggleRecurringActive(event.taskId, event.isActive);
      emit(state.copyWith(
        successMessage: event.isActive ? 'تم تفعيل المهمة المتكررة' : 'تم إيقاف المهمة المتكررة',
      ));

      // Reload data after toggle
      if (!isClosed) add(const TasksLoadRequested());
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'فشل في تحديث حالة المهمة',
      ));
    }
  }

  void _onSearchRequested(
    TasksSearchRequested event,
    Emitter<TasksState> emit,
  ) {
    final query = event.query.toLowerCase().trim();
    emit(state.copyWith(
      searchQuery: query,
      filteredTasks: _applyFilters(state.tasks, query, state.filterRecurring),
    ));
  }

  void _onSearchCleared(
    TasksSearchCleared event,
    Emitter<TasksState> emit,
  ) {
    emit(state.copyWith(
      searchQuery: '',
      filteredTasks: _applyFilters(state.tasks, '', state.filterRecurring),
    ));
  }

  void _onFilterChanged(
    TasksFilterChanged event,
    Emitter<TasksState> emit,
  ) {
    emit(state.copyWith(
      filterRecurring: event.filterRecurring,
      clearFilterRecurring: event.filterRecurring == null,
      filteredTasks: _applyFilters(state.tasks, state.searchQuery, event.filterRecurring),
    ));
  }

  Future<void> _onPublishAsRecurringRequested(
    TaskPublishAsRecurringRequested event,
    Emitter<TasksState> emit,
  ) async {
    emit(state.copyWith(clearError: true, clearSuccess: true));

    try {
      await _taskRepository.restoreTaskAsRecurring(event.taskId);
      emit(state.copyWith(
        successMessage: 'تم نشر المهمة كمهمة متكررة بنجاح',
      ));

      // Reload both active and archived tasks
      if (!isClosed) {
        add(const TasksLoadRequested());
        add(const TasksLoadArchivedRequested());
      }
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'فشل في نشر المهمة',
      ));
    }
  }

  Future<void> _onPublishForTodayRequested(
    TaskPublishForTodayRequested event,
    Emitter<TasksState> emit,
  ) async {
    emit(state.copyWith(clearError: true, clearSuccess: true));

    try {
      await _taskRepository.restoreTaskForTodayOnly(event.taskId);
      emit(state.copyWith(
        successMessage: 'تم نشر المهمة لليوم فقط بنجاح',
      ));

      // Reload both active and archived tasks
      if (!isClosed) {
        add(const TasksLoadRequested());
        add(const TasksLoadArchivedRequested());
      }
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'فشل في نشر المهمة',
      ));
    }
  }

  List<TaskModel> _applyFilters(
    List<TaskModel> tasks,
    String query,
    bool? filterRecurring,
  ) {
    var filtered = tasks;

    // Apply recurring filter
    if (filterRecurring != null) {
      filtered = filtered.where((t) => t.isRecurring == filterRecurring).toList();
    }

    // Apply search filter
    if (query.isNotEmpty) {
      filtered = filtered.where((t) {
        final title = t.title.toLowerCase();
        final description = t.description.toLowerCase();
        return title.contains(query) || description.contains(query);
      }).toList();
    }

    return filtered;
  }

  @override
  Future<void> close() {
    // No streams to cancel anymore
    return super.close();
  }
}
