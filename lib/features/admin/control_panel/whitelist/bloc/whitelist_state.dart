part of 'whitelist_bloc.dart';

/// Whitelist state
class WhitelistState extends Equatable {
  final List<WhitelistModel> entries;
  final List<WhitelistModel> filteredEntries;
  final String searchQuery;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  const WhitelistState({
    this.entries = const [],
    this.filteredEntries = const [],
    this.searchQuery = '',
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  factory WhitelistState.initial() => const WhitelistState();

  WhitelistState copyWith({
    List<WhitelistModel>? entries,
    List<WhitelistModel>? filteredEntries,
    String? searchQuery,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    String? successMessage,
    bool clearSuccess = false,
  }) {
    return WhitelistState(
      entries: entries ?? this.entries,
      filteredEntries: filteredEntries ?? this.filteredEntries,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }

  @override
  List<Object?> get props => [
        entries,
        filteredEntries,
        searchQuery,
        isLoading,
        errorMessage,
        successMessage,
      ];
}
