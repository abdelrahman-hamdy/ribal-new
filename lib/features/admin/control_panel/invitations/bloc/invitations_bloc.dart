import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../../data/models/invitation_model.dart';
import '../../../../../data/models/user_model.dart';
import '../../../../../data/repositories/invitation_repository.dart';

part 'invitations_event.dart';
part 'invitations_state.dart';

@injectable
class InvitationsBloc extends Bloc<InvitationsEvent, InvitationsState> {
  final InvitationRepository _invitationRepository;
  StreamSubscription? _invitationsSubscription;

  InvitationsBloc(this._invitationRepository) : super(InvitationsState.initial()) {
    on<InvitationsLoadRequested>(_onLoadRequested);
    on<_InvitationsDataReceived>(_onDataReceived);
    on<_InvitationsErrorReceived>(_onErrorReceived);
    on<InvitationCreateRequested>(_onCreateRequested);
    on<InvitationDeleteRequested>(_onDeleteRequested);
    on<InvitationsFilterChanged>(_onFilterChanged);
  }

  Future<void> _onLoadRequested(
    InvitationsLoadRequested event,
    Emitter<InvitationsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    await _invitationsSubscription?.cancel();

    _invitationsSubscription = _invitationRepository.streamAllInvitations().listen(
      (invitations) => add(_InvitationsDataReceived(invitations: invitations)),
      onError: (error) => add(const _InvitationsErrorReceived()),
    );
  }

  void _onDataReceived(
    _InvitationsDataReceived event,
    Emitter<InvitationsState> emit,
  ) {
    emit(state.copyWith(
      invitations: event.invitations,
      filteredInvitations: _applyFilter(event.invitations, state.showUsedOnly),
      isLoading: false,
    ));
  }

  void _onErrorReceived(
    _InvitationsErrorReceived event,
    Emitter<InvitationsState> emit,
  ) {
    emit(state.copyWith(
      isLoading: false,
      errorMessage: 'فشل في تحميل الدعوات',
    ));
  }

  Future<void> _onCreateRequested(
    InvitationCreateRequested event,
    Emitter<InvitationsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true, clearSuccess: true));

    try {
      final invitation = await _invitationRepository.createInvitation(
        role: event.role,
        createdBy: event.createdBy,
      );
      emit(state.copyWith(
        isLoading: false,
        successMessage: 'تم إنشاء كود الدعوة: ${invitation.code}',
        lastCreatedCode: invitation.code,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'فشل في إنشاء كود الدعوة',
      ));
    }
  }

  Future<void> _onDeleteRequested(
    InvitationDeleteRequested event,
    Emitter<InvitationsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true, clearSuccess: true));

    try {
      await _invitationRepository.deleteInvitation(event.code);
      emit(state.copyWith(
        isLoading: false,
        successMessage: 'تم حذف كود الدعوة بنجاح',
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'فشل في حذف كود الدعوة',
      ));
    }
  }

  void _onFilterChanged(
    InvitationsFilterChanged event,
    Emitter<InvitationsState> emit,
  ) {
    emit(state.copyWith(
      showUsedOnly: event.showUsedOnly,
      filteredInvitations: _applyFilter(state.invitations, event.showUsedOnly),
    ));
  }

  List<InvitationModel> _applyFilter(List<InvitationModel> invitations, bool? showUsedOnly) {
    if (showUsedOnly == null) return invitations;
    return invitations.where((i) => i.used == showUsedOnly).toList();
  }

  @override
  Future<void> close() {
    _invitationsSubscription?.cancel();
    return super.close();
  }
}
