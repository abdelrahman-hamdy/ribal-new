part of 'user_profile_bloc.dart';

/// User profile state
class UserProfileState extends Equatable {
  final String? userId;
  final String? currentUserId;
  final UserRole? currentUserRole;
  final UserModel? user;
  final UserPerformance? stats;
  final List<AssignmentWithTask> todayAssignments;
  final TimeFilter timeFilter;
  final bool isLoading;
  final bool isLoadingStats;
  final bool isLoadingAssignments;
  final String? loadingAssignmentId;
  final String? errorMessage;
  final String? successMessage;

  // For role conversion and group assignment
  final bool isRoleConversionLoading;
  final bool isGroupsLoading;
  final List<GroupModel> allGroups;

  const UserProfileState({
    this.userId,
    this.currentUserId,
    this.currentUserRole,
    this.user,
    this.stats,
    this.todayAssignments = const [],
    this.timeFilter = TimeFilter.today,
    this.isLoading = false,
    this.isLoadingStats = false,
    this.isLoadingAssignments = false,
    this.loadingAssignmentId,
    this.errorMessage,
    this.successMessage,
    this.isRoleConversionLoading = false,
    this.isGroupsLoading = false,
    this.allGroups = const [],
  });

  /// Initial state
  factory UserProfileState.initial() => const UserProfileState();

  /// Copy with
  UserProfileState copyWith({
    String? userId,
    String? currentUserId,
    UserRole? currentUserRole,
    UserModel? user,
    UserPerformance? stats,
    List<AssignmentWithTask>? todayAssignments,
    TimeFilter? timeFilter,
    bool? isLoading,
    bool? isLoadingStats,
    bool? isLoadingAssignments,
    String? loadingAssignmentId,
    bool clearLoadingAssignment = false,
    String? errorMessage,
    bool clearError = false,
    String? successMessage,
    bool clearSuccess = false,
    bool? isRoleConversionLoading,
    bool? isGroupsLoading,
    List<GroupModel>? allGroups,
  }) {
    return UserProfileState(
      userId: userId ?? this.userId,
      currentUserId: currentUserId ?? this.currentUserId,
      currentUserRole: currentUserRole ?? this.currentUserRole,
      user: user ?? this.user,
      stats: stats ?? this.stats,
      todayAssignments: todayAssignments ?? this.todayAssignments,
      timeFilter: timeFilter ?? this.timeFilter,
      isLoading: isLoading ?? this.isLoading,
      isLoadingStats: isLoadingStats ?? this.isLoadingStats,
      isLoadingAssignments: isLoadingAssignments ?? this.isLoadingAssignments,
      loadingAssignmentId: clearLoadingAssignment ? null : (loadingAssignmentId ?? this.loadingAssignmentId),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
      isRoleConversionLoading: isRoleConversionLoading ?? this.isRoleConversionLoading,
      isGroupsLoading: isGroupsLoading ?? this.isGroupsLoading,
      allGroups: allGroups ?? this.allGroups,
    );
  }

  @override
  List<Object?> get props => [
        userId,
        currentUserId,
        currentUserRole,
        user,
        stats,
        todayAssignments,
        timeFilter,
        isLoading,
        isLoadingStats,
        isLoadingAssignments,
        loadingAssignmentId,
        errorMessage,
        successMessage,
        isRoleConversionLoading,
        isGroupsLoading,
        allGroups,
      ];

  /// Check if current user can mark assignments as done
  /// Admins can mark any assignment as done, others only if they created the task
  bool canMarkDone(AssignmentWithTask assignment) {
    if (currentUserId == null) return false;
    // Admin can mark any assignment as done
    if (currentUserRole == UserRole.admin) return true;
    // Others can only mark assignments done if they created the task
    return assignment.taskCreatorId == currentUserId;
  }
}
