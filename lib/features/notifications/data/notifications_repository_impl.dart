import '../../../core/errors/error_mapper.dart';
import '../../../core/network/api_result.dart';
import '../domain/repositories/notifications_repository.dart';
import 'notifications_api_service.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  const NotificationsRepositoryImpl(this._apiService);

  final NotificationsApiService _apiService;

  @override
  Future<ApiResult<List<dynamic>>> listNotifications() async {
    try {
      return ApiResult.success(await _apiService.listNotifications());
    } catch (error) {
      return ApiResult.failure(ErrorMapper.fromObject(error).message);
    }
  }
}
