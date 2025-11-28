// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../../core/locale/bloc/locale_bloc.dart' as _i83;
import '../../core/services/hive_cache_service.dart' as _i763;
import '../../core/theme/bloc/theme_bloc.dart' as _i435;
import '../../core/widgets/notes/bloc/notes_bloc.dart' as _i533;
import '../../core/widgets/tasks/today_tasks/bloc/today_tasks_bloc.dart'
    as _i140;
import '../../data/repositories/assignment_repository.dart' as _i169;
import '../../data/repositories/auth_repository.dart' as _i481;
import '../../data/repositories/group_repository.dart' as _i879;
import '../../data/repositories/invitation_repository.dart' as _i482;
import '../../data/repositories/label_repository.dart' as _i79;
import '../../data/repositories/note_repository.dart' as _i420;
import '../../data/repositories/notification_repository.dart' as _i337;
import '../../data/repositories/settings_repository.dart' as _i373;
import '../../data/repositories/statistics_repository.dart' as _i232;
import '../../data/repositories/task_repository.dart' as _i515;
import '../../data/repositories/user_repository.dart' as _i517;
import '../../data/repositories/whitelist_repository.dart' as _i645;
import '../../data/services/fcm_notification_service.dart' as _i699;
import '../../data/services/firebase_auth_service.dart' as _i734;
import '../../data/services/firestore_service.dart' as _i367;
import '../../data/services/notification_service.dart' as _i670;
import '../../data/services/storage_service.dart' as _i27;
import '../../features/admin/control_panel/groups/bloc/groups_bloc.dart'
    as _i683;
import '../../features/admin/control_panel/invitations/bloc/invitations_bloc.dart'
    as _i84;
import '../../features/admin/control_panel/labels/bloc/labels_bloc.dart'
    as _i315;
import '../../features/admin/control_panel/settings/bloc/settings_bloc.dart'
    as _i694;
import '../../features/admin/control_panel/users/bloc/user_profile_bloc.dart'
    as _i538;
import '../../features/admin/control_panel/users/bloc/users_bloc.dart' as _i394;
import '../../features/admin/control_panel/whitelist/bloc/whitelist_bloc.dart'
    as _i822;
import '../../features/admin/statistics/bloc/statistics_bloc.dart' as _i714;
import '../../features/admin/tasks/bloc/task_detail_bloc.dart' as _i860;
import '../../features/admin/tasks/bloc/tasks_bloc.dart' as _i102;
import '../../features/auth/bloc/auth_bloc.dart' as _i55;
import '../../features/employee/tasks/bloc/assignment_detail_bloc.dart'
    as _i242;
import '../../features/employee/tasks/bloc/assignments_bloc.dart' as _i839;
import '../../features/notifications/bloc/notifications_bloc.dart' as _i591;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    gh.lazySingleton<_i763.HiveCacheService>(() => _i763.HiveCacheService());
    gh.lazySingleton<_i699.FCMNotificationService>(
        () => _i699.FCMNotificationService());
    gh.lazySingleton<_i367.FirestoreService>(() => _i367.FirestoreService());
    gh.lazySingleton<_i734.FirebaseAuthService>(
        () => _i734.FirebaseAuthService());
    gh.lazySingleton<_i670.NotificationService>(
        () => _i670.NotificationService());
    gh.lazySingleton<_i27.StorageService>(() => _i27.StorageService());
    gh.lazySingleton<_i79.LabelRepository>(() => _i79.LabelRepository(
          gh<_i367.FirestoreService>(),
          gh<_i763.HiveCacheService>(),
        ));
    gh.lazySingleton<_i373.SettingsRepository>(() => _i373.SettingsRepository(
          gh<_i367.FirestoreService>(),
          gh<_i763.HiveCacheService>(),
        ));
    gh.lazySingleton<_i515.TaskRepository>(() => _i515.TaskRepository(
          gh<_i367.FirestoreService>(),
          gh<_i763.HiveCacheService>(),
        ));
    gh.lazySingleton<_i232.StatisticsRepository>(
        () => _i232.StatisticsRepository(
              gh<_i367.FirestoreService>(),
              gh<_i763.HiveCacheService>(),
            ));
    gh.lazySingleton<_i517.UserRepository>(() => _i517.UserRepository(
          gh<_i367.FirestoreService>(),
          gh<_i763.HiveCacheService>(),
        ));
    gh.lazySingleton<_i169.AssignmentRepository>(
        () => _i169.AssignmentRepository(
              gh<_i367.FirestoreService>(),
              gh<_i763.HiveCacheService>(),
            ));
    gh.factory<_i420.NoteRepository>(() => _i420.NoteRepository(
          gh<_i367.FirestoreService>(),
          gh<_i763.HiveCacheService>(),
        ));
    gh.factory<_i394.UsersBloc>(
        () => _i394.UsersBloc(gh<_i517.UserRepository>()));
    gh.factory<_i102.TasksBloc>(
        () => _i102.TasksBloc(gh<_i515.TaskRepository>()));
    gh.factory<_i315.LabelsBloc>(
        () => _i315.LabelsBloc(gh<_i79.LabelRepository>()));
    gh.factory<_i839.AssignmentsBloc>(() => _i839.AssignmentsBloc(
          gh<_i169.AssignmentRepository>(),
          gh<_i515.TaskRepository>(),
          gh<_i373.SettingsRepository>(),
          gh<_i517.UserRepository>(),
        ));
    gh.factory<_i694.SettingsBloc>(
        () => _i694.SettingsBloc(gh<_i373.SettingsRepository>()));
    gh.factory<_i860.TaskDetailBloc>(() => _i860.TaskDetailBloc(
          gh<_i515.TaskRepository>(),
          gh<_i169.AssignmentRepository>(),
          gh<_i79.LabelRepository>(),
          gh<_i517.UserRepository>(),
          gh<_i420.NoteRepository>(),
        ));
    gh.factory<_i83.LocaleBloc>(
        () => _i83.LocaleBloc(gh<_i763.HiveCacheService>()));
    gh.factory<_i435.ThemeBloc>(
        () => _i435.ThemeBloc(gh<_i763.HiveCacheService>()));
    gh.lazySingleton<_i481.AuthRepository>(() => _i481.AuthRepository(
          gh<_i734.FirebaseAuthService>(),
          gh<_i367.FirestoreService>(),
        ));
    gh.factory<_i140.TodayTasksBloc>(() => _i140.TodayTasksBloc(
          gh<_i515.TaskRepository>(),
          gh<_i169.AssignmentRepository>(),
          gh<_i79.LabelRepository>(),
          gh<_i517.UserRepository>(),
          gh<_i373.SettingsRepository>(),
        ));
    gh.lazySingleton<_i337.NotificationRepository>(
        () => _i337.NotificationRepository(gh<_i367.FirestoreService>()));
    gh.lazySingleton<_i879.GroupRepository>(
        () => _i879.GroupRepository(gh<_i367.FirestoreService>()));
    gh.lazySingleton<_i482.InvitationRepository>(
        () => _i482.InvitationRepository(gh<_i367.FirestoreService>()));
    gh.lazySingleton<_i645.WhitelistRepository>(
        () => _i645.WhitelistRepository(gh<_i367.FirestoreService>()));
    gh.factory<_i84.InvitationsBloc>(
        () => _i84.InvitationsBloc(gh<_i482.InvitationRepository>()));
    gh.factory<_i242.AssignmentDetailBloc>(() => _i242.AssignmentDetailBloc(
          gh<_i169.AssignmentRepository>(),
          gh<_i515.TaskRepository>(),
          gh<_i79.LabelRepository>(),
          gh<_i517.UserRepository>(),
          gh<_i373.SettingsRepository>(),
          gh<_i420.NoteRepository>(),
        ));
    gh.factory<_i714.StatisticsBloc>(() => _i714.StatisticsBloc(
          gh<_i232.StatisticsRepository>(),
          gh<_i517.UserRepository>(),
        ));
    gh.factory<_i591.NotificationsBloc>(
        () => _i591.NotificationsBloc(gh<_i337.NotificationRepository>()));
    gh.factory<_i538.UserProfileBloc>(() => _i538.UserProfileBloc(
          gh<_i517.UserRepository>(),
          gh<_i232.StatisticsRepository>(),
          gh<_i169.AssignmentRepository>(),
          gh<_i515.TaskRepository>(),
          gh<_i879.GroupRepository>(),
          gh<_i337.NotificationRepository>(),
        ));
    gh.factory<_i822.WhitelistBloc>(
        () => _i822.WhitelistBloc(gh<_i645.WhitelistRepository>()));
    gh.factory<_i55.AuthBloc>(() => _i55.AuthBloc(
          gh<_i481.AuthRepository>(),
          gh<_i517.UserRepository>(),
          gh<_i645.WhitelistRepository>(),
          gh<_i482.InvitationRepository>(),
          gh<_i699.FCMNotificationService>(),
        ));
    gh.factory<_i533.NotesBloc>(() => _i533.NotesBloc(
          gh<_i420.NoteRepository>(),
          gh<_i337.NotificationRepository>(),
        ));
    gh.factory<_i683.GroupsBloc>(() => _i683.GroupsBloc(
          gh<_i879.GroupRepository>(),
          gh<_i517.UserRepository>(),
        ));
    return this;
  }
}
