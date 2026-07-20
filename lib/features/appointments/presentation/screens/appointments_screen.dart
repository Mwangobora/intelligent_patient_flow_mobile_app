import 'package:flutter/material.dart';

import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_scaffold.dart';

class AppointmentsScreen extends StatelessWidget {
  const AppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      title: 'Appointments',
      body: AppEmptyState(
        title: 'Appointments coming soon',
        message:
            'Booking and appointment history will use real backend APIs later.',
      ),
    );
  }
}
