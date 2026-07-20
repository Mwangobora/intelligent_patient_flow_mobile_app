import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_providers.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_error_state.dart';
import '../../../../shared/widgets/app_loading_state.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../controllers/appointments_controller.dart';
import '../widgets/appointment_widgets.dart';

class AppointmentsScreen extends ConsumerStatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  ConsumerState<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends ConsumerState<AppointmentsScreen> {
  String? _loadedPatientId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authControllerProvider).user;
      final profiles = ref.read(profileControllerProvider).patientProfiles;
      if (user != null && profiles.isEmpty) {
        ref
            .read(profileControllerProvider.notifier)
            .loadLinkedPatientProfiles(user.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileControllerProvider);
    final state = ref.watch(appointmentsControllerProvider);
    final patient = profileState.patientProfiles.isEmpty
        ? null
        : profileState.patientProfiles.first;

    if (patient != null && _loadedPatientId != patient.id) {
      _loadedPatientId = patient.id;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(appointmentsControllerProvider.notifier)
            .loadAppointments(patient.id);
      });
    }

    return AppScaffold(
      title: 'Appointments',
      showBottomNavigation: true,
      actions: [
        IconButton(
          tooltip: 'Book appointment',
          icon: const Icon(Icons.add),
          onPressed: () => context.go('/appointments/new'),
        ),
      ],
      body: profileState.isLoading
          ? const AppLoadingState(message: 'Loading patient profile...')
          : patient == null
          ? const AppEmptyState(
              title: 'No patient profile',
              message:
                  'A linked patient profile is required to view appointments.',
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppButton(
                  label: 'Book New Appointment',
                  onPressed: () => context.go('/appointments/new'),
                ),
                const SizedBox(height: AppSizes.lg),
                SegmentedButton<AppointmentFilter>(
                  segments: const [
                    ButtonSegment(
                      value: AppointmentFilter.upcoming,
                      label: Text('Upcoming'),
                    ),
                    ButtonSegment(
                      value: AppointmentFilter.past,
                      label: Text('Past'),
                    ),
                    ButtonSegment(
                      value: AppointmentFilter.cancelled,
                      label: Text('Cancelled'),
                    ),
                  ],
                  selected: {state.filter},
                  onSelectionChanged: (value) => ref
                      .read(appointmentsControllerProvider.notifier)
                      .setFilter(value.first),
                ),
                const SizedBox(height: AppSizes.lg),
                if (state.isLoading)
                  const AppLoadingState(message: 'Loading appointments...')
                else if (state.errorMessage != null)
                  AppErrorState(
                    message: state.errorMessage!,
                    onRetry: () => ref
                        .read(appointmentsControllerProvider.notifier)
                        .loadAppointments(patient.id),
                  )
                else
                  RefreshIndicator(
                    onRefresh: () => ref
                        .read(appointmentsControllerProvider.notifier)
                        .loadAppointments(patient.id),
                    child: state.visibleAppointments.isEmpty
                        ? const AppEmptyState(
                            title: 'No appointments found',
                            message: 'Your appointments will appear here.',
                          )
                        : ListView.separated(
                            itemCount: state.visibleAppointments.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: AppSizes.md),
                            itemBuilder: (context, index) => AppointmentCard(
                              appointment: state.visibleAppointments[index],
                            ),
                          ),
                  ),
              ],
            ),
    );
  }
}
