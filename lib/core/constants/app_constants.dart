class AppConstants {
  const AppConstants._();

  static const appName = 'Patient Flow';
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000/api/v1',
  );
  static const _configuredWsBaseUrl = String.fromEnvironment(
    'WS_BASE_URL',
    defaultValue: '',
  );
  static const connectTimeoutSeconds = 20;
  static const receiveTimeoutSeconds = 30;

  static String get wsBaseUrl {
    if (_configuredWsBaseUrl.isNotEmpty) return _configuredWsBaseUrl;

    final apiUri = Uri.parse(apiBaseUrl);
    final wsUri = Uri(
      scheme: apiUri.scheme == 'https' ? 'wss' : 'ws',
      host: apiUri.host,
      port: apiUri.hasPort ? apiUri.port : null,
    );
    return wsUri.toString().replaceFirst(RegExp(r'/$'), '');
  }
}
