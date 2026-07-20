import '../../../../core/utils/json_list.dart';

class QueueEntryStatus {
  const QueueEntryStatus._();

  static const waiting = 'waiting';
  static const called = 'called';
  static const skipped = 'skipped';
  static const inService = 'in_service';
  static const completed = 'completed';
  static const cancelled = 'cancelled';
  static const transferred = 'transferred';

  static const terminal = {completed, cancelled, transferred};
}

class QueueEntry {
  const QueueEntry({
    required this.id,
    required this.queueId,
    required this.patientCheckinId,
    required this.sequenceNumber,
    required this.displayQueueNumber,
    required this.priorityLevel,
    required this.status,
    required this.joinedAt,
    this.queueStatus,
    this.servicePointCode,
    this.servicePointName,
    this.facilityId,
    this.facilityName,
    this.appointmentId,
    this.queuePosition,
    this.estimatedWaitMinutes,
    this.priorityLabel,
    this.lastUpdatedAt,
    this.calledAt,
    this.serviceStartedAt,
    this.serviceCompletedAt,
    this.cancelledAt,
  });

  final String id;
  final String queueId;
  final String? queueStatus;
  final String? servicePointCode;
  final String? servicePointName;
  final String? facilityId;
  final String? facilityName;
  final String patientCheckinId;
  final String? appointmentId;
  final int sequenceNumber;
  final String displayQueueNumber;
  final int? queuePosition;
  final int? estimatedWaitMinutes;
  final String? priorityLabel;
  final int priorityLevel;
  final String status;
  final DateTime joinedAt;
  final DateTime? lastUpdatedAt;
  final DateTime? calledAt;
  final DateTime? serviceStartedAt;
  final DateTime? serviceCompletedAt;
  final DateTime? cancelledAt;

  bool get isActive => !QueueEntryStatus.terminal.contains(status);

  factory QueueEntry.fromJson(Map<String, dynamic> json) {
    return QueueEntry(
      id: json['id'] as String? ?? '',
      queueId: json['queue'] as String? ?? '',
      queueStatus: json['queue_status'] as String?,
      servicePointCode: json['service_point_code'] as String?,
      servicePointName: json['service_point_name'] as String?,
      facilityId: json['facility'] as String?,
      facilityName: json['facility_name'] as String?,
      patientCheckinId: json['patient_checkin'] as String? ?? '',
      appointmentId: json['appointment'] as String?,
      sequenceNumber: parseInt(json['sequence_number']),
      displayQueueNumber:
          json['display_queue_number'] as String? ??
          '${json['service_point_code'] ?? 'Q'}-${parseInt(json['sequence_number']).toString().padLeft(3, '0')}',
      queuePosition: parseNullableInt(json['queue_position']),
      estimatedWaitMinutes: parseNullableInt(json['estimated_wait_minutes']),
      priorityLabel: json['priority_label'] as String?,
      priorityLevel: parseInt(json['priority_level']),
      status: json['status'] as String? ?? QueueEntryStatus.waiting,
      joinedAt: DateTime.parse(json['joined_at'] as String),
      lastUpdatedAt: parseOptionalDateTime(json['last_updated_at']),
      calledAt: parseOptionalDateTime(json['called_at']),
      serviceStartedAt: parseOptionalDateTime(json['service_started_at']),
      serviceCompletedAt: parseOptionalDateTime(json['service_completed_at']),
      cancelledAt: parseOptionalDateTime(json['cancelled_at']),
    );
  }

  factory QueueEntry.fromPatientJson(Map<String, dynamic> json) {
    final servicePoint = _mapOrNull(json['service_point']);
    final facility = _mapOrNull(json['facility']);
    return QueueEntry(
      id: json['queue_entry_id'] as String? ?? '',
      queueId: json['queue_id'] as String? ?? '',
      queueStatus: json['queue_status'] as String?,
      servicePointCode: servicePoint?['code'] as String?,
      servicePointName:
          servicePoint?['name'] as String? ?? json['queue_name'] as String?,
      facilityId: facility?['id'] as String?,
      facilityName: facility?['name'] as String?,
      patientCheckinId: '',
      appointmentId: json['appointment_id'] as String?,
      sequenceNumber: 0,
      displayQueueNumber: json['queue_number'] as String? ?? '',
      queuePosition: parseNullableInt(json['people_ahead']),
      estimatedWaitMinutes: parseNullableInt(json['estimated_wait_minutes']),
      priorityLabel: json['priority_label'] as String?,
      priorityLevel: _priorityLevelFromLabel(json['priority_label'] as String?),
      status: json['status'] as String? ?? QueueEntryStatus.waiting,
      joinedAt:
          parseOptionalDateTime(json['joined_at']) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      lastUpdatedAt: parseOptionalDateTime(json['last_updated_at']),
      calledAt: parseOptionalDateTime(json['called_at']),
      serviceStartedAt: parseOptionalDateTime(json['service_started_at']),
      serviceCompletedAt: parseOptionalDateTime(json['completed_at']),
      cancelledAt: parseOptionalDateTime(json['cancelled_at']),
    );
  }
}

class QueueEntryEvent {
  const QueueEntryEvent({
    required this.id,
    required this.queueEntryId,
    required this.eventType,
    required this.occurredAt,
    this.fromStatus,
    this.toStatus,
    this.reason,
  });

  final String id;
  final String queueEntryId;
  final String eventType;
  final String? fromStatus;
  final String? toStatus;
  final String? reason;
  final DateTime occurredAt;

  factory QueueEntryEvent.fromJson(Map<String, dynamic> json) {
    return QueueEntryEvent(
      id: json['id'] as String? ?? '',
      queueEntryId: json['queue_entry'] as String? ?? '',
      eventType: json['event_type'] as String? ?? '',
      fromStatus: json['from_status'] as String?,
      toStatus: json['to_status'] as String?,
      reason: json['reason'] as String?,
      occurredAt: DateTime.parse(json['occurred_at'] as String),
    );
  }
}

class WaitTimePrediction {
  const WaitTimePrediction({
    required this.id,
    required this.queueEntryId,
    required this.predictedWaitMinutes,
    required this.predictionMethod,
    required this.generatedAt,
  });

  final String id;
  final String queueEntryId;
  final int predictedWaitMinutes;
  final String predictionMethod;
  final DateTime generatedAt;

  factory WaitTimePrediction.fromJson(Map<String, dynamic> json) {
    return WaitTimePrediction(
      id: json['id'] as String? ?? '',
      queueEntryId: json['queue_entry'] as String? ?? '',
      predictedWaitMinutes: parseInt(json['predicted_wait_minutes']),
      predictionMethod: json['prediction_method'] as String? ?? 'rule_based',
      generatedAt: DateTime.parse(json['generated_at'] as String),
    );
  }
}

Map<String, dynamic>? _mapOrNull(Object? value) {
  if (value is Map<String, dynamic>) return value;
  return null;
}

int _priorityLevelFromLabel(String? label) {
  return switch (label?.toLowerCase()) {
    'priority' => 1,
    'urgent' => 2,
    'emergency' => 3,
    _ => 0,
  };
}
