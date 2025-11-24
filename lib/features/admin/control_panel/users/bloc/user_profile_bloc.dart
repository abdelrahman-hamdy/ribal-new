import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/utils/ksa_timezone.dart';
import '../../../../../data/models/assignment_model.dart';
import '../../../../../data/models/group_model.dart';
import '../../../../../data/models/notification_model.dart';
import '../../../../../data/models/user_model.dart';
import '../../../../../data/repositories/assignment_repository.dart';
import '../../../../../data/repositories/group_repository.dart';
import '../../../../../data/repositories/notification_repository.dart';
import '../../../../../data/repositories/statistics_repository.dart';
import '../../../../../data/repositories/task_repository.dart';
import '../../../../../data/repositories/user_repository.dart';

part 'user_profile_event.dart';
part 'user_profile_state.dart';

/// Time filter for statistics
enum TimeFilter {
  today,
  week,
  month,
}

extension TimeFilterX on TimeFilter {
  String get displayNameAr {
    switch (this) {
      case TimeFilter.today:
        return 'اليوم';
      case TimeFilter.week:
        return 'هذا الأسبوع';
      case TimeFilter.month:
        return 'هذا الشهر';
    }
  }

  /// Get date range for this filter (using KSA timezone)
  (DateTime, DateTime) get dateRange {
    switch (this) {
      case TimeFilter.today:
        final startOfDay = KsaTimezone.startOfToday();
        final endOfDay = startOfDay.add(const Duration(days: 1));
        return (startOfDay, endOfDay);
      case TimeFilter.week:
        final startOfWeek = KsaTimezone.startOfWeek();
        final endOfWeek = KsaTimezone.endOfWeek();
        return (startOfWeek, endOfWeek);
      case TimeFilter.month:
        final startOfMonth = KsaTimezone.startOfMonth();
        final endOfMonth = KsaTimezone.endOfMonth();
        return (startOfMonth, endOfMonth);
    }
  }
}

@injectable
class UserProfileBloc extends Bloc<UserProfileEvent, UserProfileState> {
  final UserRepository _userRepository;
  final StatisticsRepository _statisticsRepository;
  final AssignmentRepository _assignmentRepository;
  final TaskRepository _taskRepository;
  final GroupRepository _groupRepository;
  final NotificationRepository _notificationRepository;

  StreamSubscription? _userSubscription;
  StreamSubscription? _assignmentsSubscription;

  UserProfileBloc(
    this._userRepository,
    this._statisticsRepository,
    this._assignmentRepository,
    this._taskRepository,
    this._groupRepository,
    this._notificationRepository,
  ) : super(UserProfileState.initial()) {
    on<UserProfileLoadRequested>(_onLoadRequested);
    on<_UserDataReceived>(_onUserDataReceived);
    on<_AssignmentsDataReceived>(_onAssignmentsDataReceived);
    on<UserProfileTimeFilterChanged>(_onTimeFilterChanged);
    on<UserProfileMarkAssignmentDone>(_onMarkAssignmentDone);
    on<_UserProfileError>(_onError);
    on<UserProfileRoleConversionRequested>(_onRoleConversionRequested);
    on<UserProfileManagerGroupsUpdated>(_onManagerGroupsUpdated);
    on<UserProfileGroupsLoadRequested>(_onGroupsLoadRequested);
    on<_GroupsDataReceived>(_onGroupsDataReceived);
  }

  Future<void> _onLoadRequested(
    UserProfileLoadRequested event,
    Emitter<UserProfileState> emit,
  ) async {
    emit(state.copyWith(
      isLoading: true,
      isLoadingAssignments: true,
      isLoadingStats: true,
      userId: event.userId,
      currentUserId: event.currentUserId,
      clearError: true,
    ));

    // Cancel previous subscriptions
    await _userSubscription?.cancel();
    await _assignmentsSubscription?.cancel();

    // Stream user data
    _userSubscription = _userRepository.streamUser(event.userId).listen(
          (user) => add(_UserDataReceived(user: user)),
          onError: (error) => add(const _UserProfileError('فشل في تحميل بيانات المستخدم')),
        );

    // Stream today's assignments (using KSA timezone)
    _assignmentsSubscription = _assignmentRepository
        .streamAssignmentsForUserOnDate(
          userId: event.userId,
          date: KsaTimezone.today(),
        )
        .listen(
          (assignments) => add(_AssignmentsDataReceived(assignments: assignments)),
          onError: (error) => add(const _UserProfileError('فشل في تحميل المهام')),
        );

    // Load statistics
    await _loadStatistics(emit, event.userId, state.timeFilter);
  }

  Future<void> _onUserDataReceived(
    _UserDataReceived event,
    Emitter<UserProfileState> emit,
  ) async {
    if (event.user == null) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'المستخدم غير موجود',
      ));
      return;
    }

    emit(state.copyWith(
      user: event.user,
      isLoading: false,
    ));
  }

  Future<void> _onAssignmentsDataReceived(
    _AssignmentsDataReceived event,
    Emitter<UserProfileState> emit,
  ) async {
    // Load task details for each assignment
    final assignmentsWithTasks = <AssignmentWithTask>[];

    for (final assignment in event.assignments) {
      final task = await _taskRepository.getTaskById(assignment.taskId);
      if (task != null) {
        assignmentsWithTasks.add(AssignmentWithTask(
          assignment: assignment,
          taskTitle: task.title,
          taskDescription: task.description,
          taskLabelIds: task.labelIds,
          taskAttachmentUrl: task.attachmentUrl,
          taskAttachmentRequired: task.attachmentRequired,
          taskCreatorId: task.createdBy,
        ));
      }
    }

    emit(state.copyWith(
      todayAssignments: assignmentsWithTasks,
      isLoadingAssignments: false,
    ));
  }

  Future<void> _onTimeFilterChanged(
    UserProfileTimeFilterChanged event,
    Emitter<UserProfileState> emit,
  ) async {
    emit(state.copyWith(
      timeFilter: event.filter,
      isLoadingStats: true,
    ));

    if (state.userId != null) {
      await _loadStatistics(emit, state.userId!, event.filter);
    }
  }

  Future<void> _loadStatistics(
    Emitter<UserProfileState> emit,
    String userId,
    TimeFilter filter,
  ) async {
    try {
      final (startDate, endDate) = filter.dateRange;
      final stats = await _statisticsRepository.getUserStatistics(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );

      emit(state.copyWith(
        stats: stats,
        isLoadingStats: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoadingStats: false,
        errorMessage: 'فشل في تحميل الإحصائيات',
      ));
    }
  }

  Future<void> _onMarkAssignmentDone(
    UserProfileMarkAssignmentDone event,
    Emitter<UserProfileState> emit,
  ) async {
    emit(state.copyWith(
      loadingAssignmentId: event.assignmentId,
      clearError: true,
      clearSuccess: true,
    ));

    try {
      await _assignmentRepository.markAsCompleted(
        assignmentId: event.assignmentId,
        markedDoneBy: state.currentUserId!,
      );

      emit(state.copyWith(
        successMessage: 'تم تحديد المهمة كمكتملة',
        clearLoadingAssignment: true,
      ));

      // Reload statistics
      if (state.userId != null) {
        await _loadStatistics(emit, state.userId!, state.timeFilter);
      }
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'فشل في تحديث حالة المهمة',
        clearLoadingAssignment: true,
      ));
    }
  }

  void _onError(
    _UserProfileError event,
    Emitter<UserProfileState> emit,
  ) {
    emit(state.copyWith(
      isLoading: false,
      errorMessage: event.message,
    ));
  }

  /// Handle role conversion (employee <-> manager)
  Future<void> _onRoleConversionRequested(
    UserProfileRoleConversionRequested event,
    Emitter<UserProfileState> emit,
  ) async {
    emit(state.copyWith(
      isRoleConversionLoading: true,
      clearError: true,
      clearSuccess: true,
    ));

    try {
      final user = state.user;
      if (user == null) {
        emit(state.copyWith(
          isRoleConversionLoading: false,
          errorMessage: 'المستخدم غير موجود',
        ));
        return;
      }

      final oldRole = user.role;
      final newRole = event.newRole;

      // Validate the conversion
      if (oldRole == newRole) {
        emit(state.copyWith(
          isRoleConversionLoading: false,
          errorMessage: 'المستخدم لديه هذا الدور بالفعل',
        ));
        return;
      }

      // Cannot convert to/from admin
      if (oldRole == UserRole.admin || newRole == UserRole.admin) {
        emit(state.copyWith(
          isRoleConversionLoading: false,
          errorMessage: 'لا يمكن تحويل دور مدير النظام',
        ));
        return;
      }

      // Perform role conversion
      await _userRepository.convertUserRole(
        userId: event.userId,
        newRole: newRole,
      );

      // Send notification to the user about role change
      final roleDisplayName = newRole == UserRole.manager ? 'مشرف' : 'موظف';
      await _notificationRepository.createTypedNotification(
        userId: event.userId,
        type: NotificationType.roleChanged,
        title: 'تغيير الدور',
        body: 'تم تغيير دورك إلى $roleDisplayName',
        deepLink: '/profile',
      );

      emit(state.copyWith(
        isRoleConversionLoading: false,
        successMessage: 'تم تغيير الدور بنجاح إلى $roleDisplayName',
      ));
    } catch (e) {
      emit(state.copyWith(
        isRoleConversionLoading: false,
        errorMessage: 'فشل في تغيير الدور: ${e.toString()}',
      ));
    }
  }

  /// Handle manager groups update
  Future<void> _onManagerGroupsUpdated(
    UserProfileManagerGroupsUpdated event,
    Emitter<UserProfileState> emit,
  ) async {
    emit(state.copyWith(
      isRoleConversionLoading: true,
      clearError: true,
      clearSuccess: true,
    ));

    try {
      await _userRepository.updateManagerPermissions(
        userId: event.userId,
        canAssignToAll: event.canAssignToAll,
        managedGroupIds: event.groupIds,
      );

      emit(state.copyWith(
        isRoleConversionLoading: false,
        successMessage: 'تم تحديث صلاحيات المشرف بنجاح',
      ));
    } catch (e) {
      emit(state.copyWith(
        isRoleConversionLoading: false,
        errorMessage: 'فشل في تحديث صلاحيات المشرف',
      ));
    }
  }

  /// Load all groups for selection
  Future<void> _onGroupsLoadRequested(
    UserProfileGroupsLoadRequested event,
    Emitter<UserProfileState> emit,
  ) async {
    emit(state.copyWith(isGroupsLoading: true));

    try {
      final groups = await _groupRepository.getAllGroups();
      emit(state.copyWith(
        allGroups: groups,
        isGroupsLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isGroupsLoading: false,
        errorMessage: 'فشل في تحميل المجموعات',
      ));
    }
  }

  /// Handle groups data received
  void _onGroupsDataReceived(
    _GroupsDataReceived event,
    Emitter<UserProfileState> emit,
  ) {
    emit(state.copyWith(allGroups: event.groups));
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    _assignmentsSubscription?.cancel();
    return super.close();
  }
}
