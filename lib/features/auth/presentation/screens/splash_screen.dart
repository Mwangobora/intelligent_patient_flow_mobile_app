import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_scaffold.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Patient Flow',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.local_hospital,
            size: 56,
            color: AppColors.primaryTeal,
          ),
          const SizedBox(height: 20),
          Text(
            'Healthcare access, made calmer.',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          const Text(
            'Book appointments, check in securely, and follow your queue status.',
          ),
          const SizedBox(height: 28),
          AppButton(label: 'Continue', onPressed: () => context.go('/login')),
        ],
      ),
    );
  }
}
