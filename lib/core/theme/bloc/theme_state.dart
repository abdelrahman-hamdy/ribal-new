part of 'theme_bloc.dart';

/// Theme state
class ThemeState extends Equatable {
  const ThemeState({
    this.mode = AppThemeMode.system,
    this.isLoading = false,
  });

  /// Current theme mode
  final AppThemeMode mode;

  /// Whether theme is being loaded
  final bool isLoading;

  /// Get the Flutter ThemeMode based on AppThemeMode
  ThemeMode get themeMode {
    switch (mode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  /// Initial state
  factory ThemeState.initial() => const ThemeState(isLoading: true);

  ThemeState copyWith({
    AppThemeMode? mode,
    bool? isLoading,
  }) {
    return ThemeState(
      mode: mode ?? this.mode,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [mode, isLoading];
}
