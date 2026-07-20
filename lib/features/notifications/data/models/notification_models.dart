import '../../../../core/utils/json_list.dart';

class PatientNotificationType {
  const PatientNotificationType._();

  static const appointmentConfirmation = 'appointment_confirmation';
  static const appointmentReminder = 'appointment_reminder';
  static const appointmentRescheduled = 'appointment_rescheduled';
  static const appointmentCancelled = 'appointment_cancelled';
  static const queueJoined = 'queue_joined';
  static const queueUpdated = 'queue_updated';
  static const queueCalled = 'queue_called';
  static const general = 'general';
}

class PatientNotificationStatus {
  const PatientNotificationStatus._();

  static const pending = 'pending';
  static const processing = 'processing';
  static const sent = 'sent';
  static const delivered = 'delivered';
  static const failed = 'failed';
  static const cancelled = 'cancelled';
}

class PatientNotification {
  const PatientNotification({
    required this.id,
    required this.patientId,
    required this.notificationType,
    required this.channel,
    required this.status,
    required this.scheduledFor,
    required this.attemptCount,
    required this.createdAt,
    this.patientNumber,
    this.appointmentId,
    this.queueEntryId,
    this.recipientUserId,
    this.lastAttemptAt,
    this.sentAt,
    this.deliveredAt,
    this.readAt,
    this.failedAt,
    this.failureReason,
    this.providerMessageId,
  });

  final String id;
  final String patientId;
  final String? patientNumber;
  final String? appointmentId;
  final String? queueEntryId;
  final String notificationType;
  final String channel;
  final String? recipientUserId;
  final DateTime scheduledFor;
  final String status;
  final int attemptCount;
  final DateTime? lastAttemptAt;
  final DateTime? sentAt;
  final DateTime? deliveredAt;
  final DateTime? readAt;
  final DateTime? failedAt;
  final String? failureReason;
  final String? providerMessageId;
  final DateTime createdAt;

  bool get canMarkRead =>
      channel == 'in_app' && status == PatientNotificationStatus.delivered;
  bool get isUnread => canMarkRead && readAt == null;

  factory PatientNotification.fromJson(Map<String, dynamic> json) {
    return PatientNotification(
      id: json['id'] as String? ?? '',
      patientId: json['patient'] as String? ?? '',
      patientNumber: json['patient_number'] as String?,
      appointmentId: json['appointment'] as String?,
      queueEntryId: json['queue_entry'] as String?,
      notificationType:
          json['notification_type'] as String? ??
          PatientNotificationType.general,
      channel: json['channel'] as String? ?? 'in_app',
      recipientUserId: json['recipient_user'] as String?,
      scheduledFor:
          parseOptionalDateTime(json['scheduled_for']) ?? DateTime.now(),
      status: json['status'] as String? ?? PatientNotificationStatus.pending,
      attemptCount: parseInt(json['attempt_count']),
      lastAttemptAt: parseOptionalDateTime(json['last_attempt_at']),
      sentAt: parseOptionalDateTime(json['sent_at']),
      deliveredAt: parseOptionalDateTime(json['delivered_at']),
      readAt: parseOptionalDateTime(json['read_at']),
      failedAt: parseOptionalDateTime(json['failed_at']),
      failureReason: json['failure_reason'] as String?,
      providerMessageId: json['provider_message_id'] as String?,
      createdAt: parseOptionalDateTime(json['created_at']) ?? DateTime.now(),
    );
  }
}

class PushDevice {
  const PushDevice({
    required this.id,
    required this.userId,
    required this.platform,
    required this.isActive,
    required this.createdAt,
    this.deviceName,
    this.appVersion,
    this.lastSeenAt,
    this.revokedAt,
  });

  final String id;
  final String userId;
  final String platform;
  final String? deviceName;
  final String? appVersion;
  final DateTime? lastSeenAt;
  final bool isActive;
  final DateTime? revokedAt;
  final DateTime createdAt;

  factory PushDevice.fromJson(Map<String, dynamic> json) {
    return PushDevice(
      id: json['id'] as String? ?? '',
      userId: json['user'] as String? ?? '',
      platform: json['platform'] as String? ?? '',
      deviceName: json['device_name'] as String?,
      appVersion: json['app_version'] as String?,
      lastSeenAt: parseOptionalDateTime(json['last_seen_at']),
      isActive: parseBool(json['is_active']),
      revokedAt: parseOptionalDateTime(json['revoked_at']),
      createdAt: parseOptionalDateTime(json['created_at']) ?? DateTime.now(),
    );
  }
}
