part of 'user_profile_bloc.dart';

/// User profile events
abstract class UserProfileEvent extends Equatable {
  const UserProfileEvent();

  @override
  List<Object?> get props => [];
}

/// Load user profile
class UserProfileLoadRequested extends UserProfileEvent {
  final String userId;
  final String currentUserId;

  const UserProfileLoadRequested({
    required this.userId,
    required this.currentUserId,
  });

  @override
  List<Object?> get props => [userId, currentUserId];
}

/// Change time filter
class UserProfileTimeFilterChanged extends UserProfileEvent {
  final TimeFilter filter;

  const UserProfileTimeFilterChanged({required this.filter});

  @override
  List<Object?> get props => [filter];
}

/// Mark assignment as done
class UserProfileMarkAssignmentDone extends UserProfileEvent {
  final String assignmentId;

  const UserProfileMarkAssignmentDone({required this.assignmentId});

  @override
  List<Object?> get props => [assignmentId];
}

/// Internal: User data received
class _UserDataReceived extends UserProfileEvent {
  final UserModel? user;

  const _UserDataReceived({required this.user});

  @override
  List<Object?> get props => [user];
}

/// Internal: Assignments data received
class _AssignmentsDataReceived extends UserProfileEvent {
  final List<AssignmentModel> assignments;

  const _AssignmentsDataReceived({required this.assignments});

  @override
  List<Object?> get props => [assignments];
}

/// Internal: Error occurred
class _UserProfileError extends UserProfileEvent {
  final String message;

  const _UserProfileError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Convert user role (employee <-> manager)
class UserProfileRoleConversionRequested extends UserProfileEvent {
  final String userId;
  final UserRole newRole;

  const UserProfileRoleConversionRequested({
    required this.userId,
    required this.newRole,
  });

  @override
  List<Object?> get props => [userId, newRole];
}

/// Update manager's assigned groups
class UserProfileManagerGroupsUpdated extends UserProfileEvent {
  final String userId;
  final List<String> groupIds;
  final bool canAssignToAll;

  const UserProfileManagerGroupsUpdated({
    required this.userId,
    required this.groupIds,
    required this.canAssignToAll,
  });

  @override
  List<Object?> get props => [userId, groupIds, canAssignToAll];
}

/// Load all groups (for group assignment dialog)
class UserProfileGroupsLoadRequested extends UserProfileEvent {
  const UserProfileGroupsLoadRequested();
}

/// Internal: Groups data received
class _GroupsDataReceived extends UserProfileEvent {
  final List<GroupModel> groups;

  const _GroupsDataReceived({required this.groups});

  @override
  List<Object?> get props => [groups];
}
