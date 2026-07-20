import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_status_badge.dart';
import '../../data/models/notification_models.dart';

class NotificationListCard extends StatelessWidget {
  const NotificationListCard({required this.notification, super.key});

  final PatientNotification notification;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.md),
      child: AppCard(
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            backgroundColor: notification.isUnread
                ? AppColors.softCyan
                : AppColors.background,
            child: Icon(_icon, color: AppColors.primaryTeal),
          ),
          title: Text(
            _title,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          subtitle: Text(
            '$_subtitle\n${DateFormatter.readableDateTime(notification.createdAt)}',
          ),
          isThreeLine: true,
          trailing: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              NotificationStatusBadge(status: notification.status),
              if (notification.isUnread)
                const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Icon(Icons.circle, size: 8, color: AppColors.info),
                ),
            ],
          ),
          onTap: () => context.go('/notifications/${notification.id}'),
        ),
      ),
    );
  }

  IconData get _icon {
    return switch (notification.notificationType) {
      PatientNotificationType.appointmentConfirmation ||
      PatientNotificationType.appointmentReminder ||
      PatientNotificationType.appointmentRescheduled ||
      PatientNotificationType.appointmentCancelled => Icons.event_note,
      PatientNotificationType.queueJoined ||
      PatientNotificationType.queueUpdated ||
      PatientNotificationType.queueCalled => Icons.confirmation_num_outlined,
      _ => Icons.notifications_outlined,
    };
  }

  String get _title => notificationTitle(notification.notificationType);

  String get _subtitle {
    return switch (notification.notificationType) {
      PatientNotificationType.queueCalled =>
        'Your queue status has changed. Please check your queue screen.',
      PatientNotificationType.queueJoined =>
        'You have been added to a hospital queue.',
      PatientNotificationType.queueUpdated => 'Your queue has an update.',
      PatientNotificationType.appointmentReminder =>
        'You have an upcoming appointment reminder.',
      PatientNotificationType.appointmentCancelled =>
        'An appointment was cancelled.',
      PatientNotificationType.appointmentRescheduled =>
        'An appointment was rescheduled.',
      PatientNotificationType.appointmentConfirmation =>
        'Your appointment has been confirmed.',
      _ => 'You have a patient notification.',
    };
  }
}

class NotificationStatusBadge extends StatelessWidget {
  const NotificationStatusBadge({required this.status, super.key});

  final String status;

  @override
  Widget build(BuildContext context) {
    return AppStatusBadge(label: _label, color: _color);
  }

  String get _label => status
      .split('_')
      .map(
        (part) => part.isEmpty
            ? part
            : '${part[0].toUpperCase()}${part.substring(1)}',
      )
      .join(' ');

  Color get _color {
    return switch (status) {
      PatientNotificationStatus.delivered ||
      PatientNotificationStatus.sent => AppColors.success,
      PatientNotificationStatus.failed ||
      PatientNotificationStatus.cancelled => AppColors.danger,
      PatientNotificationStatus.processing => AppColors.info,
      _ => AppColors.warning,
    };
  }
}

String notificationTitle(String value) {
  return switch (value) {
    PatientNotificationType.appointmentConfirmation =>
      'Appointment confirmation',
    PatientNotificationType.appointmentReminder => 'Appointment reminder',
    PatientNotificationType.appointmentRescheduled => 'Appointment rescheduled',
    PatientNotificationType.appointmentCancelled => 'Appointment cancelled',
    PatientNotificationType.queueJoined => 'Queue joined',
    PatientNotificationType.queueUpdated => 'Queue updated',
    PatientNotificationType.queueCalled => 'Queue called',
    _ => 'General notification',
  };
}
