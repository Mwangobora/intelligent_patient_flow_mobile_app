import 'package:flutter/material.dart';

import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_scaffold.dart';

class AppointmentNewScreen extends StatelessWidget {
  const AppointmentNewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      title: 'Book Appointment',
      body: AppEmptyState(
        title: 'Guided booking',
        message:
            'Patient, facility, service, date, and slot selection will be added next.',
      ),
    );
  }
}
