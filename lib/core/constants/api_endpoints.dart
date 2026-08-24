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
  String get register => '/patient/register/';
  String get logout => '/auth/logout/';
  String get me => '/auth/me/';
  String get refresh => '/auth/refresh/';
  String get changePassword => '/auth/change-password/';
}

class _ProfileEndpoints {
  const _ProfileEndpoints();

  String get me => '/patient/me/';
  String get claimExistingRecord => '/patient/claim-existing-record/';
}

class _AppointmentEndpoints {
  const _AppointmentEndpoints();

  String get base => '/patient/appointments/';
  String get slots => '/patient/appointment-slots/';
  String detail(String id) => '/patient/appointments/$id/';
  String cancel(String id) => '/patient/appointments/$id/cancel/';
  String reschedule(String id) => '/patient/appointments/$id/reschedule/';
  String statusHistory(String id) =>
      '/patient/appointments/$id/status-history/';
}

class _FacilityEndpoints {
  const _FacilityEndpoints();

  String get facilities => '/patient/facilities/';
  String facilitySpecialties(String facilityId) =>
      '/patient/facilities/$facilityId/specialties/';
}

class _CheckinEndpoints {
  const _CheckinEndpoints();

  String get patientEligibility => '/patient/checkins/eligibility/';
  String patientAppointmentCheckin(String appointmentId) =>
      '/patient/checkins/appointments/$appointmentId/check-in/';
  String patientQrToken(String appointmentId) =>
      '/patient/checkins/appointments/$appointmentId/qr-token/';
  String get patientQrConsume => '/patient/checkins/qr/consume/';
  String get patientFacilityQrConsume =>
      '/patient/checkins/facility-qr/consume/';
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

  String get base => '/patient/notifications/';
  String detail(String id) => '/patient/notifications/$id/';
  String markRead(String id) => '/patient/notifications/$id/mark-read/';
  String get pushDevices => '/notifications/push-devices/';
  String pushDeviceLastSeen(String id) =>
      '/notifications/push-devices/$id/last-seen/';
  String pushDeviceRevoke(String id) =>
      '/notifications/push-devices/$id/revoke/';
  String pushDeviceDeactivate(String id) =>
      '/notifications/push-devices/$id/deactivate/';
}
