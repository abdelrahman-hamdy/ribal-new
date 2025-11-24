part of 'invitations_bloc.dart';

/// Invitations events
abstract class InvitationsEvent extends Equatable {
  const InvitationsEvent();

  @override
  List<Object?> get props => [];
}

/// Load invitations
class InvitationsLoadRequested extends InvitationsEvent {
  const InvitationsLoadRequested();
}

/// Create new invitation
class InvitationCreateRequested extends InvitationsEvent {
  final UserRole role;
  final String createdBy;

  const InvitationCreateRequested({
    required this.role,
    required this.createdBy,
  });

  @override
  List<Object?> get props => [role, createdBy];
}

/// Delete invitation
class InvitationDeleteRequested extends InvitationsEvent {
  final String code;

  const InvitationDeleteRequested({required this.code});

  @override
  List<Object?> get props => [code];
}

/// Filter invitations
class InvitationsFilterChanged extends InvitationsEvent {
  final bool? showUsedOnly;

  const InvitationsFilterChanged({this.showUsedOnly});

  @override
  List<Object?> get props => [showUsedOnly];
}

/// Internal: Data received from stream
class _InvitationsDataReceived extends InvitationsEvent {
  final List<InvitationModel> invitations;

  const _InvitationsDataReceived({required this.invitations});

  @override
  List<Object?> get props => [invitations];
}

/// Internal: Error received from stream
class _InvitationsErrorReceived extends InvitationsEvent {
  const _InvitationsErrorReceived();
}
