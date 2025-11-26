import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../services/hive_cache_service.dart';

part 'locale_event.dart';
part 'locale_state.dart';

/// App locale options
enum AppLocale {
  /// Arabic
  arabic,

  /// English
  english,
}

/// Extension to convert AppLocale to/from string for storage
extension AppLocaleExtension on AppLocale {
  String get value {
    switch (this) {
      case AppLocale.arabic:
        return 'ar';
      case AppLocale.english:
        return 'en';
    }
  }

  Locale get locale {
    switch (this) {
      case AppLocale.arabic:
        return const Locale('ar');
      case AppLocale.english:
        return const Locale('en');
    }
  }

  String get displayName {
    switch (this) {
      case AppLocale.arabic:
        return 'العربية';
      case AppLocale.english:
        return 'English';
    }
  }

  static AppLocale fromString(String? value) {
    switch (value) {
      case 'en':
        return AppLocale.english;
      case 'ar':
      default:
        return AppLocale.arabic;
    }
  }
}

/// Bloc for managing app locale
@injectable
class LocaleBloc extends Bloc<LocaleEvent, LocaleState> {
  LocaleBloc(this._cacheService) : super(LocaleState.initial()) {
    on<LocaleLoadRequested>(_onLoadRequested);
    on<LocaleChanged>(_onLocaleChanged);
  }

  final HiveCacheService _cacheService;

  /// Cache key for locale
  static const String _localeKey = 'app_locale';

  Future<void> _onLoadRequested(
    LocaleLoadRequested event,
    Emitter<LocaleState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    try {
      // Load locale from cache
      final cachedLocale = await _cacheService.get<Map<String, dynamic>>(
        boxName: HiveCacheService.boxSettings,
        key: _localeKey,
      );

      final appLocale = AppLocaleExtension.fromString(
        cachedLocale?['locale'] as String?,
      );

      emit(state.copyWith(
        appLocale: appLocale,
        isLoading: false,
      ));
    } catch (e) {
      // Default to Arabic on error
      emit(state.copyWith(
        appLocale: AppLocale.arabic,
        isLoading: false,
      ));
    }
  }

  Future<void> _onLocaleChanged(
    LocaleChanged event,
    Emitter<LocaleState> emit,
  ) async {
    // Update state immediately for responsive UI
    emit(state.copyWith(appLocale: event.appLocale));

    // Persist to cache
    try {
      await _cacheService.put(
        boxName: HiveCacheService.boxSettings,
        key: _localeKey,
        value: {'locale': event.appLocale.value},
      );
    } catch (e) {
      // Silently fail on cache error - UI already updated
    }
  }
}
