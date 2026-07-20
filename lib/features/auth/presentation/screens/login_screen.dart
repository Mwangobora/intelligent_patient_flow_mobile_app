import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/app_providers.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../widgets/login_form.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    return AppScaffold(
      title: 'Sign in',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(
            Icons.local_hospital,
            size: 44,
            color: AppColors.primaryTeal,
          ),
          const SizedBox(height: 20),
          Text(
            'Welcome back',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          const Text('Use your registered email or phone number to continue.'),
          if (authState.errorMessage != null) ...[
            const SizedBox(height: 16),
            Text(
              authState.errorMessage!,
              style: const TextStyle(color: AppColors.danger),
            ),
          ],
          const SizedBox(height: 24),
          LoginForm(
            isLoading: authState.isLoading,
            registrationSupported: authState.registrationSupported,
            onSubmit: (emailOrPhone, password) async {
              await ref
                  .read(authControllerProvider.notifier)
                  .login(emailOrPhone: emailOrPhone, password: password);
            },
          ),
        ],
      ),
    );
  }
}
