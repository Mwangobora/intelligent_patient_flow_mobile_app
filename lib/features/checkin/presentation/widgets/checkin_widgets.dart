import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_status_badge.dart';
import '../../../appointments/data/models/appointment_models.dart';
import '../../data/models/checkin_models.dart';

class CheckinAppointmentSummary extends StatelessWidget {
  const CheckinAppointmentSummary({required this.appointment, super.key});

  final Appointment appointment;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.event_available, color: AppColors.primaryTeal),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: Text(
                  appointment.appointmentNumber.isEmpty
                      ? 'Appointment'
                      : appointment.appointmentNumber,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              AppStatusBadge(
                label: _label(appointment.status),
                color: _appointmentStatusColor(appointment.status),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          _InfoRow(
            icon: Icons.local_hospital_outlined,
            label: appointment.facilityName ?? 'Facility not available',
          ),
          _InfoRow(
            icon: Icons.medical_services_outlined,
            label: appointment.specialtyName ?? 'Service not available',
          ),
          _InfoRow(
            icon: Icons.schedule,
            label: DateFormatter.readableDateTime(appointment.scheduledStart),
          ),
        ],
      ),
    );
  }
}

class CheckinStateCard extends StatelessWidget {
  const CheckinStateCard({
    required this.appointment,
    required this.checkin,
    required this.canCheckIn,
    required this.isActionLoading,
    required this.onCheckInNow,
    required this.onIssueQr,
    required this.onScanQr,
    this.blockReason,
    super.key,
  });

  final Appointment appointment;
  final PatientCheckin? checkin;
  final bool canCheckIn;
  final String? blockReason;
  final bool isActionLoading;
  final VoidCallback onCheckInNow;
  final VoidCallback onIssueQr;
  final VoidCallback onScanQr;

  @override
  Widget build(BuildContext context) {
    if (AppointmentStatus.terminal.contains(appointment.status)) {
      return const _InstructionCard(
        icon: Icons.block_outlined,
        title: 'Check-in is closed',
        message: 'This appointment is completed, cancelled, or rescheduled.',
        color: AppColors.textSecondary,
      );
    }
    if (checkin != null) {
      return AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _InstructionHeader(
              icon: Icons.check_circle_outline,
              title: 'You are checked in.',
              color: AppColors.success,
            ),
            const SizedBox(height: AppSizes.sm),
            Text(
              'Checked in at ${DateFormatter.readableDateTime(checkin!.checkedInAt)}',
            ),
            const SizedBox(height: AppSizes.lg),
            AppButton(
              label: 'View queue status',
              onPressed: () => context.go('/queue'),
            ),
          ],
        ),
      );
    }
    if (!canCheckIn) {
      return _InstructionCard(
        icon: Icons.lock_clock_outlined,
        title: 'Check-in is not open yet',
        message: _blockReasonText(blockReason),
        color: AppColors.warning,
      );
    }
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _InstructionHeader(
            icon: Icons.qr_code_scanner,
            title: 'Ready for arrival check-in',
            color: AppColors.primaryTeal,
          ),
          const SizedBox(height: AppSizes.sm),
          const Text(
            'Use mobile check-in, show your appointment QR code, or scan a hospital check-in QR code.',
          ),
          const SizedBox(height: AppSizes.lg),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Check in now',
                  isLoading: isActionLoading,
                  onPressed: onCheckInNow,
                ),
              ),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isActionLoading ? null : onIssueQr,
                  icon: const Icon(Icons.qr_code_2),
                  label: const Text('Show My QR'),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: isActionLoading ? null : onScanQr,
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Scan QR Code'),
            ),
          ),
        ],
      ),
    );
  }
}

String _blockReasonText(String? reason) {
  return switch (reason) {
    'too_early' =>
      'Check-in is not open yet. Please try again closer to your appointment time.',
    'too_late' =>
      'This appointment check-in window has closed. Please contact reception.',
    'already_checked_in' => 'You are already checked in for this appointment.',
    'appointment_cancelled' ||
    'appointment_completed' ||
    'appointment_no_show' ||
    'appointment_rescheduled' => 'This appointment cannot be checked in.',
    _ => 'Please contact reception if you need help with this appointment.',
  };
}

class CheckinQrCard extends StatelessWidget {
  const CheckinQrCard({required this.token, super.key});

  final CheckinToken token;

  @override
  Widget build(BuildContext context) {
    if (token.rawToken == null || token.rawToken!.isEmpty) {
      return const _InstructionCard(
        icon: Icons.qr_code_2,
        title: 'QR code not available',
        message: 'Generate a new QR code when you are ready to check in.',
        color: AppColors.warning,
      );
    }
    return AppCard(
      child: Column(
        children: [
          Text(
            'Show this QR code at check-in',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSizes.md),
          QrImageView(
            data: token.rawToken!,
            version: QrVersions.auto,
            size: 220,
            backgroundColor: Colors.white,
          ),
          const SizedBox(height: AppSizes.md),
          Text(
            token.isExpired
                ? 'This QR code has expired. Please generate a new one.'
                : 'Expires ${DateFormatter.readableDateTime(token.expiresAt)}',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: token.isExpired
                  ? AppColors.danger
                  : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _InstructionCard extends StatelessWidget {
  const _InstructionCard({
    required this.icon,
    required this.title,
    required this.message,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String message;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InstructionHeader(icon: icon, title: title, color: color),
          const SizedBox(height: AppSizes.sm),
          Text(message),
        ],
      ),
    );
  }
}

class _InstructionHeader extends StatelessWidget {
  const _InstructionHeader({
    required this.icon,
    required this.title,
    required this.color,
  });

  final IconData icon;
  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: AppSizes.sm),
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleMedium),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.sm),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: AppSizes.sm),
          Expanded(child: Text(label)),
        ],
      ),
    );
  }
}

Color _appointmentStatusColor(String status) {
  return switch (status) {
    AppointmentStatus.completed => AppColors.success,
    AppointmentStatus.cancelled || AppointmentStatus.noShow => AppColors.danger,
    AppointmentStatus.rescheduled => AppColors.warning,
    _ => AppColors.primaryTeal,
  };
}

String _label(String value) {
  return value
      .split('_')
      .map(
        (part) => part.isEmpty
            ? part
            : '${part[0].toUpperCase()}${part.substring(1)}',
      )
      .join(' ');
}
