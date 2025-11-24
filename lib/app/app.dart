import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../core/theme/app_theme.dart';
import '../features/admin/control_panel/groups/bloc/groups_bloc.dart';
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
      ],
      child: MaterialApp.router(
        title: 'Ribal',
        debugShowCheckedModeBanner: false,

        // Theme
        theme: AppTheme.light,

        // Localization - Arabic only (RTL)
        locale: const Locale('ar'),
        supportedLocales: const [
          Locale('ar'),
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],

        // Router
        routerConfig: AppRouter.router,
      ),
    );
  }
}
