import '../../../../core/network/api_result.dart';

abstract interface class NotificationsRepository {
  Future<ApiResult<List<dynamic>>> listNotifications();
}
