import 'package:flutter/material.dart';

import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_scaffold.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      title: 'Profile',
      body: AppEmptyState(
        title: 'Patient profile',
        message:
            'Profile details will load from patient-safe backend APIs later.',
      ),
    );
  }
}
