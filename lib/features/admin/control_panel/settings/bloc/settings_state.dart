part of 'settings_bloc.dart';

/// Settings state
class SettingsState extends Equatable {
  final SettingsModel? settings;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  const SettingsState({
    this.settings,
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  factory SettingsState.initial() => const SettingsState();

  SettingsState copyWith({
    SettingsModel? settings,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    String? successMessage,
    bool clearSuccess = false,
  }) {
    return SettingsState(
      settings: settings ?? this.settings,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }

  @override
  List<Object?> get props => [
        settings,
        isLoading,
        errorMessage,
        successMessage,
      ];

  /// Get recurring task time (formatted)
  String get recurringTaskTime => settings?.recurringTaskTime ?? '08:00';

  /// Get task deadline (formatted)
  String get taskDeadline => settings?.taskDeadline ?? '20:00';
}
