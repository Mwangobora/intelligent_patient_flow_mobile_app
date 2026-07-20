import 'package:flutter/material.dart';

import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_scaffold.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      title: 'Onboarding',
      body: AppEmptyState(
        title: 'Patient onboarding',
        message:
            'Onboarding content will be added after product copy is approved.',
      ),
    );
  }
}
