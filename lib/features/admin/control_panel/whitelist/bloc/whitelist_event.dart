part of 'whitelist_bloc.dart';

/// Whitelist events
abstract class WhitelistEvent extends Equatable {
  const WhitelistEvent();

  @override
  List<Object?> get props => [];
}

/// Load whitelist
class WhitelistLoadRequested extends WhitelistEvent {
  const WhitelistLoadRequested();
}

/// Add email to whitelist
class WhitelistAddRequested extends WhitelistEvent {
  final String email;
  final UserRole role;
  final String addedBy;

  const WhitelistAddRequested({
    required this.email,
    required this.role,
    required this.addedBy,
  });

  @override
  List<Object?> get props => [email, role, addedBy];
}

/// Remove email from whitelist
class WhitelistRemoveRequested extends WhitelistEvent {
  final String entryId;

  const WhitelistRemoveRequested({required this.entryId});

  @override
  List<Object?> get props => [entryId];
}

/// Search whitelist
class WhitelistSearchRequested extends WhitelistEvent {
  final String query;

  const WhitelistSearchRequested({required this.query});

  @override
  List<Object?> get props => [query];
}

/// Clear search
class WhitelistSearchCleared extends WhitelistEvent {
  const WhitelistSearchCleared();
}

/// Filter by status
class WhitelistFilterChanged extends WhitelistEvent {
  final WhitelistFilter filter;

  const WhitelistFilterChanged({required this.filter});

  @override
  List<Object?> get props => [filter];
}

/// Delete all registered emails
class WhitelistDeleteAllRegisteredRequested extends WhitelistEvent {
  const WhitelistDeleteAllRegisteredRequested();
}

/// Internal: Data received from stream
class _WhitelistDataReceived extends WhitelistEvent {
  final List<WhitelistModel> entries;

  const _WhitelistDataReceived({required this.entries});

  @override
  List<Object?> get props => [entries];
}

/// Internal: Error received from stream
class _WhitelistErrorReceived extends WhitelistEvent {
  const _WhitelistErrorReceived();
}
