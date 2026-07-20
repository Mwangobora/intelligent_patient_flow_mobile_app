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
      appointmentId: json['appointment'] as String? ?? '',
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
