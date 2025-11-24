part of 'groups_bloc.dart';

/// Groups events
abstract class GroupsEvent extends Equatable {
  const GroupsEvent();

  @override
  List<Object?> get props => [];
}

/// Load all groups
class GroupsLoadRequested extends GroupsEvent {
  const GroupsLoadRequested();
}

/// Create new group
class GroupCreateRequested extends GroupsEvent {
  final String name;
  final String createdBy;

  const GroupCreateRequested({
    required this.name,
    required this.createdBy,
  });

  @override
  List<Object?> get props => [name, createdBy];
}

/// Update group
class GroupUpdateRequested extends GroupsEvent {
  final GroupModel group;

  const GroupUpdateRequested({required this.group});

  @override
  List<Object?> get props => [group];
}

/// Delete group
class GroupDeleteRequested extends GroupsEvent {
  final String groupId;

  const GroupDeleteRequested({required this.groupId});

  @override
  List<Object?> get props => [groupId];
}

/// Search groups
class GroupsSearchRequested extends GroupsEvent {
  final String query;

  const GroupsSearchRequested({required this.query});

  @override
  List<Object?> get props => [query];
}

/// Clear search
class GroupsSearchCleared extends GroupsEvent {
  const GroupsSearchCleared();
}

/// Load members for a specific group
class GroupMembersLoadRequested extends GroupsEvent {
  final String groupId;

  const GroupMembersLoadRequested({required this.groupId});

  @override
  List<Object?> get props => [groupId];
}

/// Load all users (for member selection)
class AllUsersLoadRequested extends GroupsEvent {
  const AllUsersLoadRequested();
}

/// Add a user to a group
class GroupMemberAddRequested extends GroupsEvent {
  final String groupId;
  final String userId;

  const GroupMemberAddRequested({
    required this.groupId,
    required this.userId,
  });

  @override
  List<Object?> get props => [groupId, userId];
}

/// Remove a user from a group
class GroupMemberRemoveRequested extends GroupsEvent {
  final String groupId;
  final String userId;

  const GroupMemberRemoveRequested({
    required this.groupId,
    required this.userId,
  });

  @override
  List<Object?> get props => [groupId, userId];
}

/// Batch update group members (set the complete list of members)
class GroupMembersBatchUpdateRequested extends GroupsEvent {
  final String groupId;
  final List<String> userIds;

  const GroupMembersBatchUpdateRequested({
    required this.groupId,
    required this.userIds,
  });

  @override
  List<Object?> get props => [groupId, userIds];
}
