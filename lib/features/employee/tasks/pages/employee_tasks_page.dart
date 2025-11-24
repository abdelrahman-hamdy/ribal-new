import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../core/widgets/assignments/my_assignments_section.dart';
import '../../../auth/bloc/auth_bloc.dart';

class EmployeeTasksPage extends StatelessWidget {
  const EmployeeTasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! AuthAuthenticated) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return MyAssignmentsPage(
          userId: authState.user.id,
          userName: authState.user.firstName,
          appBarTitle: 'مهام اليوم',
          getAssignmentDetailRoute: Routes.employeeAssignmentDetailPath,
          onNavigate: (route) => context.push(route),
          onNotificationTap: () => context.push(Routes.notifications),
        );
      },
    );
  }
}
