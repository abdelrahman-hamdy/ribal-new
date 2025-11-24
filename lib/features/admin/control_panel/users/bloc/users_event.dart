part of 'users_bloc.dart';

/// Users events
abstract class UsersEvent extends Equatable {
  const UsersEvent();

  @override
  List<Object?> get props => [];
}

/// Load all users
class UsersLoadRequested extends UsersEvent {
  const UsersLoadRequested();
}

/// Load users by role
class UsersLoadByRoleRequested extends UsersEvent {
  final UserRole role;

  const UsersLoadByRoleRequested({required this.role});

  @override
  List<Object?> get props => [role];
}

/// Load users by group
class UsersLoadByGroupRequested extends UsersEvent {
  final String groupId;

  const UsersLoadByGroupRequested({required this.groupId});

  @override
  List<Object?> get props => [groupId];
}

/// Update user role
class UserRoleUpdateRequested extends UsersEvent {
  final String userId;
  final UserRole newRole;

  const UserRoleUpdateRequested({
    required this.userId,
    required this.newRole,
  });

  @override
  List<Object?> get props => [userId, newRole];
}

/// Update user group
class UserGroupUpdateRequested extends UsersEvent {
  final String userId;
  final String? groupId;

  const UserGroupUpdateRequested({
    required this.userId,
    required this.groupId,
  });

  @override
  List<Object?> get props => [userId, groupId];
}

/// Update manager permissions
class ManagerPermissionsUpdateRequested extends UsersEvent {
  final String userId;
  final bool canAssignToAll;
  final List<String> managedGroupIds;

  const ManagerPermissionsUpdateRequested({
    required this.userId,
    required this.canAssignToAll,
    required this.managedGroupIds,
  });

  @override
  List<Object?> get props => [userId, canAssignToAll, managedGroupIds];
}

/// Search users
class UsersSearchRequested extends UsersEvent {
  final String query;

  const UsersSearchRequested({required this.query});

  @override
  List<Object?> get props => [query];
}

/// Clear search
class UsersSearchCleared extends UsersEvent {
  const UsersSearchCleared();
}

/// Filter users by role
class UsersFilterByRoleChanged extends UsersEvent {
  final UserRole? role;

  const UsersFilterByRoleChanged({this.role});

  @override
  List<Object?> get props => [role];
}

/// Internal: Data received from stream
class _UsersDataReceived extends UsersEvent {
  final List<UserModel> users;

  const _UsersDataReceived({required this.users});

  @override
  List<Object?> get props => [users];
}

/// Internal: Error received from stream
class _UsersErrorReceived extends UsersEvent {
  const _UsersErrorReceived();
}
