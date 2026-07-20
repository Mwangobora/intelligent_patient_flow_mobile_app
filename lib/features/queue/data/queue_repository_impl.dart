import '../../../core/errors/error_mapper.dart';
import '../../../core/network/api_result.dart';
import '../domain/repositories/queue_repository.dart';
import 'queue_api_service.dart';
import 'models/queue_models.dart';

class QueueRepositoryImpl implements QueueRepository {
  const QueueRepositoryImpl(this._apiService);

  final QueueApiService _apiService;

  @override
  Future<ApiResult<QueueEntry?>> getCurrentQueue() async {
    try {
      return ApiResult.success(await _apiService.getCurrentQueue());
    } catch (error) {
      return ApiResult.failure(ErrorMapper.fromObject(error).message);
    }
  }

  @override
  Future<ApiResult<List<QueueEntry>>> listQueueHistory() async {
    try {
      return ApiResult.success(await _apiService.listQueueHistory());
    } catch (error) {
      return ApiResult.failure(ErrorMapper.fromObject(error).message);
    }
  }
}
