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
  }

  Future<void> _onLoadRequested(
    WhitelistLoadRequested event,
    Emitter<WhitelistState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    await _whitelistSubscription?.cancel();

    _whitelistSubscription = _whitelistRepository.streamAllWhitelistEntries().listen(
      (entries) => add(_WhitelistDataReceived(entries: entries)),
      onError: (error) => add(const _WhitelistErrorReceived()),
    );
  }

  void _onDataReceived(
    _WhitelistDataReceived event,
    Emitter<WhitelistState> emit,
  ) {
    emit(state.copyWith(
      entries: event.entries,
      filteredEntries: _applySearch(event.entries, state.searchQuery),
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
      filteredEntries: _applySearch(state.entries, query),
    ));
  }

  void _onSearchCleared(
    WhitelistSearchCleared event,
    Emitter<WhitelistState> emit,
  ) {
    emit(state.copyWith(
      searchQuery: '',
      filteredEntries: state.entries,
    ));
  }

  List<WhitelistModel> _applySearch(List<WhitelistModel> entries, String query) {
    if (query.isEmpty) return entries;
    return entries.where((e) => e.email.toLowerCase().contains(query)).toList();
  }

  @override
  Future<void> close() {
    _whitelistSubscription?.cancel();
    return super.close();
  }
}
