import 'package:flutter/material.dart';

import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_scaffold.dart';

class AppointmentDetailScreen extends StatelessWidget {
  const AppointmentDetailScreen({required this.appointmentId, super.key});

  final String appointmentId;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Appointment Detail',
      body: AppEmptyState(
        title: 'Appointment $appointmentId',
        message:
            'Details and status history will load from backend APIs later.',
      ),
    );
  }
}
