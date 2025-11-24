part of 'labels_bloc.dart';

/// Labels state
class LabelsState extends Equatable {
  final List<LabelModel> labels;
  final List<LabelModel> filteredLabels;
  final String searchQuery;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  const LabelsState({
    this.labels = const [],
    this.filteredLabels = const [],
    this.searchQuery = '',
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  factory LabelsState.initial() => const LabelsState();

  LabelsState copyWith({
    List<LabelModel>? labels,
    List<LabelModel>? filteredLabels,
    String? searchQuery,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    String? successMessage,
    bool clearSuccess = false,
  }) {
    return LabelsState(
      labels: labels ?? this.labels,
      filteredLabels: filteredLabels ?? this.filteredLabels,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }

  @override
  List<Object?> get props => [
        labels,
        filteredLabels,
        searchQuery,
        isLoading,
        errorMessage,
        successMessage,
      ];

  /// Get active labels
  List<LabelModel> get activeLabels => labels.where((l) => l.isActive).toList();

  /// Get label by ID
  LabelModel? getLabelById(String id) {
    try {
      return labels.firstWhere((l) => l.id == id);
    } catch (_) {
      return null;
    }
  }
}
