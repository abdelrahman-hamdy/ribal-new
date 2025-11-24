import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../../data/models/user_model.dart';
import '../../../../../data/repositories/user_repository.dart';

part 'users_event.dart';
part 'users_state.dart';

@injectable
class UsersBloc extends Bloc<UsersEvent, UsersState> {
  final UserRepository _userRepository;
  StreamSubscription? _usersSubscription;

  UsersBloc(this._userRepository) : super(UsersState.initial()) {
    on<UsersLoadRequested>(_onLoadRequested);
    on<_UsersDataReceived>(_onDataReceived);
    on<_UsersErrorReceived>(_onErrorReceived);
    on<UsersLoadByRoleRequested>(_onLoadByRoleRequested);
    on<UsersLoadByGroupRequested>(_onLoadByGroupRequested);
    on<UserRoleUpdateRequested>(_onRoleUpdateRequested);
    on<UserGroupUpdateRequested>(_onGroupUpdateRequested);
    on<ManagerPermissionsUpdateRequested>(_onManagerPermissionsUpdateRequested);
    on<UsersSearchRequested>(_onSearchRequested);
    on<UsersSearchCleared>(_onSearchCleared);
    on<UsersFilterByRoleChanged>(_onFilterByRoleChanged);
  }

  Future<void> _onLoadRequested(
    UsersLoadRequested event,
    Emitter<UsersState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    await _usersSubscription?.cancel();

    _usersSubscription = _userRepository.streamAllUsers().listen(
      (users) => add(_UsersDataReceived(users: users)),
      onError: (error) => add(const _UsersErrorReceived()),
    );
  }

  void _onDataReceived(
    _UsersDataReceived event,
    Emitter<UsersState> emit,
  ) {
    emit(state.copyWith(
      users: event.users,
      filteredUsers: _applyFilters(event.users, state.filterRole, state.searchQuery),
      isLoading: false,
    ));
  }

  void _onErrorReceived(
    _UsersErrorReceived event,
    Emitter<UsersState> emit,
  ) {
    emit(state.copyWith(
      isLoading: false,
      errorMessage: 'فشل في تحميل المستخدمين',
    ));
  }

  Future<void> _onLoadByRoleRequested(
    UsersLoadByRoleRequested event,
    Emitter<UsersState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      final users = await _userRepository.getUsersByRole(event.role);
      emit(state.copyWith(
        users: users,
        filteredUsers: users,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'فشل في تحميل المستخدمين',
      ));
    }
  }

  Future<void> _onLoadByGroupRequested(
    UsersLoadByGroupRequested event,
    Emitter<UsersState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      final users = await _userRepository.getUsersByGroup(event.groupId);
      emit(state.copyWith(
        users: users,
        filteredUsers: users,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'فشل في تحميل المستخدمين',
      ));
    }
  }

  Future<void> _onRoleUpdateRequested(
    UserRoleUpdateRequested event,
    Emitter<UsersState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true, clearSuccess: true));

    try {
      await _userRepository.updateUserRole(event.userId, event.newRole);
      emit(state.copyWith(
        isLoading: false,
        successMessage: 'تم تحديث الدور بنجاح',
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'فشل في تحديث الدور',
      ));
    }
  }

  Future<void> _onGroupUpdateRequested(
    UserGroupUpdateRequested event,
    Emitter<UsersState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true, clearSuccess: true));

    try {
      await _userRepository.updateUserGroup(event.userId, event.groupId);
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

  Future<void> _onManagerPermissionsUpdateRequested(
    ManagerPermissionsUpdateRequested event,
    Emitter<UsersState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true, clearSuccess: true));

    try {
      await _userRepository.updateManagerPermissions(
        userId: event.userId,
        canAssignToAll: event.canAssignToAll,
        managedGroupIds: event.managedGroupIds,
      );
      emit(state.copyWith(
        isLoading: false,
        successMessage: 'تم تحديث صلاحيات المشرف بنجاح',
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'فشل في تحديث صلاحيات المشرف',
      ));
    }
  }

  void _onSearchRequested(
    UsersSearchRequested event,
    Emitter<UsersState> emit,
  ) {
    final query = event.query.toLowerCase().trim();
    emit(state.copyWith(
      searchQuery: query,
      filteredUsers: _applyFilters(state.users, state.filterRole, query),
    ));
  }

  void _onSearchCleared(
    UsersSearchCleared event,
    Emitter<UsersState> emit,
  ) {
    emit(state.copyWith(
      searchQuery: '',
      filteredUsers: _applyFilters(state.users, state.filterRole, ''),
    ));
  }

  void _onFilterByRoleChanged(
    UsersFilterByRoleChanged event,
    Emitter<UsersState> emit,
  ) {
    emit(state.copyWith(
      filterRole: event.role,
      clearFilterRole: event.role == null,
      filteredUsers: _applyFilters(state.users, event.role, state.searchQuery),
    ));
  }

  List<UserModel> _applyFilters(
    List<UserModel> users,
    UserRole? filterRole,
    String searchQuery,
  ) {
    var filtered = users;

    // Apply role filter
    if (filterRole != null) {
      filtered = filtered.where((u) => u.role == filterRole).toList();
    }

    // Apply search filter
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((u) {
        final fullName = u.fullName.toLowerCase();
        final email = u.email.toLowerCase();
        return fullName.contains(searchQuery) || email.contains(searchQuery);
      }).toList();
    }

    return filtered;
  }

  @override
  Future<void> close() {
    _usersSubscription?.cancel();
    return super.close();
  }
}
