part of 'users_bloc.dart';

/// Users state
class UsersState extends Equatable {
  final List<UserModel> users;
  final List<UserModel> filteredUsers;
  final UserRole? filterRole;
  final String searchQuery;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  const UsersState({
    this.users = const [],
    this.filteredUsers = const [],
    this.filterRole,
    this.searchQuery = '',
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  /// Initial state
  factory UsersState.initial() => const UsersState();

  /// Copy with
  UsersState copyWith({
    List<UserModel>? users,
    List<UserModel>? filteredUsers,
    UserRole? filterRole,
    bool clearFilterRole = false,
    String? searchQuery,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    String? successMessage,
    bool clearSuccess = false,
  }) {
    return UsersState(
      users: users ?? this.users,
      filteredUsers: filteredUsers ?? this.filteredUsers,
      filterRole: clearFilterRole ? null : (filterRole ?? this.filterRole),
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }

  @override
  List<Object?> get props => [
        users,
        filteredUsers,
        filterRole,
        searchQuery,
        isLoading,
        errorMessage,
        successMessage,
      ];

  /// Get users count by role
  int countByRole(UserRole role) {
    return users.where((u) => u.role == role).length;
  }

  /// Get admins count
  int get adminsCount => countByRole(UserRole.admin);

  /// Get managers count
  int get managersCount => countByRole(UserRole.manager);

  /// Get employees count
  int get employeesCount => countByRole(UserRole.employee);
}
