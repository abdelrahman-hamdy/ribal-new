import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../../data/models/whitelist_model.dart';
import '../../../../../data/models/user_model.dart';
import '../../../../../data/repositories/whitelist_repository.dart';

part 'whitelist_event.dart';
part 'whitelist_state.dart';

@injectable
class WhitelistBloc extends Bloc<WhitelistEvent, WhitelistState> {
  final WhitelistRepository _whitelistRepository;
  StreamSubscription? _whitelistSubscription;

  WhitelistBloc(this._whitelistRepository) : super(WhitelistState.initial()) {
    on<WhitelistLoadRequested>(_onLoadRequested);
    on<_WhitelistDataReceived>(_onDataReceived);
    on<_WhitelistErrorReceived>(_onErrorReceived);
    on<WhitelistAddRequested>(_onAddRequested);
    on<WhitelistRemoveRequested>(_onRemoveRequested);
    on<WhitelistSearchRequested>(_onSearchRequested);
    on<WhitelistSearchCleared>(_onSearchCleared);
    on<WhitelistFilterChanged>(_onFilterChanged);
    on<WhitelistDeleteAllRegisteredRequested>(_onDeleteAllRegisteredRequested);
  }

  Future<void> _onLoadRequested(
    WhitelistLoadRequested event,
    Emitter<WhitelistState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    await _whitelistSubscription?.cancel();

    _whitelistSubscription = _whitelistRepository.streamAllWhitelistEntries().listen(
      (entries) {
        if (!isClosed) {
          add(_WhitelistDataReceived(entries: entries));
        }
      },
      onError: (error) {
        if (!isClosed) {
          add(const _WhitelistErrorReceived());
        }
      },
    );
  }

  void _onDataReceived(
    _WhitelistDataReceived event,
    Emitter<WhitelistState> emit,
  ) {
    emit(state.copyWith(
      entries: event.entries,
      filteredEntries: _applyFilters(event.entries, state.searchQuery, state.filterStatus),
      isLoading: false,
    ));
  }

  void _onErrorReceived(
    _WhitelistErrorReceived event,
    Emitter<WhitelistState> emit,
  ) {
    emit(state.copyWith(
      isLoading: false,
      errorMessage: 'فشل في تحميل القائمة البيضاء',
    ));
  }

  Future<void> _onAddRequested(
    WhitelistAddRequested event,
    Emitter<WhitelistState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true, clearSuccess: true));

    try {
      // Check if email already exists
      final exists = await _whitelistRepository.isEmailWhitelisted(event.email);
      if (exists) {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: 'البريد الإلكتروني مضاف بالفعل',
        ));
        return;
      }

      final entry = WhitelistModel(
        id: '',
        email: event.email,
        role: event.role,
        createdBy: event.addedBy,
        createdAt: DateTime.now(),
      );
      await _whitelistRepository.createWhitelistEntry(entry);
      emit(state.copyWith(
        isLoading: false,
        successMessage: 'تمت إضافة البريد الإلكتروني بنجاح',
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'فشل في إضافة البريد الإلكتروني',
      ));
    }
  }

  Future<void> _onRemoveRequested(
    WhitelistRemoveRequested event,
    Emitter<WhitelistState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true, clearSuccess: true));

    try {
      await _whitelistRepository.deleteWhitelistEntry(event.entryId);
      emit(state.copyWith(
        isLoading: false,
        successMessage: 'تمت إزالة البريد الإلكتروني بنجاح',
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'فشل في إزالة البريد الإلكتروني',
      ));
    }
  }

  void _onSearchRequested(
    WhitelistSearchRequested event,
    Emitter<WhitelistState> emit,
  ) {
    final query = event.query.toLowerCase().trim();
    emit(state.copyWith(
      searchQuery: query,
      filteredEntries: _applyFilters(state.entries, query, state.filterStatus),
    ));
  }

  void _onSearchCleared(
    WhitelistSearchCleared event,
    Emitter<WhitelistState> emit,
  ) {
    emit(state.copyWith(
      searchQuery: '',
      filteredEntries: _applyFilters(state.entries, '', state.filterStatus),
    ));
  }

  void _onFilterChanged(
    WhitelistFilterChanged event,
    Emitter<WhitelistState> emit,
  ) {
    emit(state.copyWith(
      filterStatus: event.filter,
      filteredEntries: _applyFilters(state.entries, state.searchQuery, event.filter),
    ));
  }

  Future<void> _onDeleteAllRegisteredRequested(
    WhitelistDeleteAllRegisteredRequested event,
    Emitter<WhitelistState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true, clearSuccess: true));

    try {
      final deletedCount = await _whitelistRepository.deleteAllRegisteredEmails();
      emit(state.copyWith(
        isLoading: false,
        successMessage: 'تم حذف $deletedCount بريد إلكتروني مسجل',
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'فشل في حذف البريدات المسجلة',
      ));
    }
  }

  List<WhitelistModel> _applyFilters(
    List<WhitelistModel> entries,
    String query,
    WhitelistFilter filter,
  ) {
    // First apply status filter
    var filtered = entries;
    switch (filter) {
      case WhitelistFilter.registered:
        filtered = entries.where((e) => e.isRegistered).toList();
        break;
      case WhitelistFilter.notRegistered:
        filtered = entries.where((e) => !e.isRegistered).toList();
        break;
      case WhitelistFilter.all:
        filtered = entries;
        break;
    }

    // Then apply search query
    if (query.isNotEmpty) {
      filtered = filtered.where((e) => e.email.toLowerCase().contains(query)).toList();
    }

    return filtered;
  }

  @override
  Future<void> close() {
    _whitelistSubscription?.cancel();
    return super.close();
  }
}
