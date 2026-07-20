class ApiEndpoints {
  const ApiEndpoints._();

  static const auth = _AuthEndpoints();
  static const profile = _ProfileEndpoints();
  static const appointments = _AppointmentEndpoints();
  static const checkins = _CheckinEndpoints();
  static const queue = _QueueEndpoints();
  static const notifications = _NotificationEndpoints();
}

class _AuthEndpoints {
  const _AuthEndpoints();

  String get login => '/auth/login/';
  String get logout => '/auth/logout/';
  String get me => '/auth/me/';
}

class _ProfileEndpoints {
  const _ProfileEndpoints();

  String get patients => '/patients/';
}

class _AppointmentEndpoints {
  const _AppointmentEndpoints();

  String get base => '/scheduling/appointments/';
  String detail(String id) => '/scheduling/appointments/$id/';
}

class _CheckinEndpoints {
  const _CheckinEndpoints();

  String get base => '/checkins/';
  String get tokenIssue => '/checkins/tokens/issue/';
  String get tokenConsume => '/checkins/tokens/consume/';
}

class _QueueEndpoints {
  const _QueueEndpoints();

  String get entries => '/queueing/entries/';
  String get queues => '/queueing/queues/';
}

class _NotificationEndpoints {
  const _NotificationEndpoints();

  String get base => '/notifications/';
}
