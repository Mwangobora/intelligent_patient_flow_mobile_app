class AuthUser {
  const AuthUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.isActive,
    required this.hasGlobalAccess,
    this.email,
    this.phoneNumber,
    this.middleName,
    this.memberships = const [],
    this.permissions = const [],
    this.linkedPatientId,
    this.patientSummary,
  });

  final String id;
  final String? email;
  final String? phoneNumber;
  final String firstName;
  final String? middleName;
  final String lastName;
  final bool isActive;
  final bool hasGlobalAccess;
  final String? linkedPatientId;
  final AuthPatientSummary? patientSummary;
  final List<AuthMembership> memberships;
  final List<String> permissions;

  String get fullName => [
    firstName,
    middleName,
    lastName,
  ].where((part) => part != null && part.trim().isNotEmpty).join(' ');

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] as String? ?? '',
      email: json['email'] as String?,
      phoneNumber: json['phone_number'] as String?,
      firstName: json['first_name'] as String? ?? '',
      middleName: json['middle_name'] as String?,
      lastName: json['last_name'] as String? ?? '',
      isActive: json['is_active'] as bool? ?? false,
      hasGlobalAccess: json['has_global_access'] as bool? ?? false,
      linkedPatientId: json['linked_patient_id'] as String?,
      patientSummary: json['patient_summary'] is Map<String, dynamic>
          ? AuthPatientSummary.fromJson(
              json['patient_summary'] as Map<String, dynamic>,
            )
          : null,
      memberships: (json['memberships'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(AuthMembership.fromJson)
          .toList(),
      permissions: (json['permissions'] as List<dynamic>? ?? [])
          .whereType<String>()
          .toList(),
    );
  }
}

class AuthPatientSummary {
  const AuthPatientSummary({
    required this.id,
    required this.patientNumber,
    required this.firstName,
    required this.lastName,
    required this.isActive,
    this.middleName,
    this.organizationName,
    this.registeredFacilityName,
  });

  final String id;
  final String patientNumber;
  final String firstName;
  final String? middleName;
  final String lastName;
  final String? organizationName;
  final String? registeredFacilityName;
  final bool isActive;

  factory AuthPatientSummary.fromJson(Map<String, dynamic> json) {
    return AuthPatientSummary(
      id: json['id'] as String? ?? '',
      patientNumber: json['patient_number'] as String? ?? '',
      firstName: json['first_name'] as String? ?? '',
      middleName: json['middle_name'] as String?,
      lastName: json['last_name'] as String? ?? '',
      organizationName: json['organization_name'] as String?,
      registeredFacilityName: json['registered_facility_name'] as String?,
      isActive: json['is_active'] as bool? ?? false,
    );
  }
}

class AuthMembership {
  const AuthMembership({
    required this.id,
    required this.organizationId,
    required this.organizationName,
    required this.isActive,
    this.facilityId,
    this.facilityName,
  });

  final String id;
  final String organizationId;
  final String organizationName;
  final String? facilityId;
  final String? facilityName;
  final bool isActive;

  factory AuthMembership.fromJson(Map<String, dynamic> json) {
    return AuthMembership(
      id: json['id'] as String? ?? '',
      organizationId: json['organization'] as String? ?? '',
      organizationName: json['organization_name'] as String? ?? '',
      facilityId: json['facility'] as String?,
      facilityName: json['facility_name'] as String?,
      isActive: json['is_active'] as bool? ?? false,
    );
  }
}
