part of 'whitelist_bloc.dart';

/// Filter status for whitelist entries
enum WhitelistFilter {
  all,
  registered,
  notRegistered,
}

/// Whitelist state
class WhitelistState extends Equatable {
  final List<WhitelistModel> entries;
  final List<WhitelistModel> filteredEntries;
  final String searchQuery;
  final WhitelistFilter filterStatus;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  const WhitelistState({
    this.entries = const [],
    this.filteredEntries = const [],
    this.searchQuery = '',
    this.filterStatus = WhitelistFilter.all,
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  factory WhitelistState.initial() => const WhitelistState();

  WhitelistState copyWith({
    List<WhitelistModel>? entries,
    List<WhitelistModel>? filteredEntries,
    String? searchQuery,
    WhitelistFilter? filterStatus,
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
      filterStatus: filterStatus ?? this.filterStatus,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }

  // Computed properties for counts
  int get allCount => entries.length;
  int get registeredCount => entries.where((e) => e.isRegistered).length;
  int get notRegisteredCount => entries.where((e) => !e.isRegistered).length;

  @override
  List<Object?> get props => [
        entries,
        filteredEntries,
        searchQuery,
        filterStatus,
        isLoading,
        errorMessage,
        successMessage,
      ];
}
