import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_error_state.dart';
import '../../../../shared/widgets/app_loading_state.dart';
import '../../../appointments/data/models/appointment_models.dart';
import '../controllers/checkin_controller.dart';
import 'checkin_widgets.dart';

class CheckinContent extends StatelessWidget {
  const CheckinContent({
    required this.appointment,
    required this.isLoading,
    required this.checkinState,
    required this.onRetry,
    required this.onCheckInNow,
    required this.onIssueQr,
    this.errorMessage,
    this.successMessage,
    super.key,
  });

  final Appointment appointment;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;
  final CheckinState checkinState;
  final VoidCallback onRetry;
  final VoidCallback onCheckInNow;
  final VoidCallback onIssueQr;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const AppLoadingState(message: 'Loading check-in status...');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (successMessage != null)
          _MessageBanner(message: successMessage!, color: AppColors.success),
        if (errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.md),
            child: AppErrorState(message: errorMessage!, onRetry: onRetry),
          ),
        CheckinAppointmentSummary(appointment: appointment),
        const SizedBox(height: AppSizes.lg),
        CheckinStateCard(
          appointment: appointment,
          checkin: checkinState.activeCheckin,
          isActionLoading: checkinState.isActionLoading,
          onCheckInNow: onCheckInNow,
          onIssueQr: onIssueQr,
        ),
        if (checkinState.activeToken != null) ...[
          const SizedBox(height: AppSizes.lg),
          CheckinQrCard(token: checkinState.activeToken!),
        ],
        const SizedBox(height: AppSizes.lg),
        const _NextStepsCard(),
      ],
    );
  }
}

class NoAppointmentCheckin extends StatelessWidget {
  const NoAppointmentCheckin({required this.onAppointments, super.key});

  final VoidCallback onAppointments;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AppEmptyState(
          title: 'No appointment ready for check-in',
          message:
              'Your upcoming appointment check-in status will appear here.',
        ),
        const SizedBox(height: AppSizes.lg),
        AppButton(label: 'View appointments', onPressed: onAppointments),
      ],
    );
  }
}

class _MessageBanner extends StatelessWidget {
  const _MessageBanner({required this.message, required this.color});

  final String message;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.md),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppSizes.radius),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.md),
          child: Text(message, style: TextStyle(color: color)),
        ),
      ),
    );
  }
}

class _NextStepsCard extends StatelessWidget {
  const _NextStepsCard();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.softCyan,
        borderRadius: BorderRadius.all(Radius.circular(AppSizes.radius)),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSizes.md),
        child: Text(
          'After check-in, reception will add you to the right queue if it is not automatic.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
