part of 'settings_bloc.dart';

/// Settings events
abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

/// Load settings
class SettingsLoadRequested extends SettingsEvent {
  const SettingsLoadRequested();
}

/// Update all settings
class SettingsUpdateRequested extends SettingsEvent {
  final SettingsModel settings;

  const SettingsUpdateRequested({required this.settings});

  @override
  List<Object?> get props => [settings];
}

/// Change recurring task time
class SettingsRecurringTimeChanged extends SettingsEvent {
  final String time;

  const SettingsRecurringTimeChanged({required this.time});

  @override
  List<Object?> get props => [time];
}

/// Change task deadline
class SettingsDeadlineChanged extends SettingsEvent {
  final String time;

  const SettingsDeadlineChanged({required this.time});

  @override
  List<Object?> get props => [time];
}
