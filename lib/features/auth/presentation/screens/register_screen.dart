import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_providers.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../widgets/register_form.dart';

class RegisterScreen extends ConsumerWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    return AppScaffold(
      title: 'Create patient account',
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Join Patient Flow',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSizes.sm),
            const Text(
              'Create your secure mobile account. We will link it to your patient profile automatically.',
            ),
            if (authState.errorMessage != null) ...[
              const SizedBox(height: AppSizes.md),
              Text(
                authState.errorMessage!,
                style: const TextStyle(color: AppColors.danger),
              ),
            ],
            const SizedBox(height: AppSizes.lg),
            RegisterForm(
              isLoading: authState.isLoading,
              onSubmit: (data) async {
                final registered = await ref
                    .read(authControllerProvider.notifier)
                    .register(
                      firstName: data.firstName,
                      middleName: data.middleName,
                      lastName: data.lastName,
                      dateOfBirth: data.dateOfBirth,
                      sexCode: data.sexCode,
                      email: data.email,
                      phoneNumber: data.phoneNumber,
                      password: data.password,
                      passwordConfirm: data.passwordConfirm,
                    );
                if (!registered && context.mounted) {
                  showAppErrorSnackBar(
                    context,
                    ref.read(authControllerProvider).errorMessage ??
                        'Could not create your account. Please try again.',
                  );
                }
                if (registered && context.mounted) {
                  showAppSuccessSnackBar(context, 'Account created.');
                  context.go('/home');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
