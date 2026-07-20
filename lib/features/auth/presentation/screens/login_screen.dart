import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_password_field.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/app_text_field.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Sign in',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Welcome back',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          const Text('Sign in to manage your appointments and queue updates.'),
          const SizedBox(height: 24),
          AppTextField(label: 'Email or phone', validator: Validators.required),
          const SizedBox(height: 16),
          AppPasswordField(label: 'Password', validator: Validators.required),
          const SizedBox(height: 24),
          AppButton(label: 'Sign in', onPressed: () => context.go('/home')),
          TextButton(
            onPressed: () => context.go('/register'),
            child: const Text('Create patient account'),
          ),
        ],
      ),
    );
  }
}
