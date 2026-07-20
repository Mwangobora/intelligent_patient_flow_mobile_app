class AppointmentStatus {
  const AppointmentStatus._();

  static const pending = 'pending';
  static const confirmed = 'confirmed';
  static const checkedIn = 'checked_in';
  static const queued = 'queued';
  static const inService = 'in_service';
  static const completed = 'completed';
  static const cancelled = 'cancelled';
  static const noShow = 'no_show';
  static const rescheduled = 'rescheduled';

  static const terminal = {completed, cancelled, noShow, rescheduled};
}

class Appointment {
  const Appointment({
    required this.id,
    required this.facilityId,
    required this.patientId,
    required this.facilitySpecialtyId,
    required this.appointmentNumber,
    required this.scheduledStart,
    required this.scheduledEnd,
    required this.status,
    required this.bookingChannel,
    this.facilityName,
    this.specialtyName,
    this.practitionerNumber,
    this.practitionerFacilityAssignmentId,
    this.practitionerSpecialtyAssignmentId,
    this.practitionerShiftId,
    this.appointmentSlotId,
    this.slotStatus,
    this.rescheduledFromId,
    this.cancellationReason,
    this.createdAt,
  });

  final String id;
  final String facilityId;
  final String? facilityName;
  final String patientId;
  final String facilitySpecialtyId;
  final String? specialtyName;
  final String? practitionerFacilityAssignmentId;
  final String? practitionerSpecialtyAssignmentId;
  final String? practitionerShiftId;
  final String? practitionerNumber;
  final String? appointmentSlotId;
  final String? slotStatus;
  final String appointmentNumber;
  final DateTime scheduledStart;
  final DateTime scheduledEnd;
  final String status;
  final String bookingChannel;
  final String? rescheduledFromId;
  final String? cancellationReason;
  final DateTime? createdAt;

  bool get canCancel => !AppointmentStatus.terminal.contains(status);
  bool get canReschedule => !AppointmentStatus.terminal.contains(status);
  bool get isPast => scheduledEnd.isBefore(DateTime.now());

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] as String? ?? '',
      facilityId: json['facility'] as String? ?? '',
      facilityName: json['facility_name'] as String?,
      patientId: json['patient'] as String? ?? '',
      facilitySpecialtyId: json['facility_specialty'] as String? ?? '',
      specialtyName: json['specialty_name'] as String?,
      practitionerFacilityAssignmentId:
          json['practitioner_facility_assignment'] as String?,
      practitionerSpecialtyAssignmentId:
          json['practitioner_specialty_assignment'] as String?,
      practitionerShiftId: json['practitioner_shift'] as String?,
      practitionerNumber: json['practitioner_number'] as String?,
      appointmentSlotId: json['appointment_slot'] as String?,
      slotStatus: json['slot_status'] as String?,
      appointmentNumber: json['appointment_number'] as String? ?? '',
      scheduledStart: DateTime.parse(json['scheduled_start'] as String),
      scheduledEnd: DateTime.parse(json['scheduled_end'] as String),
      status: json['status'] as String? ?? AppointmentStatus.pending,
      bookingChannel: json['booking_channel'] as String? ?? 'mobile',
      rescheduledFromId: json['rescheduled_from'] as String?,
      cancellationReason: json['cancellation_reason'] as String?,
      createdAt: _parseDateTime(json['created_at']),
    );
  }
}

class AppointmentStatusEvent {
  const AppointmentStatusEvent({
    required this.id,
    required this.fromStatus,
    required this.toStatus,
    required this.changeSource,
    required this.changedAt,
    this.reason,
  });

  final String id;
  final String? fromStatus;
  final String toStatus;
  final String changeSource;
  final DateTime changedAt;
  final String? reason;

  factory AppointmentStatusEvent.fromJson(Map<String, dynamic> json) {
    return AppointmentStatusEvent(
      id: json['id'] as String? ?? '',
      fromStatus: json['from_status'] as String?,
      toStatus: json['to_status'] as String? ?? '',
      changeSource: json['change_source'] as String? ?? '',
      changedAt: DateTime.parse(json['changed_at'] as String),
      reason: json['reason'] as String?,
    );
  }
}

DateTime? _parseDateTime(dynamic value) {
  if (value is! String || value.isEmpty) return null;
  return DateTime.tryParse(value);
}
