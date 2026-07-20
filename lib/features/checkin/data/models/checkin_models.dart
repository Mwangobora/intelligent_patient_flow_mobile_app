import '../../../../core/utils/json_list.dart';

class CheckinMethod {
  const CheckinMethod._();

  static const reception = 'reception';
  static const mobile = 'mobile';
  static const qrCode = 'qr_code';
  static const selfService = 'self_service';
}

class PatientCheckin {
  const PatientCheckin({
    required this.id,
    required this.facilityId,
    required this.patientId,
    required this.checkinMethod,
    required this.checkedInAt,
    this.facilityName,
    this.appointmentId,
    this.appointmentNumber,
    this.facilitySpecialtyId,
    this.specialtyName,
    this.notes,
    this.voidedAt,
  });

  final String id;
  final String facilityId;
  final String? facilityName;
  final String patientId;
  final String? appointmentId;
  final String? appointmentNumber;
  final String? facilitySpecialtyId;
  final String? specialtyName;
  final String checkinMethod;
  final DateTime checkedInAt;
  final String? notes;
  final DateTime? voidedAt;

  bool get isVoided => voidedAt != null;

  factory PatientCheckin.fromJson(Map<String, dynamic> json) {
    return PatientCheckin(
      id: json['id'] as String? ?? '',
      facilityId: json['facility'] as String? ?? '',
      facilityName: json['facility_name'] as String?,
      patientId: json['patient'] as String? ?? '',
      appointmentId: json['appointment'] as String?,
      appointmentNumber: json['appointment_number'] as String?,
      facilitySpecialtyId: json['facility_specialty'] as String?,
      specialtyName: json['specialty_name'] as String?,
      checkinMethod:
          json['checkin_method'] as String? ?? CheckinMethod.reception,
      checkedInAt: DateTime.parse(json['checked_in_at'] as String),
      notes: json['notes'] as String?,
      voidedAt: parseOptionalDateTime(json['voided_at']),
    );
  }
}

class CheckinEligibility {
  const CheckinEligibility({
    required this.appointmentId,
    required this.canCheckIn,
    required this.appointmentStatus,
    required this.scheduledStart,
    required this.scheduledEnd,
    required this.hasActiveToken,
    this.reason,
    this.facility,
    this.specialty,
    this.department,
    this.existingCheckin,
    this.tokenExpiresAt,
  });

  final String appointmentId;
  final bool canCheckIn;
  final String? reason;
  final String appointmentStatus;
  final DateTime scheduledStart;
  final DateTime scheduledEnd;
  final Map<String, dynamic>? facility;
  final Map<String, dynamic>? specialty;
  final Map<String, dynamic>? department;
  final PatientCheckin? existingCheckin;
  final bool hasActiveToken;
  final DateTime? tokenExpiresAt;

  factory CheckinEligibility.fromJson(Map<String, dynamic> json) {
    final existing = json['existing_checkin'];
    return CheckinEligibility(
      appointmentId: json['appointment_id'] as String? ?? '',
      canCheckIn: parseBool(json['can_check_in']),
      reason: json['reason'] as String?,
      appointmentStatus: json['appointment_status'] as String? ?? '',
      scheduledStart: DateTime.parse(json['scheduled_start'] as String),
      scheduledEnd: DateTime.parse(json['scheduled_end'] as String),
      facility: _mapOrNull(json['facility']),
      specialty: _mapOrNull(json['specialty']),
      department: _mapOrNull(json['department']),
      existingCheckin: existing is Map<String, dynamic>
          ? PatientCheckin.fromJson({
              'id': existing['id'],
              'facility': json['facility'] is Map<String, dynamic>
                  ? (json['facility'] as Map<String, dynamic>)['id']
                  : null,
              'patient': '',
              'appointment': json['appointment_id'],
              'checkin_method': existing['checkin_method'],
              'checked_in_at': existing['checked_in_at'],
            })
          : null,
      hasActiveToken: parseBool(json['has_active_token']),
      tokenExpiresAt: parseOptionalDateTime(json['token_expires_at']),
    );
  }
}

class AppointmentCheckinResult {
  const AppointmentCheckinResult({
    required this.checkin,
    required this.message,
    this.queueEntry,
  });

  final PatientCheckin checkin;
  final Map<String, dynamic>? queueEntry;
  final String message;

  factory AppointmentCheckinResult.fromJson(Map<String, dynamic> json) {
    return AppointmentCheckinResult(
      checkin: PatientCheckin.fromJson(
        json['checkin'] as Map<String, dynamic>? ?? <String, dynamic>{},
      ),
      queueEntry: _mapOrNull(json['queue_entry']),
      message: json['message'] as String? ?? 'Check-in successful.',
    );
  }
}

class CheckinToken {
  const CheckinToken({
    required this.id,
    required this.appointmentId,
    required this.expiresAt,
    required this.isActive,
    this.appointmentNumber,
    this.patientNumber,
    this.facilityName,
    this.usedAt,
    this.patientCheckinId,
    this.revokedAt,
    this.rawToken,
  });

  final String id;
  final String appointmentId;
  final String? appointmentNumber;
  final String? patientNumber;
  final String? facilityName;
  final DateTime expiresAt;
  final DateTime? usedAt;
  final String? patientCheckinId;
  final DateTime? revokedAt;
  final bool isActive;
  final String? rawToken;

  bool get isExpired => expiresAt.isBefore(DateTime.now());
  bool get canUse =>
      isActive && usedAt == null && revokedAt == null && !isExpired;

  factory CheckinToken.fromJson(Map<String, dynamic> json) {
    return CheckinToken(
      id: json['id'] as String? ?? '',
      appointmentId:
          json['appointment'] as String? ??
          json['appointment_id'] as String? ??
          '',
      appointmentNumber: json['appointment_number'] as String?,
      patientNumber: json['patient_number'] as String?,
      facilityName: json['facility_name'] as String?,
      expiresAt: DateTime.parse(json['expires_at'] as String),
      usedAt: parseOptionalDateTime(json['used_at']),
      patientCheckinId: json['patient_checkin'] as String?,
      revokedAt: parseOptionalDateTime(json['revoked_at']),
      isActive: parseBool(json['is_active']),
      rawToken: json['raw_token'] as String?,
    );
  }
}

Map<String, dynamic>? _mapOrNull(Object? value) {
  if (value is Map<String, dynamic>) return value;
  return null;
}
