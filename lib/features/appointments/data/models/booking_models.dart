class FacilityOption {
  const FacilityOption({
    required this.id,
    required this.name,
    required this.code,
    required this.organizationId,
    required this.isActive,
    this.organizationName,
    this.timezone,
  });

  final String id;
  final String name;
  final String code;
  final String organizationId;
  final String? organizationName;
  final String? timezone;
  final bool isActive;

  factory FacilityOption.fromJson(Map<String, dynamic> json) {
    return FacilityOption(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      code: json['code'] as String? ?? '',
      organizationId: json['organization'] as String? ?? '',
      organizationName: json['organization_name'] as String?,
      timezone: json['timezone'] as String?,
      isActive: json['is_active'] as bool? ?? false,
    );
  }
}

class FacilitySpecialtyOption {
  const FacilitySpecialtyOption({
    required this.id,
    required this.facilityId,
    required this.specialtyId,
    required this.specialtyName,
    required this.durationMinutes,
    required this.acceptsAppointments,
    required this.isActive,
    this.facilityName,
    this.departmentName,
  });

  final String id;
  final String facilityId;
  final String? facilityName;
  final String specialtyId;
  final String specialtyName;
  final String? departmentName;
  final int durationMinutes;
  final bool acceptsAppointments;
  final bool isActive;

  factory FacilitySpecialtyOption.fromJson(Map<String, dynamic> json) {
    return FacilitySpecialtyOption(
      id: json['id'] as String? ?? '',
      facilityId: json['facility'] as String? ?? '',
      facilityName: json['facility_name'] as String?,
      specialtyId: json['specialty'] as String? ?? '',
      specialtyName: json['specialty_name'] as String? ?? '',
      departmentName: json['department_name'] as String?,
      durationMinutes: json['appointment_duration_minutes'] as int? ?? 30,
      acceptsAppointments: json['accepts_appointments'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? false,
    );
  }
}

class AppointmentSlotOption {
  const AppointmentSlotOption({
    required this.id,
    required this.practitionerShiftId,
    required this.facilitySpecialtyId,
    required this.startsAt,
    required this.endsAt,
    required this.capacity,
    required this.bookedCount,
    required this.status,
    required this.isOnlineBookable,
    this.practitionerNumber,
    this.specialtyName,
  });

  final String id;
  final String practitionerShiftId;
  final String? practitionerNumber;
  final String facilitySpecialtyId;
  final String? specialtyName;
  final DateTime startsAt;
  final DateTime endsAt;
  final int capacity;
  final int bookedCount;
  final String status;
  final bool isOnlineBookable;

  bool get isBookable =>
      status == 'available' && isOnlineBookable && bookedCount < capacity;

  factory AppointmentSlotOption.fromJson(Map<String, dynamic> json) {
    return AppointmentSlotOption(
      id: json['id'] as String? ?? '',
      practitionerShiftId: json['practitioner_shift'] as String? ?? '',
      practitionerNumber: json['practitioner_number'] as String?,
      facilitySpecialtyId: json['facility_specialty'] as String? ?? '',
      specialtyName: json['specialty_name'] as String?,
      startsAt: DateTime.parse(json['starts_at'] as String),
      endsAt: DateTime.parse(json['ends_at'] as String),
      capacity: json['capacity'] as int? ?? 1,
      bookedCount: json['booked_count'] as int? ?? 0,
      status: json['status'] as String? ?? 'available',
      isOnlineBookable: json['is_online_bookable'] as bool? ?? false,
    );
  }
}
