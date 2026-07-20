import 'package:flutter/material.dart';

import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_scaffold.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      title: 'Notifications',
      showBottomNavigation: true,
      body: AppEmptyState(
        title: 'Patient notifications',
        message:
            'Appointment, queue, and general notifications will appear here.',
      ),
    );
  }
}
