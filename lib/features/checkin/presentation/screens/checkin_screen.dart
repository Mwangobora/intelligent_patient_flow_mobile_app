import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_providers.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_loading_state.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../appointments/data/models/appointment_models.dart';
import '../widgets/checkin_state_view.dart';

class CheckinScreen extends ConsumerStatefulWidget {
  const CheckinScreen({this.appointmentId, super.key});

  final String? appointmentId;

  @override
  ConsumerState<CheckinScreen> createState() => _CheckinScreenState();
}

class _CheckinScreenState extends ConsumerState<CheckinScreen> {
  String? _loadedPatientId;
  String? _loadedCheckinAppointmentId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authControllerProvider).user;
      if (user != null &&
          ref.read(profileControllerProvider).patientProfiles.isEmpty) {
        ref
            .read(profileControllerProvider.notifier)
            .loadLinkedPatientProfiles(user.id);
      }
      final appointmentId = widget.appointmentId;
      if (appointmentId != null) {
        ref
            .read(appointmentDetailControllerProvider.notifier)
            .loadAppointment(appointmentId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileControllerProvider);
    final appointmentState = ref.watch(appointmentsControllerProvider);
    final detailState = ref.watch(appointmentDetailControllerProvider);
    final checkinState = ref.watch(checkinControllerProvider);
    final patient = profileState.patientProfiles.isEmpty
        ? null
        : profileState.patientProfiles.first;

    if (patient != null &&
        widget.appointmentId == null &&
        _loadedPatientId != patient.id) {
      _loadedPatientId = patient.id;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(appointmentsControllerProvider.notifier)
            .loadAppointments(patient.id);
      });
    }

    final appointment = widget.appointmentId == null
        ? appointmentState.nextAppointment
        : detailState.appointment;

    if (appointment != null &&
        _loadedCheckinAppointmentId != appointment.id &&
        !checkinState.isLoading) {
      _loadedCheckinAppointmentId = appointment.id;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(checkinControllerProvider.notifier)
            .loadForAppointment(appointment);
      });
    }

    return AppScaffold(
      title: 'QR Check-in',
      showBottomNavigation: true,
      body:
          profileState.isLoading ||
              appointmentState.isLoading ||
              detailState.isLoading
          ? const AppLoadingState(message: 'Preparing check-in...')
          : patient == null
          ? const AppEmptyState(
              title: 'Patient profile unavailable',
              message: 'A linked patient profile is required for check-in.',
            )
          : appointment == null
          ? NoAppointmentCheckin(
              onAppointments: () => context.go('/appointments'),
            )
          : CheckinContent(
              appointment: appointment,
              isLoading: checkinState.isLoading,
              errorMessage: checkinState.errorMessage,
              successMessage: checkinState.successMessage,
              checkinState: checkinState,
              onRetry: () => ref
                  .read(checkinControllerProvider.notifier)
                  .loadForAppointment(appointment),
              onCheckInNow: () => _confirmMobileCheckin(appointment),
              onIssueQr: () => _issueQrToken(),
            ),
    );
  }

  Future<void> _confirmMobileCheckin(Appointment appointment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Check in now?'),
        content: Text(
          'Confirm that you have arrived at ${appointment.facilityName ?? 'the facility'}.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Not yet'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Check in'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final success = await ref
        .read(checkinControllerProvider.notifier)
        .checkInNow();
    if (!mounted) return;
    _showSnack(
      success ? 'Check-in successful.' : 'Check-in failed. Please try again.',
    );
  }

  Future<void> _issueQrToken() async {
    final success = await ref
        .read(checkinControllerProvider.notifier)
        .issueQrToken();
    if (!mounted) return;
    _showSnack(success ? 'QR code is ready.' : 'Could not generate QR code.');
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
