import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_providers.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_error_state.dart';
import '../../../../shared/widgets/app_loading_state.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../widgets/appointment_widgets.dart';

class AppointmentDetailScreen extends ConsumerStatefulWidget {
  const AppointmentDetailScreen({required this.appointmentId, super.key});

  final String appointmentId;

  @override
  ConsumerState<AppointmentDetailScreen> createState() =>
      _AppointmentDetailScreenState();
}

class _AppointmentDetailScreenState
    extends ConsumerState<AppointmentDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(appointmentDetailControllerProvider.notifier)
          .loadAppointment(widget.appointmentId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appointmentDetailControllerProvider);
    final appointment = state.appointment;

    return AppScaffold(
      title: 'Appointment Detail',
      showBottomNavigation: true,
      body: state.isLoading
          ? const AppLoadingState(message: 'Loading appointment...')
          : state.errorMessage != null
          ? AppErrorState(
              message: state.errorMessage!,
              onRetry: () => ref
                  .read(appointmentDetailControllerProvider.notifier)
                  .loadAppointment(widget.appointmentId),
            )
          : appointment == null
          ? const AppErrorState(message: 'Appointment was not found.')
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              appointment.appointmentNumber.isEmpty
                                  ? 'Appointment'
                                  : appointment.appointmentNumber,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          AppointmentStatusBadge(status: appointment.status),
                        ],
                      ),
                      const SizedBox(height: AppSizes.lg),
                      _DetailRow(
                        label: 'Facility',
                        value: appointment.facilityName ?? 'Not available',
                      ),
                      _DetailRow(
                        label: 'Service',
                        value: appointment.specialtyName ?? 'Not available',
                      ),
                      _DetailRow(
                        label: 'Doctor',
                        value: appointment.practitionerNumber == null
                            ? 'Assigned by schedule'
                            : 'Doctor ${appointment.practitionerNumber}',
                      ),
                      _DetailRow(
                        label: 'Date & time',
                        value: DateFormatter.readableDateTime(
                          appointment.scheduledStart,
                        ),
                      ),
                      _DetailRow(
                        label: 'Created',
                        value: appointment.createdAt == null
                            ? 'Not available'
                            : DateFormatter.readableDateTime(
                                appointment.createdAt!,
                              ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSizes.lg),
                if (appointment.canCancel || appointment.canReschedule)
                  Row(
                    children: [
                      if (appointment.canReschedule)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: state.isActionLoading
                                ? null
                                : () => context.go(
                                    '/appointments/${appointment.id}/reschedule',
                                  ),
                            child: const Text('Reschedule'),
                          ),
                        ),
                      if (appointment.canCancel && appointment.canReschedule)
                        const SizedBox(width: AppSizes.md),
                      if (appointment.canCancel)
                        Expanded(
                          child: AppButton(
                            label: 'Cancel',
                            isLoading: state.isActionLoading,
                            onPressed: () =>
                                _showCancelDialog(context, appointment.id),
                          ),
                        ),
                    ],
                  ),
                const SizedBox(height: AppSizes.lg),
                AppCard(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.qr_code_2, color: AppColors.info),
                    title: const Text('Check-in'),
                    subtitle: const Text(
                      'View QR check-in and arrival instructions.',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.go('/checkin/${appointment.id}'),
                  ),
                ),
                const SizedBox(height: AppSizes.lg),
                Text(
                  'Status history',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppSizes.md),
                if (state.history.isEmpty)
                  const AppCard(child: Text('No status history available.'))
                else
                  ...state.history.map(
                    (event) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSizes.sm),
                      child: AppCard(
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.history),
                          title: Text(event.toStatus),
                          subtitle: Text(
                            '${DateFormatter.readableDateTime(event.changedAt)}'
                            '${event.reason == null ? '' : '\n${event.reason}'}',
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  Future<void> _showCancelDialog(
    BuildContext context,
    String appointmentId,
  ) async {
    final controller = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel appointment?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please provide a cancellation reason.'),
            const SizedBox(height: AppSizes.md),
            AppTextField(label: 'Reason', controller: controller),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Cancel appointment'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final reason = controller.text.trim();
    if (reason.isEmpty) return;
    await ref
        .read(appointmentDetailControllerProvider.notifier)
        .cancelAppointment(appointmentId: appointmentId, reason: reason);
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
