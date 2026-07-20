import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/app_providers.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_error_state.dart';
import '../../../../shared/widgets/app_loading_state.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../widgets/notification_widgets.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  String? _loadedPatientId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadIfReady());
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final profileState = ref.watch(profileControllerProvider);
    final notificationState = ref.watch(notificationsControllerProvider);
    final patient = profileState.patientProfiles.isEmpty
        ? null
        : profileState.patientProfiles.first;

    if (patient != null && _loadedPatientId != patient.id) {
      _loadedPatientId = patient.id;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(notificationsControllerProvider.notifier)
            .loadNotifications(patient.id);
      });
    }

    return AppScaffold(
      title: 'Notifications',
      showBottomNavigation: true,
      actions: [
        IconButton(
          tooltip: 'Refresh notifications',
          icon: const Icon(Icons.refresh),
          onPressed: patient == null ? null : () => _refresh(patient.id),
        ),
      ],
      body: profileState.isLoading
          ? const AppLoadingState(message: 'Loading your profile...')
          : patient == null
          ? AppErrorState(
              message: authState.user == null
                  ? 'Please sign in again to view notifications.'
                  : 'Patient profile access is not available yet.',
            )
          : notificationState.isLoading
          ? const AppLoadingState(message: 'Loading notifications...')
          : notificationState.errorMessage != null
          ? AppErrorState(
              message: notificationState.errorMessage!,
              onRetry: () => _refresh(patient.id),
            )
          : RefreshIndicator(
              onRefresh: () => _refresh(patient.id),
              child: ListView(
                shrinkWrap: true,
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  _NotificationFilterBar(
                    unreadCount: notificationState.unreadCount,
                    unreadOnly: notificationState.showUnreadOnly,
                    onChanged: (value) => ref
                        .read(notificationsControllerProvider.notifier)
                        .setUnreadOnly(value),
                  ),
                  const SizedBox(height: AppSizes.md),
                  if (notificationState.visibleNotifications.isEmpty)
                    const AppEmptyState(
                      title: 'No notifications yet',
                      message:
                          'Appointment and queue updates will appear here.',
                    )
                  else
                    ...notificationState.visibleNotifications.map(
                      (notification) =>
                          NotificationListCard(notification: notification),
                    ),
                ],
              ),
            ),
    );
  }

  Future<void> _loadIfReady() async {
    final user = ref.read(authControllerProvider).user;
    if (user == null) return;
    if (ref.read(profileControllerProvider).patientProfiles.isEmpty) {
      await ref
          .read(profileControllerProvider.notifier)
          .loadLinkedPatientProfiles(user.id);
    }
    final profiles = ref.read(profileControllerProvider).patientProfiles;
    if (profiles.isNotEmpty) await _refresh(profiles.first.id);
  }

  Future<void> _refresh(String patientId) async {
    await ref
        .read(notificationsControllerProvider.notifier)
        .loadNotifications(patientId);
  }
}

class _NotificationFilterBar extends StatelessWidget {
  const _NotificationFilterBar({
    required this.unreadCount,
    required this.unreadOnly,
    required this.onChanged,
  });

  final int unreadCount;
  final bool unreadOnly;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<bool>(
      segments: [
        const ButtonSegment(value: false, label: Text('All')),
        ButtonSegment(value: true, label: Text('Unread ($unreadCount)')),
      ],
      selected: {unreadOnly},
      onSelectionChanged: (values) => onChanged(values.first),
    );
  }
}
