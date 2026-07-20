import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_providers.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_loading_state.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../controllers/auth_controller.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authControllerProvider.notifier).checkSession();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return AppScaffold(
      title: 'Patient Flow',
      body: authState.isLoading
          ? const AppLoadingState(message: 'Checking your session...')
          : authState.status == AuthStatus.sessionError
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.wifi_off_outlined,
                  size: 56,
                  color: AppColors.warning,
                ),
                const SizedBox(height: 20),
                Text(
                  'We could not reach the server.',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                Text(
                  authState.errorMessage ??
                      'Server is not reachable. Please try again.',
                ),
                const SizedBox(height: 28),
                AppButton(
                  label: 'Retry',
                  onPressed: () => ref
                      .read(authControllerProvider.notifier)
                      .checkSession(force: true),
                ),
              ],
            )
          : Column(
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
                  'Sign in securely to view your hospital profile and manage future patient services.',
                ),
                const SizedBox(height: 28),
                AppButton(
                  label: 'Go to sign in',
                  onPressed: () => context.go('/login'),
                ),
              ],
            ),
    );
  }
}
