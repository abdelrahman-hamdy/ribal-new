part of 'tasks_bloc.dart';

/// Tasks state
class TasksState extends Equatable {
  final List<TaskModel> tasks;
  final List<TaskModel> filteredTasks;
  final List<TaskModel> archivedTasks;
  final String searchQuery;
  final bool? filterRecurring;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  const TasksState({
    this.tasks = const [],
    this.filteredTasks = const [],
    this.archivedTasks = const [],
    this.searchQuery = '',
    this.filterRecurring,
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  factory TasksState.initial() => const TasksState();

  TasksState copyWith({
    List<TaskModel>? tasks,
    List<TaskModel>? filteredTasks,
    List<TaskModel>? archivedTasks,
    String? searchQuery,
    bool? filterRecurring,
    bool clearFilterRecurring = false,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    String? successMessage,
    bool clearSuccess = false,
  }) {
    return TasksState(
      tasks: tasks ?? this.tasks,
      filteredTasks: filteredTasks ?? this.filteredTasks,
      archivedTasks: archivedTasks ?? this.archivedTasks,
      searchQuery: searchQuery ?? this.searchQuery,
      filterRecurring: clearFilterRecurring ? null : (filterRecurring ?? this.filterRecurring),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }

  @override
  List<Object?> get props => [
        tasks,
        filteredTasks,
        archivedTasks,
        searchQuery,
        filterRecurring,
        isLoading,
        errorMessage,
        successMessage,
      ];

  /// Get recurring tasks
  List<TaskModel> get recurringTasks => tasks.where((t) => t.isRecurring).toList();

  /// Get one-time tasks
  List<TaskModel> get oneTimeTasks => tasks.where((t) => !t.isRecurring).toList();

  /// Get task by ID
  TaskModel? getTaskById(String id) {
    try {
      return tasks.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }
}
