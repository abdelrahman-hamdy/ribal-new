import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../../data/models/settings_model.dart';
import '../../../../../data/repositories/settings_repository.dart';

part 'settings_event.dart';
part 'settings_state.dart';

@injectable
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsRepository _settingsRepository;
  StreamSubscription? _settingsSubscription;

  SettingsBloc(this._settingsRepository) : super(SettingsState.initial()) {
    on<SettingsLoadRequested>(_onLoadRequested);
    on<SettingsUpdateRequested>(_onUpdateRequested);
    on<SettingsRecurringTimeChanged>(_onRecurringTimeChanged);
    on<SettingsDeadlineChanged>(_onDeadlineChanged);
  }

  Future<void> _onLoadRequested(
    SettingsLoadRequested event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      await _settingsSubscription?.cancel();

      _settingsSubscription = _settingsRepository.streamSettings().listen(
        (settings) {
          emit(state.copyWith(
            settings: settings,
            isLoading: false,
          ));
        },
        onError: (error) {
          emit(state.copyWith(
            isLoading: false,
            errorMessage: 'فشل في تحميل الإعدادات',
          ));
        },
      );
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'فشل في تحميل الإعدادات',
      ));
    }
  }

  Future<void> _onUpdateRequested(
    SettingsUpdateRequested event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true, clearSuccess: true));

    try {
      await _settingsRepository.updateSettings(event.settings);
      emit(state.copyWith(
        isLoading: false,
        successMessage: 'تم حفظ الإعدادات بنجاح',
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'فشل في حفظ الإعدادات',
      ));
    }
  }

  Future<void> _onRecurringTimeChanged(
    SettingsRecurringTimeChanged event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(clearError: true, clearSuccess: true));

    try {
      await _settingsRepository.updateRecurringTaskTime(event.time);
      emit(state.copyWith(
        successMessage: 'تم تحديث وقت المهام المتكررة',
      ));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'فشل في تحديث الإعدادات',
      ));
    }
  }

  Future<void> _onDeadlineChanged(
    SettingsDeadlineChanged event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(clearError: true, clearSuccess: true));

    try {
      await _settingsRepository.updateTaskDeadline(event.time);
      emit(state.copyWith(
        successMessage: 'تم تحديث الموعد النهائي',
      ));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'فشل في تحديث الإعدادات',
      ));
    }
  }

  @override
  Future<void> close() {
    _settingsSubscription?.cancel();
    return super.close();
  }
}
