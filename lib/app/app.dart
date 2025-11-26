import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../l10n/generated/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../core/locale/bloc/locale_bloc.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/bloc/theme_bloc.dart';
import '../features/admin/control_panel/groups/bloc/groups_bloc.dart';
import '../features/admin/control_panel/settings/bloc/settings_bloc.dart';
import '../features/admin/tasks/bloc/tasks_bloc.dart';
import '../features/auth/bloc/auth_bloc.dart';
import 'di/injection.dart';
import 'router/app_router.dart';

class RibalApp extends StatelessWidget {
  const RibalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => getIt<AuthBloc>()..add(const AuthCheckRequested()),
        ),
        BlocProvider(
          create: (_) => getIt<TasksBloc>()..add(const TasksLoadRequested()),
        ),
        BlocProvider(
          create: (_) => getIt<GroupsBloc>()..add(const GroupsLoadRequested()),
        ),
        BlocProvider(
          create: (_) => getIt<SettingsBloc>(),
        ),
        BlocProvider(
          create: (_) => getIt<ThemeBloc>()..add(const ThemeLoadRequested()),
        ),
        BlocProvider(
          create: (_) => getIt<LocaleBloc>()..add(const LocaleLoadRequested()),
        ),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return BlocBuilder<LocaleBloc, LocaleState>(
            builder: (context, localeState) {
              return MaterialApp.router(
                title: 'Ribal',
                debugShowCheckedModeBanner: false,

                // Theme
                theme: AppTheme.light,
                darkTheme: AppTheme.dark,
                themeMode: themeState.themeMode,

                // Localization
                locale: localeState.locale,
                supportedLocales: const [
                  Locale('ar'),
                  Locale('en'),
                ],
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],

                // Router
                routerConfig: AppRouter.router,
              );
            },
          );
        },
      ),
    );
  }
}
