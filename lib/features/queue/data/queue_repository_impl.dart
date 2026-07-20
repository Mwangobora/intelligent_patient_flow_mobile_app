import '../../../core/errors/error_mapper.dart';
import '../../../core/network/api_result.dart';
import '../domain/repositories/queue_repository.dart';
import 'queue_api_service.dart';

class QueueRepositoryImpl implements QueueRepository {
  const QueueRepositoryImpl(this._apiService);

  final QueueApiService _apiService;

  @override
  Future<ApiResult<List<dynamic>>> listQueueEntries() async {
    try {
      return ApiResult.success(await _apiService.listQueueEntries());
    } catch (error) {
      return ApiResult.failure(ErrorMapper.fromObject(error).message);
    }
  }
}
