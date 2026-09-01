import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
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
    final currentPath = GoRouterState.of(context).uri.path;
    final canPop = context.canPop();
    final showPatientBackButton =
        showBottomNavigation && _shouldShowPatientBackButton(currentPath);

    return PopScope(
      canPop: canPop || !showBottomNavigation,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop || !showBottomNavigation) return;
        _goBackSafely(context, currentPath);
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: !showPatientBackButton,
          leading: showPatientBackButton
              ? IconButton(
                  tooltip: 'Back',
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => _goBackSafely(context, currentPath),
                )
              : null,
          title: Text(title),
          actions: actions,
        ),
        bottomNavigationBar: showBottomNavigation
            ? _PatientBottomNavigation(currentPath: currentPath)
            : null,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.lg),
            child: body,
          ),
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
      indicatorColor: AppColors.softCyan,
      onDestinationSelected: (index) {
        final destination = _destinations[index].path;
        if (currentPath != destination) context.go(destination);
      },
      destinations: _destinations
          .map(
            (item) => NavigationDestination(
              icon: Icon(item.icon),
              selectedIcon: Icon(item.selectedIcon),
              label: item.label,
            ),
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
    required this.selectedIcon,
  });

  final String path;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

const _destinations = [
  _NavigationItem(
    path: '/home',
    label: 'Home',
    icon: Icons.home_outlined,
    selectedIcon: Icons.home,
  ),
  _NavigationItem(
    path: '/appointments',
    label: 'Appointments',
    icon: Icons.event_outlined,
    selectedIcon: Icons.event,
  ),
  _NavigationItem(
    path: '/checkin',
    label: 'Check-in',
    icon: Icons.qr_code_scanner,
    selectedIcon: Icons.qr_code_2,
  ),
  _NavigationItem(
    path: '/queue',
    label: 'Queue',
    icon: Icons.confirmation_num_outlined,
    selectedIcon: Icons.confirmation_num,
  ),
  _NavigationItem(
    path: '/profile',
    label: 'Profile',
    icon: Icons.person_outline,
    selectedIcon: Icons.person,
  ),
];

bool _shouldShowPatientBackButton(String path) {
  return path != '/home';
}

void _goBackSafely(BuildContext context, String currentPath) {
  if (context.canPop()) {
    context.pop();
    return;
  }

  final fallbackPath = _fallbackPathFor(currentPath);
  if (fallbackPath == currentPath) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('You are already on the home screen.')),
      );
    return;
  }
  context.go(fallbackPath);
}

String _fallbackPathFor(String path) {
  if (path == '/home') return '/home';
  if (path == '/appointments') return '/home';
  if (path.startsWith('/appointments/')) return '/appointments';
  if (path == '/checkin') return '/home';
  if (path.startsWith('/checkin/')) return '/checkin';
  if (path == '/queue') return '/home';
  if (path.startsWith('/queue/')) return '/queue';
  if (path == '/notifications') return '/home';
  if (path.startsWith('/notifications/')) return '/notifications';
  if (path == '/profile') return '/home';
  return '/home';
}
