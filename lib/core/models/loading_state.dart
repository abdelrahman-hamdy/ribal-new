/// Enhanced loading state for better UX
///
/// Differentiates between initial load, refresh, and pagination
/// to show appropriate loading indicators
enum LoadingState {
  /// Initial state - no loading
  idle,

  /// First time loading data (show full-screen loading)
  initial,

  /// Refreshing existing data (show pull-to-refresh indicator)
  refreshing,

  /// Loading more data (show bottom loading indicator)
  loadingMore,

  /// Loading completed successfully
  success,

  /// Loading failed with error
  error;

  /// Check if any loading is in progress
  bool get isLoading =>
      this == LoadingState.initial ||
      this == LoadingState.refreshing ||
      this == LoadingState.loadingMore;

  /// Check if this is the first load
  bool get isInitialLoad => this == LoadingState.initial;

  /// Check if this is a refresh operation
  bool get isRefreshing => this == LoadingState.refreshing;

  /// Check if loading more data for pagination
  bool get isLoadingMore => this == LoadingState.loadingMore;

  /// Check if completed successfully
  bool get isSuccess => this == LoadingState.success;

  /// Check if failed with error
  bool get hasError => this == LoadingState.error;

  /// Check if idle (no operation)
  bool get isIdle => this == LoadingState.idle;
}
