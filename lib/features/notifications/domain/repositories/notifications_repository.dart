import '../../../../core/network/api_result.dart';
import '../../data/models/notification_models.dart';

abstract interface class NotificationsRepository {
  Future<ApiResult<List<PatientNotification>>> listNotifications({
    required String patientId,
    bool unreadOnly,
  });

  Future<ApiResult<PatientNotification>> getNotification(String id);

  Future<ApiResult<PatientNotification>> markAsRead(String id);

  Future<ApiResult<List<PushDevice>>> listPushDevices({
    required String userId,
    bool? isActive,
  });

  Future<ApiResult<PushDevice>> registerPushDevice({
    required String userId,
    required String platform,
    required String rawToken,
    String? deviceName,
    String? appVersion,
  });

  Future<ApiResult<PushDevice>> updatePushDeviceLastSeen(String id);

  Future<ApiResult<PushDevice>> revokePushDevice(String id);

  Future<ApiResult<PushDevice>> deactivatePushDevice(String id);
}
