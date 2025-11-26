part of 'theme_bloc.dart';

/// Theme events
sealed class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object?> get props => [];
}

/// Load theme preference from storage
class ThemeLoadRequested extends ThemeEvent {
  const ThemeLoadRequested();
}

/// Change theme mode
class ThemeModeChanged extends ThemeEvent {
  const ThemeModeChanged(this.mode);

  final AppThemeMode mode;

  @override
  List<Object?> get props => [mode];
}
