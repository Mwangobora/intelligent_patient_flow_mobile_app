import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/json_list.dart';
import 'models/notification_models.dart';

class NotificationsApiService {
  const NotificationsApiService(this._apiClient);

  final ApiClient _apiClient;

  Future<List<PatientNotification>> listNotifications({
    required String patientId,
    bool unreadOnly = false,
  }) async {
    final response = await _apiClient.dio.get<dynamic>(
      ApiEndpoints.notifications.base,
      queryParameters: {'patient_id': patientId},
    );
    final notifications = asJsonList(response.data)
        .whereType<Map<String, dynamic>>()
        .map(PatientNotification.fromJson)
        .where((item) => item.patientId == patientId)
        .toList();
    if (!unreadOnly) return notifications;
    return notifications.where((item) => item.isUnread).toList();
  }

  Future<PatientNotification> getNotification(String id) async {
    final response = await _apiClient.dio.get<Map<String, dynamic>>(
      ApiEndpoints.notifications.detail(id),
    );
    return PatientNotification.fromJson(response.data ?? <String, dynamic>{});
  }

  Future<PatientNotification> markAsRead(String id) async {
    final response = await _apiClient.dio.post<Map<String, dynamic>>(
      ApiEndpoints.notifications.markRead(id),
      data: <String, dynamic>{},
    );
    return PatientNotification.fromJson(response.data ?? <String, dynamic>{});
  }

  Future<List<PushDevice>> listPushDevices({
    required String userId,
    bool? isActive,
  }) async {
    final query = <String, dynamic>{'user_id': userId};
    if (isActive != null) query['is_active'] = isActive;
    final response = await _apiClient.dio.get<dynamic>(
      ApiEndpoints.notifications.pushDevices,
      queryParameters: query,
    );
    return asJsonList(response.data)
        .whereType<Map<String, dynamic>>()
        .map(PushDevice.fromJson)
        .where((item) => item.userId == userId)
        .toList();
  }

  Future<PushDevice> registerPushDevice({
    required String userId,
    required String platform,
    required String rawToken,
    String? deviceName,
    String? appVersion,
  }) async {
    final response = await _apiClient.dio.post<Map<String, dynamic>>(
      ApiEndpoints.notifications.pushDevices,
      data: {
        'user_id': userId,
        'platform': platform,
        'raw_token': rawToken,
        'device_name': ?deviceName,
        'app_version': ?appVersion,
      },
    );
    return PushDevice.fromJson(response.data ?? <String, dynamic>{});
  }

  Future<PushDevice> updatePushDeviceLastSeen(String id) async {
    final response = await _apiClient.dio.post<Map<String, dynamic>>(
      ApiEndpoints.notifications.pushDeviceLastSeen(id),
      data: <String, dynamic>{},
    );
    return PushDevice.fromJson(response.data ?? <String, dynamic>{});
  }

  Future<PushDevice> revokePushDevice(String id) async {
    final response = await _apiClient.dio.post<Map<String, dynamic>>(
      ApiEndpoints.notifications.pushDeviceRevoke(id),
      data: <String, dynamic>{},
    );
    return PushDevice.fromJson(response.data ?? <String, dynamic>{});
  }

  Future<PushDevice> deactivatePushDevice(String id) async {
    final response = await _apiClient.dio.post<Map<String, dynamic>>(
      ApiEndpoints.notifications.pushDeviceDeactivate(id),
      data: <String, dynamic>{},
    );
    return PushDevice.fromJson(response.data ?? <String, dynamic>{});
  }
}
