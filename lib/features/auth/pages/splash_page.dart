import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../bloc/auth_bloc.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          final route = switch (state.user.role.name) {
            'admin' => Routes.adminHome,
            'manager' => Routes.managerMyTasks,
            _ => Routes.employeeTasks,
          };
          context.go(route);
        } else if (state is AuthEmailNotVerified) {
          context.go('${Routes.verifyEmail}?email=${state.email}');
        } else if (state is AuthUnauthenticated) {
          context.go(Routes.login);
        }
      },
      // White background with centered logo - matches native splash screen
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Image.asset(
            'assets/images/rbal-logo.png',
            width: 200,
            height: 200,
          ),
        ),
      ),
    );
  }
}
