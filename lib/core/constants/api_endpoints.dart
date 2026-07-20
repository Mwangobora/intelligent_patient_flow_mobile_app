class ApiEndpoints {
  const ApiEndpoints._();

  static const auth = _AuthEndpoints();
  static const profile = _ProfileEndpoints();
  static const appointments = _AppointmentEndpoints();
  static const facilities = _FacilityEndpoints();
  static const checkins = _CheckinEndpoints();
  static const queue = _QueueEndpoints();
  static const intelligence = _IntelligenceEndpoints();
  static const notifications = _NotificationEndpoints();
}

class _AuthEndpoints {
  const _AuthEndpoints();

  String get login => '/auth/login/';
  String get logout => '/auth/logout/';
  String get me => '/auth/me/';
  String get changePassword => '/auth/change-password/';
}

class _ProfileEndpoints {
  const _ProfileEndpoints();

  String get patients => '/patients/';
}

class _AppointmentEndpoints {
  const _AppointmentEndpoints();

  String get base => '/scheduling/appointments/';
  String get slots => '/scheduling/slots/';
  String detail(String id) => '/scheduling/appointments/$id/';
  String cancel(String id) => '/scheduling/appointments/$id/cancel/';
  String reschedule(String id) => '/scheduling/appointments/$id/reschedule/';
  String statusHistory(String id) =>
      '/scheduling/appointments/$id/status-history/';
}

class _FacilityEndpoints {
  const _FacilityEndpoints();

  String get facilities => '/facilities/facilities/';
  String get facilitySpecialties => '/facilities/facility-specialties/';
}

class _CheckinEndpoints {
  const _CheckinEndpoints();

  String get patientEligibility => '/patient/checkins/eligibility/';
  String patientAppointmentCheckin(String appointmentId) =>
      '/patient/checkins/appointments/$appointmentId/check-in/';
  String patientQrToken(String appointmentId) =>
      '/patient/checkins/appointments/$appointmentId/qr-token/';
  String get patientQrConsume => '/patient/checkins/qr/consume/';
}

class _QueueEndpoints {
  const _QueueEndpoints();

  String get patientCurrent => '/patient/queue/current/';
  String get patientHistory => '/patient/queue/history/';
}

class _IntelligenceEndpoints {
  const _IntelligenceEndpoints();

  String latestPrediction(String queueEntryId) =>
      '/intelligence/queue-entries/$queueEntryId/latest-prediction/';
}

class _NotificationEndpoints {
  const _NotificationEndpoints();

  String get base => '/notifications/';
}
