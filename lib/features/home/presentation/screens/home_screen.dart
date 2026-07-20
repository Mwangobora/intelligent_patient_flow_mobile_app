import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_providers.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_loading_state.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../appointments/data/models/appointment_models.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _loadedProfiles = false;
  String? _loadedAppointmentPatientId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authControllerProvider).user;
      if (user != null && !_loadedProfiles) {
        _loadedProfiles = true;
        ref
            .read(profileControllerProvider.notifier)
            .loadLinkedPatientProfiles(user.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final profileState = ref.watch(profileControllerProvider);
    final appointmentState = ref.watch(appointmentsControllerProvider);
    final patient = profileState.patientProfiles.isEmpty
        ? null
        : profileState.patientProfiles.first;

    if (patient != null && _loadedAppointmentPatientId != patient.id) {
      _loadedAppointmentPatientId = patient.id;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(appointmentsControllerProvider.notifier)
            .loadAppointments(patient.id);
      });
    }

    return AppScaffold(
      title: 'Patient Home',
      showBottomNavigation: true,
      actions: [
        IconButton(
          tooltip: 'Logout',
          onPressed: authState.isLoading
              ? null
              : () => ref.read(authControllerProvider.notifier).logout(),
          icon: const Icon(Icons.logout),
        ),
      ],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hello, ${patient?.firstName ?? authState.user?.firstName ?? 'there'}',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppSizes.sm),
          const Text(
            'Manage appointments and prepare for your hospital visit.',
          ),
          const SizedBox(height: AppSizes.lg),
          if (profileState.isLoading)
            const AppLoadingState(message: 'Loading your profile...')
          else if (patient == null)
            const AppEmptyState(
              title: 'Patient profile unavailable',
              message:
                  'This account is signed in, but no patient-safe profile is available yet.',
            )
          else ...[
            _NextAppointmentCard(appointment: appointmentState.nextAppointment),
            const SizedBox(height: AppSizes.lg),
            Text(
              'Quick actions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSizes.md),
            _QuickActionGrid(
              actions: [
                _QuickAction(
                  label: 'Book Appointment',
                  icon: Icons.add_circle_outline,
                  onTap: () => context.go('/appointments/new'),
                ),
                _QuickAction(
                  label: 'My Appointments',
                  icon: Icons.calendar_month_outlined,
                  onTap: () => context.go('/appointments'),
                ),
                _QuickAction(
                  label: 'Check-in',
                  icon: Icons.qr_code_scanner,
                  onTap: () => context.go('/checkin'),
                ),
                const _QuickAction(
                  label: 'Notifications',
                  icon: Icons.notifications_outlined,
                  isEnabled: false,
                ),
              ],
            ),
            const SizedBox(height: AppSizes.lg),
            _PlaceholderCard(onTap: () => context.go('/queue')),
          ],
        ],
      ),
    );
  }
}

class _NextAppointmentCard extends StatelessWidget {
  const _NextAppointmentCard({required this.appointment});

  final Appointment? appointment;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: appointment == null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Next appointment',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppSizes.sm),
                const Text('No upcoming appointment is scheduled.'),
              ],
            )
          : ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(
                backgroundColor: AppColors.softCyan,
                child: Icon(
                  Icons.event_available,
                  color: AppColors.primaryTeal,
                ),
              ),
              title: Text(appointment!.specialtyName ?? 'Appointment'),
              subtitle: Text(
                '${appointment!.facilityName ?? 'Facility'}\n'
                '${DateFormatter.readableDateTime(appointment!.scheduledStart)}',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.go('/appointments/${appointment!.id}'),
            ),
    );
  }
}

class _QuickActionGrid extends StatelessWidget {
  const _QuickActionGrid({required this.actions});

  final List<_QuickAction> actions;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      childAspectRatio: 1.45,
      crossAxisSpacing: AppSizes.md,
      mainAxisSpacing: AppSizes.md,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: actions,
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.label,
    required this.icon,
    this.onTap,
    this.isEnabled = true,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isEnabled
                  ? AppColors.primaryTeal
                  : AppColors.textSecondary,
            ),
            const SizedBox(height: AppSizes.sm),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: isEnabled
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
            ),
            if (!isEnabled)
              const Text(
                'Soon',
                style: TextStyle(color: AppColors.textSecondary),
              ),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderCard extends StatelessWidget {
  const _PlaceholderCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.format_list_numbered, color: AppColors.info),
        title: const Text('Queue status'),
        subtitle: const Text('View your current queue number and status.'),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
