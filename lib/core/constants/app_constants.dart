class AppConstants {
  const AppConstants._();

  static const appName = 'Patient Flow';
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000/api/v1',
  );
  static const connectTimeoutSeconds = 20;
  static const receiveTimeoutSeconds = 30;
}
