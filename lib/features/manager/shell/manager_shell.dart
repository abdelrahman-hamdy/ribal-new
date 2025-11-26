import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../l10n/generated/app_localizations.dart';

class ManagerShell extends StatelessWidget {
  final Widget child;

  const ManagerShell({
    super.key,
    required this.child,
  });

  /// Root routes for each tab
  static const _tabRoots = [
    Routes.managerMyTasks,
    Routes.managerTeamTasks,
    Routes.managerProfile,
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = _calculateSelectedIndex(context);
    final location = GoRouterState.of(context).matchedLocation;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBackButton(context, location, currentIndex);
      },
      child: Scaffold(
        body: child,
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: context.colors.surface,
            boxShadow: AppShadows.bottomNav,
          ),
          child: NavigationBar(
            selectedIndex: currentIndex,
            onDestinationSelected: (index) =>
                _onItemTapped(index, context, currentIndex),
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.assignment_outlined),
                selectedIcon: const Icon(Icons.assignment),
                label: AppLocalizations.of(context)!.nav_myTasks,
              ),
              NavigationDestination(
                icon: const Icon(Icons.groups_outlined),
                selectedIcon: const Icon(Icons.groups),
                label: AppLocalizations.of(context)!.task_manage,
              ),
              NavigationDestination(
                icon: const Icon(Icons.person_outline),
                selectedIcon: const Icon(Icons.person),
                label: AppLocalizations.of(context)!.nav_profile,
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/manager/team')) return 1;
    if (location.startsWith('/manager/profile')) return 2;
    return 0;
  }

  /// Check if we're on a nested (sub) page within a tab
  bool _isOnNestedPage(String location, int currentIndex) {
    final rootPath = _tabRoots[currentIndex];
    return location != rootPath && location.startsWith(rootPath);
  }

  /// Handle back button press
  void _handleBackButton(
      BuildContext context, String location, int currentIndex) {
    // If on a nested page, go back to tab root
    if (_isOnNestedPage(location, currentIndex)) {
      context.go(_tabRoots[currentIndex]);
    }
    // If on home tab root (My Tasks), allow app exit
    else if (currentIndex == 0) {
      SystemNavigator.pop();
    }
    // If on other tab root, go to home (My Tasks)
    else {
      context.go(Routes.managerMyTasks);
    }
  }

  void _onItemTapped(int index, BuildContext context, int currentIndex) {
    // If tapping current tab, go to its root (useful when on nested page)
    if (index == currentIndex) {
      final location = GoRouterState.of(context).matchedLocation;
      if (_isOnNestedPage(location, currentIndex)) {
        context.go(_tabRoots[index]);
      }
      return;
    }

    // Navigate to the selected tab
    context.go(_tabRoots[index]);
  }
}
