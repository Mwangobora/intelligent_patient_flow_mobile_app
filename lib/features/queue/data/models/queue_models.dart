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
    this.appointmentId,
    this.queuePosition,
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
  final String patientCheckinId;
  final String? appointmentId;
  final int sequenceNumber;
  final String displayQueueNumber;
  final int? queuePosition;
  final int priorityLevel;
  final String status;
  final DateTime joinedAt;
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
      patientCheckinId: json['patient_checkin'] as String? ?? '',
      appointmentId: json['appointment'] as String?,
      sequenceNumber: parseInt(json['sequence_number']),
      displayQueueNumber:
          json['display_queue_number'] as String? ??
          '${json['service_point_code'] ?? 'Q'}-${parseInt(json['sequence_number']).toString().padLeft(3, '0')}',
      queuePosition: parseNullableInt(json['queue_position']),
      priorityLevel: parseInt(json['priority_level']),
      status: json['status'] as String? ?? QueueEntryStatus.waiting,
      joinedAt: DateTime.parse(json['joined_at'] as String),
      calledAt: parseOptionalDateTime(json['called_at']),
      serviceStartedAt: parseOptionalDateTime(json['service_started_at']),
      serviceCompletedAt: parseOptionalDateTime(json['service_completed_at']),
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
