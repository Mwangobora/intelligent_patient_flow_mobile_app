import '../../../core/errors/error_mapper.dart';
import '../../../core/network/api_result.dart';
import '../domain/repositories/notifications_repository.dart';
import 'models/notification_models.dart';
import 'notifications_api_service.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  const NotificationsRepositoryImpl(this._apiService);

  final NotificationsApiService _apiService;

  @override
  Future<ApiResult<List<PatientNotification>>> listNotifications({
    required String patientId,
    bool unreadOnly = false,
  }) async {
    try {
      return ApiResult.success(
        await _apiService.listNotifications(
          patientId: patientId,
          unreadOnly: unreadOnly,
        ),
      );
    } catch (error) {
      return ApiResult.failure(_friendlyNotificationError(error));
    }
  }

  @override
  Future<ApiResult<PatientNotification>> getNotification(String id) async {
    try {
      return ApiResult.success(await _apiService.getNotification(id));
    } catch (error) {
      return ApiResult.failure(_friendlyNotificationError(error));
    }
  }

  @override
  Future<ApiResult<PatientNotification>> markAsRead(String id) async {
    try {
      return ApiResult.success(await _apiService.markAsRead(id));
    } catch (error) {
      return ApiResult.failure(_friendlyNotificationError(error));
    }
  }

  @override
  Future<ApiResult<List<PushDevice>>> listPushDevices({
    required String userId,
    bool? isActive,
  }) async {
    try {
      return ApiResult.success(
        await _apiService.listPushDevices(userId: userId, isActive: isActive),
      );
    } catch (error) {
      return ApiResult.failure(_friendlyNotificationError(error));
    }
  }

  @override
  Future<ApiResult<PushDevice>> registerPushDevice({
    required String userId,
    required String platform,
    required String rawToken,
    String? deviceName,
    String? appVersion,
  }) async {
    try {
      return ApiResult.success(
        await _apiService.registerPushDevice(
          userId: userId,
          platform: platform,
          rawToken: rawToken,
          deviceName: deviceName,
          appVersion: appVersion,
        ),
      );
    } catch (error) {
      return ApiResult.failure(_friendlyNotificationError(error));
    }
  }

  @override
  Future<ApiResult<PushDevice>> updatePushDeviceLastSeen(String id) async {
    try {
      return ApiResult.success(await _apiService.updatePushDeviceLastSeen(id));
    } catch (error) {
      return ApiResult.failure(_friendlyNotificationError(error));
    }
  }

  @override
  Future<ApiResult<PushDevice>> revokePushDevice(String id) async {
    try {
      return ApiResult.success(await _apiService.revokePushDevice(id));
    } catch (error) {
      return ApiResult.failure(_friendlyNotificationError(error));
    }
  }

  @override
  Future<ApiResult<PushDevice>> deactivatePushDevice(String id) async {
    try {
      return ApiResult.success(await _apiService.deactivatePushDevice(id));
    } catch (error) {
      return ApiResult.failure(_friendlyNotificationError(error));
    }
  }

  String _friendlyNotificationError(Object error) {
    final message = ErrorMapper.fromObject(error).message;
    final normalized = message.toLowerCase();
    if (normalized.contains('permission')) {
      return 'Notifications are not available for this account yet.';
    }
    if (normalized.contains('not found')) {
      return 'Notification was not found.';
    }
    if (normalized.contains('connect') || normalized.contains('server')) {
      return 'Could not connect to the server. Please try again.';
    }
    return message;
  }
}
