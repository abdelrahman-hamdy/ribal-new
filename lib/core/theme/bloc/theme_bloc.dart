import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../services/hive_cache_service.dart';

part 'theme_event.dart';
part 'theme_state.dart';

/// Theme mode options
enum AppThemeMode {
  /// Light theme
  light,

  /// Dark theme
  dark,

  /// Follow system theme
  system,
}

/// Extension to convert AppThemeMode to/from string for storage
extension AppThemeModeExtension on AppThemeMode {
  String get value {
    switch (this) {
      case AppThemeMode.light:
        return 'light';
      case AppThemeMode.dark:
        return 'dark';
      case AppThemeMode.system:
        return 'system';
    }
  }

  static AppThemeMode fromString(String? value) {
    switch (value) {
      case 'light':
        return AppThemeMode.light;
      case 'dark':
        return AppThemeMode.dark;
      case 'system':
      default:
        return AppThemeMode.system;
    }
  }
}

/// Bloc for managing app theme
@injectable
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc(this._cacheService) : super(ThemeState.initial()) {
    on<ThemeLoadRequested>(_onLoadRequested);
    on<ThemeModeChanged>(_onModeChanged);
  }

  final HiveCacheService _cacheService;

  /// Cache key for theme mode
  static const String _themeModeKey = 'theme_mode';

  Future<void> _onLoadRequested(
    ThemeLoadRequested event,
    Emitter<ThemeState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    try {
      // Load theme mode from cache
      final cachedMode = await _cacheService.get<Map<String, dynamic>>(
        boxName: HiveCacheService.boxSettings,
        key: _themeModeKey,
      );

      final mode = AppThemeModeExtension.fromString(
        cachedMode?['mode'] as String?,
      );

      emit(state.copyWith(
        mode: mode,
        isLoading: false,
      ));
    } catch (e) {
      // Default to system on error
      emit(state.copyWith(
        mode: AppThemeMode.system,
        isLoading: false,
      ));
    }
  }

  Future<void> _onModeChanged(
    ThemeModeChanged event,
    Emitter<ThemeState> emit,
  ) async {
    // Update state immediately for responsive UI
    emit(state.copyWith(mode: event.mode));

    // Persist to cache
    try {
      await _cacheService.put(
        boxName: HiveCacheService.boxSettings,
        key: _themeModeKey,
        value: {'mode': event.mode.value},
      );
    } catch (e) {
      // Silently fail on cache error - UI already updated
    }
  }
}
