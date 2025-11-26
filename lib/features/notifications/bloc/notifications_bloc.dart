import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../data/models/notification_model.dart';
import '../../../data/repositories/notification_repository.dart';

part 'notifications_event.dart';
part 'notifications_state.dart';

@injectable
class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final NotificationRepository _notificationRepository;
  StreamSubscription<List<NotificationModel>>? _notificationsSubscription;

  NotificationsBloc(this._notificationRepository)
      : super(NotificationsState.initial()) {
    on<NotificationsLoadRequested>(_onLoadRequested);
    on<_NotificationsUpdated>(_onNotificationsUpdated);
    on<NotificationsPanelOpened>(_onPanelOpened);
    on<NotificationMarkAsReadRequested>(_onMarkAsReadRequested);
    on<NotificationsMarkAllAsReadRequested>(_onMarkAllAsReadRequested);
    on<NotificationDeleteRequested>(_onDeleteRequested);
    on<NotificationsDeleteAllRequested>(_onDeleteAllRequested);
  }

  Future<void> _onLoadRequested(
    NotificationsLoadRequested event,
    Emitter<NotificationsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    await _notificationsSubscription?.cancel();

    _notificationsSubscription = _notificationRepository
        .streamNotificationsForUser(event.userId)
        .listen(
      (notifications) {
        if (!isClosed) {
          add(_NotificationsUpdated(notifications));
        }
      },
      onError: (error) {
        if (!isClosed) {
          add(const _NotificationsUpdated([], error: 'فشل في تحميل الإشعارات'));
        }
      },
    );
  }

  void _onNotificationsUpdated(
    _NotificationsUpdated event,
    Emitter<NotificationsState> emit,
  ) {
    if (event.error != null) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: event.error,
      ));
    } else {
      emit(state.copyWith(
        notifications: event.notifications,
        isLoading: false,
        clearError: true,
      ));
    }
  }

  Future<void> _onPanelOpened(
    NotificationsPanelOpened event,
    Emitter<NotificationsState> emit,
  ) async {
    try {
      await _notificationRepository.markAllAsSeen(event.userId);
    } catch (e) {
      // Silently fail - not critical
    }
  }

  Future<void> _onMarkAsReadRequested(
    NotificationMarkAsReadRequested event,
    Emitter<NotificationsState> emit,
  ) async {
    emit(state.copyWith(clearError: true, clearSuccess: true));

    try {
      await _notificationRepository.markAsRead(event.notificationId);
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'فشل في تحديث الإشعار',
      ));
    }
  }

  Future<void> _onMarkAllAsReadRequested(
    NotificationsMarkAllAsReadRequested event,
    Emitter<NotificationsState> emit,
  ) async {
    emit(state.copyWith(clearError: true, clearSuccess: true));

    try {
      await _notificationRepository.markAllAsRead(event.userId);
      emit(state.copyWith(
        successMessage: 'تم تعليم جميع الإشعارات كمقروءة',
      ));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'فشل في تحديث الإشعارات',
      ));
    }
  }

  Future<void> _onDeleteRequested(
    NotificationDeleteRequested event,
    Emitter<NotificationsState> emit,
  ) async {
    emit(state.copyWith(clearError: true, clearSuccess: true));

    try {
      await _notificationRepository.deleteNotification(event.notificationId);
      emit(state.copyWith(
        successMessage: 'تم حذف الإشعار',
      ));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'فشل في حذف الإشعار',
      ));
    }
  }

  Future<void> _onDeleteAllRequested(
    NotificationsDeleteAllRequested event,
    Emitter<NotificationsState> emit,
  ) async {
    emit(state.copyWith(clearError: true, clearSuccess: true));

    try {
      await _notificationRepository.deleteAllNotifications(event.userId);
      emit(state.copyWith(
        successMessage: 'تم حذف جميع الإشعارات',
      ));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'فشل في حذف الإشعارات',
      ));
    }
  }

  @override
  Future<void> close() {
    _notificationsSubscription?.cancel();
    return super.close();
  }
}
