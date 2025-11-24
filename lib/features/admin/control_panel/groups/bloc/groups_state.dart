part of 'groups_bloc.dart';

/// Groups state
class GroupsState extends Equatable {
  final List<GroupModel> groups;
  final List<GroupModel> filteredGroups;
  final Map<String, int> memberCounts;
  final Map<String, List<UserModel>> groupMembers;
  final List<UserModel> allUsers;
  final String searchQuery;
  final bool isLoading;
  final bool isLoadingMembers;
  final String? errorMessage;
  final String? successMessage;

  const GroupsState({
    this.groups = const [],
    this.filteredGroups = const [],
    this.memberCounts = const {},
    this.groupMembers = const {},
    this.allUsers = const [],
    this.searchQuery = '',
    this.isLoading = false,
    this.isLoadingMembers = false,
    this.errorMessage,
    this.successMessage,
  });

  factory GroupsState.initial() => const GroupsState();

  GroupsState copyWith({
    List<GroupModel>? groups,
    List<GroupModel>? filteredGroups,
    Map<String, int>? memberCounts,
    Map<String, List<UserModel>>? groupMembers,
    List<UserModel>? allUsers,
    String? searchQuery,
    bool? isLoading,
    bool? isLoadingMembers,
    String? errorMessage,
    bool clearError = false,
    String? successMessage,
    bool clearSuccess = false,
  }) {
    return GroupsState(
      groups: groups ?? this.groups,
      filteredGroups: filteredGroups ?? this.filteredGroups,
      memberCounts: memberCounts ?? this.memberCounts,
      groupMembers: groupMembers ?? this.groupMembers,
      allUsers: allUsers ?? this.allUsers,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMembers: isLoadingMembers ?? this.isLoadingMembers,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }

  @override
  List<Object?> get props => [
        groups,
        filteredGroups,
        memberCounts,
        groupMembers,
        allUsers,
        searchQuery,
        isLoading,
        isLoadingMembers,
        errorMessage,
        successMessage,
      ];

  /// Get group by ID
  GroupModel? getGroupById(String id) {
    try {
      return groups.firstWhere((g) => g.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Get member count for a group
  int getMemberCount(String groupId) {
    return memberCounts[groupId] ?? 0;
  }

  /// Get members for a group
  List<UserModel> getMembers(String groupId) {
    return groupMembers[groupId] ?? [];
  }

  /// Get users not in any group (available for assignment)
  List<UserModel> get availableUsers {
    return allUsers.where((u) => u.groupId == null || u.groupId!.isEmpty).toList();
  }
}
