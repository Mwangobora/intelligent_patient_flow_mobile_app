import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_sizes.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    required this.title,
    required this.body,
    this.actions,
    this.showBottomNavigation = false,
    super.key,
  });

  final String title;
  final Widget body;
  final List<Widget>? actions;
  final bool showBottomNavigation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title), actions: actions),
      bottomNavigationBar: showBottomNavigation
          ? _PatientBottomNavigation(
              currentPath: GoRouterState.of(context).uri.path,
            )
          : null,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.lg),
          child: body,
        ),
      ),
    );
  }
}

class _PatientBottomNavigation extends StatelessWidget {
  const _PatientBottomNavigation({required this.currentPath});

  final String currentPath;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: _selectedIndex,
      onDestinationSelected: (index) => context.go(_destinations[index].path),
      destinations: _destinations
          .map(
            (item) =>
                NavigationDestination(icon: Icon(item.icon), label: item.label),
          )
          .toList(),
    );
  }

  int get _selectedIndex {
    final index = _destinations.indexWhere(
      (item) =>
          currentPath == item.path || currentPath.startsWith('${item.path}/'),
    );
    return index < 0 ? 0 : index;
  }
}

class _NavigationItem {
  const _NavigationItem({
    required this.path,
    required this.label,
    required this.icon,
  });

  final String path;
  final String label;
  final IconData icon;
}

const _destinations = [
  _NavigationItem(path: '/home', label: 'Home', icon: Icons.home_outlined),
  _NavigationItem(
    path: '/appointments',
    label: 'Appointments',
    icon: Icons.event_outlined,
  ),
  _NavigationItem(
    path: '/checkin',
    label: 'Check-in',
    icon: Icons.qr_code_scanner,
  ),
  _NavigationItem(
    path: '/queue',
    label: 'Queue',
    icon: Icons.confirmation_num_outlined,
  ),
  _NavigationItem(
    path: '/profile',
    label: 'Profile',
    icon: Icons.person_outline,
  ),
];
