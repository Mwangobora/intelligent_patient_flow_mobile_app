import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/app_sizes.dart';
import 'app_providers.dart';
import '../shared/widgets/app_card.dart';
import '../shared/widgets/app_scaffold.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final items = [
      ('Appointments', '/appointments', Icons.calendar_month_outlined),
      ('Queue Status', '/queue', Icons.format_list_numbered),
      ('QR Check-in', '/checkin', Icons.qr_code_scanner),
      ('Notifications', '/notifications', Icons.notifications_outlined),
      ('Profile', '/profile', Icons.person_outline),
    ];

    return AppScaffold(
      title: 'Patient Home',
      actions: [
        IconButton(
          tooltip: 'Logout',
          onPressed: authState.isLoading
              ? null
              : () => ref.read(authControllerProvider.notifier).logout(),
          icon: const Icon(Icons.logout),
        ),
      ],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome to Patient Flow',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            'Manage appointments, check-ins, queue updates, and hospital notifications.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSizes.xl),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: AppSizes.md),
              child: AppCard(
                child: ListTile(
                  leading: Icon(item.$3),
                  title: Text(item.$1),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go(item.$2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
