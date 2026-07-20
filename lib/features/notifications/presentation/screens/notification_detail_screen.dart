import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/app_providers.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_error_state.dart';
import '../../../../shared/widgets/app_loading_state.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../data/models/notification_models.dart';
import '../widgets/notification_widgets.dart';

class NotificationDetailScreen extends ConsumerStatefulWidget {
  const NotificationDetailScreen({required this.notificationId, super.key});

  final String notificationId;

  @override
  ConsumerState<NotificationDetailScreen> createState() =>
      _NotificationDetailScreenState();
}

class _NotificationDetailScreenState
    extends ConsumerState<NotificationDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(notificationsControllerProvider.notifier)
          .loadNotificationDetail(widget.notificationId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationsControllerProvider);
    final notification = state.selectedNotification;

    return AppScaffold(
      title: 'Notification detail',
      showBottomNavigation: true,
      body: state.isLoading
          ? const AppLoadingState(message: 'Loading notification...')
          : state.errorMessage != null
          ? AppErrorState(
              message: state.errorMessage!,
              onRetry: () => ref
                  .read(notificationsControllerProvider.notifier)
                  .loadNotificationDetail(widget.notificationId),
            )
          : notification == null
          ? const AppErrorState(message: 'Notification was not found.')
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (state.successMessage != null) ...[
                  _SuccessBanner(message: state.successMessage!),
                  const SizedBox(height: AppSizes.md),
                ],
                _NotificationDetailCard(notification: notification),
                if (notification.isUnread) ...[
                  const SizedBox(height: AppSizes.lg),
                  AppButton(
                    label: 'Mark as read',
                    isLoading: state.isActionLoading,
                    onPressed: () => ref
                        .read(notificationsControllerProvider.notifier)
                        .markAsRead(notification.id),
                  ),
                ],
              ],
            ),
    );
  }
}

class _NotificationDetailCard extends StatelessWidget {
  const _NotificationDetailCard({required this.notification});

  final PatientNotification notification;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                backgroundColor: AppColors.softCyan,
                child: Icon(
                  Icons.notifications_outlined,
                  color: AppColors.primaryTeal,
                ),
              ),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: Text(
                  notificationTitle(notification.notificationType),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              NotificationStatusBadge(status: notification.status),
            ],
          ),
          const SizedBox(height: AppSizes.lg),
          _InfoRow(label: 'Channel', value: notification.channel),
          _InfoRow(
            label: 'Scheduled for',
            value: DateFormatter.readableDateTime(notification.scheduledFor),
          ),
          if (notification.deliveredAt != null)
            _InfoRow(
              label: 'Delivered',
              value: DateFormatter.readableDateTime(notification.deliveredAt!),
            ),
          if (notification.readAt != null)
            _InfoRow(
              label: 'Read',
              value: DateFormatter.readableDateTime(notification.readAt!),
            ),
          if (notification.appointmentId != null)
            _InfoRow(label: 'Related item', value: 'Appointment update'),
          if (notification.queueEntryId != null)
            _InfoRow(label: 'Related item', value: 'Queue update'),
          if (notification.failureReason != null)
            _InfoRow(
              label: 'Delivery note',
              value: notification.failureReason!,
            ),
          const SizedBox(height: AppSizes.md),
          const Text(
            'Sensitive message content is protected and not shown in this mobile view.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

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
            width: 120,
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

class _SuccessBanner extends StatelessWidget {
  const _SuccessBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSizes.radius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Text(message, style: const TextStyle(color: AppColors.success)),
      ),
    );
  }
}
