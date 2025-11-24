import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../../data/models/group_model.dart';
import '../../../../../data/models/user_model.dart';
import '../../../../../data/repositories/group_repository.dart';
import '../../../../../data/repositories/user_repository.dart';

part 'groups_event.dart';
part 'groups_state.dart';

@injectable
class GroupsBloc extends Bloc<GroupsEvent, GroupsState> {
  final GroupRepository _groupRepository;
  final UserRepository _userRepository;
  StreamSubscription? _groupsSubscription;

  GroupsBloc(this._groupRepository, this._userRepository) : super(GroupsState.initial()) {
    on<GroupsLoadRequested>(_onLoadRequested);
    on<GroupCreateRequested>(_onCreateRequested);
    on<GroupUpdateRequested>(_onUpdateRequested);
    on<GroupDeleteRequested>(_onDeleteRequested);
    on<GroupsSearchRequested>(_onSearchRequested);
    on<GroupsSearchCleared>(_onSearchCleared);
    on<GroupMembersLoadRequested>(_onMembersLoadRequested);
    on<GroupMemberAddRequested>(_onMemberAddRequested);
    on<GroupMemberRemoveRequested>(_onMemberRemoveRequested);
    on<GroupMembersBatchUpdateRequested>(_onMembersBatchUpdateRequested);
    on<AllUsersLoadRequested>(_onAllUsersLoadRequested);
    on<_MemberCountsLoaded>(_onMemberCountsLoaded);
  }

  Future<void> _onLoadRequested(
    GroupsLoadRequested event,
    Emitter<GroupsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    await _groupsSubscription?.cancel();

    await emit.forEach<List<GroupModel>>(
      _groupRepository.streamAllGroups(),
      onData: (groups) {
        // Load member counts for all groups
        _loadMemberCounts(groups);
        return state.copyWith(
          groups: groups,
          filteredGroups: _applySearch(groups, state.searchQuery),
          isLoading: false,
        );
      },
      onError: (_, __) => state.copyWith(
        isLoading: false,
        errorMessage: 'فشل في تحميل المجموعات',
      ),
    );
  }

  Future<void> _loadMemberCounts(List<GroupModel> groups) async {
    final counts = <String, int>{};
    for (final group in groups) {
      try {
        counts[group.id] = await _userRepository.countUsersByGroup(group.id);
      } catch (_) {
        counts[group.id] = 0;
      }
    }
    add(_MemberCountsLoaded(counts: counts));
  }

  void _onMemberCountsLoaded(
    _MemberCountsLoaded event,
    Emitter<GroupsState> emit,
  ) {
    emit(state.copyWith(memberCounts: event.counts));
  }

  Future<void> _onCreateRequested(
    GroupCreateRequested event,
    Emitter<GroupsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true, clearSuccess: true));

    try {
      final group = GroupModel(
        id: '',
        name: event.name,
        createdBy: event.createdBy,
        createdAt: DateTime.now(),
      );
      await _groupRepository.createGroup(group);
      emit(state.copyWith(
        isLoading: false,
        successMessage: 'تم إنشاء المجموعة بنجاح',
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'فشل في إنشاء المجموعة',
      ));
    }
  }

  Future<void> _onUpdateRequested(
    GroupUpdateRequested event,
    Emitter<GroupsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true, clearSuccess: true));

    try {
      await _groupRepository.updateGroup(event.group);
      emit(state.copyWith(
        isLoading: false,
        successMessage: 'تم تحديث المجموعة بنجاح',
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'فشل في تحديث المجموعة',
      ));
    }
  }

  Future<void> _onDeleteRequested(
    GroupDeleteRequested event,
    Emitter<GroupsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true, clearSuccess: true));

    try {
      // First, remove all users from this group
      final members = await _userRepository.getUsersByGroup(event.groupId);
      for (final member in members) {
        await _userRepository.updateUserGroup(member.id, null);
      }
      // Then delete the group
      await _groupRepository.deleteGroup(event.groupId);
      emit(state.copyWith(
        isLoading: false,
        successMessage: 'تم حذف المجموعة بنجاح',
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'فشل في حذف المجموعة',
      ));
    }
  }

  void _onSearchRequested(
    GroupsSearchRequested event,
    Emitter<GroupsState> emit,
  ) {
    final query = event.query.toLowerCase().trim();
    emit(state.copyWith(
      searchQuery: query,
      filteredGroups: _applySearch(state.groups, query),
    ));
  }

  void _onSearchCleared(
    GroupsSearchCleared event,
    Emitter<GroupsState> emit,
  ) {
    emit(state.copyWith(
      searchQuery: '',
      filteredGroups: state.groups,
    ));
  }

  Future<void> _onMembersLoadRequested(
    GroupMembersLoadRequested event,
    Emitter<GroupsState> emit,
  ) async {
    emit(state.copyWith(isLoadingMembers: true));

    try {
      final members = await _userRepository.getUsersByGroup(event.groupId);
      final updatedMembers = Map<String, List<UserModel>>.from(state.groupMembers);
      updatedMembers[event.groupId] = members;

      emit(state.copyWith(
        groupMembers: updatedMembers,
        isLoadingMembers: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoadingMembers: false,
        errorMessage: 'فشل في تحميل أعضاء المجموعة',
      ));
    }
  }

  Future<void> _onAllUsersLoadRequested(
    AllUsersLoadRequested event,
    Emitter<GroupsState> emit,
  ) async {
    try {
      final users = await _userRepository.getAllUsers();
      emit(state.copyWith(allUsers: users));
    } catch (e) {
      // Silent fail - not critical
    }
  }

  Future<void> _onMemberAddRequested(
    GroupMemberAddRequested event,
    Emitter<GroupsState> emit,
  ) async {
    emit(state.copyWith(isLoadingMembers: true, clearError: true, clearSuccess: true));

    try {
      await _userRepository.updateUserGroup(event.userId, event.groupId);

      // Update local state
      final updatedMembers = Map<String, List<UserModel>>.from(state.groupMembers);
      final userIndex = state.allUsers.indexWhere((u) => u.id == event.userId);
      if (userIndex != -1) {
        final user = state.allUsers[userIndex];
        final currentMembers = List<UserModel>.from(updatedMembers[event.groupId] ?? []);
        currentMembers.add(user.copyWith(groupId: event.groupId));
        updatedMembers[event.groupId] = currentMembers;
      }

      // Update member counts
      final updatedCounts = Map<String, int>.from(state.memberCounts);
      updatedCounts[event.groupId] = (updatedCounts[event.groupId] ?? 0) + 1;

      // Update all users list
      final updatedAllUsers = state.allUsers.map((u) {
        if (u.id == event.userId) {
          return u.copyWith(groupId: event.groupId);
        }
        return u;
      }).toList();

      emit(state.copyWith(
        groupMembers: updatedMembers,
        memberCounts: updatedCounts,
        allUsers: updatedAllUsers,
        isLoadingMembers: false,
        successMessage: 'تم إضافة العضو بنجاح',
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoadingMembers: false,
        errorMessage: 'فشل في إضافة العضو',
      ));
    }
  }

  Future<void> _onMemberRemoveRequested(
    GroupMemberRemoveRequested event,
    Emitter<GroupsState> emit,
  ) async {
    emit(state.copyWith(isLoadingMembers: true, clearError: true, clearSuccess: true));

    try {
      await _userRepository.updateUserGroup(event.userId, null);

      // Update local state
      final updatedMembers = Map<String, List<UserModel>>.from(state.groupMembers);
      final currentMembers = List<UserModel>.from(updatedMembers[event.groupId] ?? []);
      currentMembers.removeWhere((u) => u.id == event.userId);
      updatedMembers[event.groupId] = currentMembers;

      // Update member counts
      final updatedCounts = Map<String, int>.from(state.memberCounts);
      updatedCounts[event.groupId] = ((updatedCounts[event.groupId] ?? 1) - 1).clamp(0, 999999);

      // Update all users list
      final updatedAllUsers = state.allUsers.map((u) {
        if (u.id == event.userId) {
          return u.copyWith(groupId: null);
        }
        return u;
      }).toList();

      emit(state.copyWith(
        groupMembers: updatedMembers,
        memberCounts: updatedCounts,
        allUsers: updatedAllUsers,
        isLoadingMembers: false,
        successMessage: 'تم إزالة العضو بنجاح',
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoadingMembers: false,
        errorMessage: 'فشل في إزالة العضو',
      ));
    }
  }

  Future<void> _onMembersBatchUpdateRequested(
    GroupMembersBatchUpdateRequested event,
    Emitter<GroupsState> emit,
  ) async {
    emit(state.copyWith(isLoadingMembers: true, clearError: true, clearSuccess: true));

    try {
      // Get current members
      final currentMembers = await _userRepository.getUsersByGroup(event.groupId);
      final currentMemberIds = currentMembers.map((u) => u.id).toSet();
      final newMemberIds = event.userIds.toSet();

      // Users to add (in new list but not in current)
      final toAdd = newMemberIds.difference(currentMemberIds);
      // Users to remove (in current but not in new list)
      final toRemove = currentMemberIds.difference(newMemberIds);

      // Perform updates
      for (final userId in toAdd) {
        await _userRepository.updateUserGroup(userId, event.groupId);
      }
      for (final userId in toRemove) {
        await _userRepository.updateUserGroup(userId, null);
      }

      // Reload members
      final updatedMembers = await _userRepository.getUsersByGroup(event.groupId);
      final membersMap = Map<String, List<UserModel>>.from(state.groupMembers);
      membersMap[event.groupId] = updatedMembers;

      // Update counts
      final updatedCounts = Map<String, int>.from(state.memberCounts);
      updatedCounts[event.groupId] = updatedMembers.length;

      // Reload all users to reflect changes
      final allUsers = await _userRepository.getAllUsers();

      emit(state.copyWith(
        groupMembers: membersMap,
        memberCounts: updatedCounts,
        allUsers: allUsers,
        isLoadingMembers: false,
        successMessage: 'تم تحديث أعضاء المجموعة بنجاح',
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoadingMembers: false,
        errorMessage: 'فشل في تحديث أعضاء المجموعة',
      ));
    }
  }

  List<GroupModel> _applySearch(List<GroupModel> groups, String query) {
    if (query.isEmpty) return groups;

    return groups.where((g) {
      final name = g.name.toLowerCase();
      return name.contains(query);
    }).toList();
  }

  @override
  Future<void> close() {
    _groupsSubscription?.cancel();
    return super.close();
  }
}

/// Internal event for member counts loaded
class _MemberCountsLoaded extends GroupsEvent {
  final Map<String, int> counts;

  const _MemberCountsLoaded({required this.counts});

  @override
  List<Object?> get props => [counts];
}
