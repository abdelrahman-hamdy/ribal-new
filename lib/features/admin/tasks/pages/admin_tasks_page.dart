import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../core/widgets/feedback/empty_state.dart';

class AdminTasksPage extends StatelessWidget {
  const AdminTasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المهام'),
      ),
      body: const EmptyState(
        icon: Icons.task_outlined,
        title: 'لا توجد مهام',
        message: 'قم بإنشاء مهمة جديدة للبدء',
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(Routes.adminTaskCreate),
        child: const Icon(Icons.add),
      ),
    );
  }
}
