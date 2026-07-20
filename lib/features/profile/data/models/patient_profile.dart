class PatientProfile {
  const PatientProfile({
    required this.id,
    required this.organizationId,
    required this.patientNumber,
    required this.firstName,
    required this.lastName,
    required this.isActive,
    this.email,
    this.phoneNumber,
    this.middleName,
    this.dateOfBirth,
    this.sexCode,
  });

  final String id;
  final String organizationId;
  final String patientNumber;
  final String firstName;
  final String? middleName;
  final String lastName;
  final String? email;
  final String? phoneNumber;
  final String? dateOfBirth;
  final String? sexCode;
  final bool isActive;

  String get fullName => [
    firstName,
    middleName,
    lastName,
  ].where((part) => part != null && part.trim().isNotEmpty).join(' ');

  factory PatientProfile.fromJson(Map<String, dynamic> json) {
    return PatientProfile(
      id: json['id'] as String? ?? '',
      organizationId: json['organization'] as String? ?? '',
      patientNumber: json['patient_number'] as String? ?? '',
      firstName: json['first_name'] as String? ?? '',
      middleName: json['middle_name'] as String?,
      lastName: json['last_name'] as String? ?? '',
      email: json['email'] as String?,
      phoneNumber: json['phone_number'] as String?,
      dateOfBirth: json['date_of_birth'] as String?,
      sexCode: json['sex_code'] as String?,
      isActive: json['is_active'] as bool? ?? false,
    );
  }
}
