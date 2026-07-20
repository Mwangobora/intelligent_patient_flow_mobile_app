import '../../../core/errors/error_mapper.dart';
import '../../../core/network/api_result.dart';
import '../domain/repositories/queue_repository.dart';
import 'queue_api_service.dart';
import 'models/queue_models.dart';

class QueueRepositoryImpl implements QueueRepository {
  const QueueRepositoryImpl(this._apiService);

  final QueueApiService _apiService;

  @override
  Future<ApiResult<List<QueueEntry>>> listQueueEntries({
    String? patientId,
    String? patientCheckinId,
    bool? activeOnly,
  }) async {
    try {
      return ApiResult.success(
        await _apiService.listQueueEntries(
          patientId: patientId,
          patientCheckinId: patientCheckinId,
          activeOnly: activeOnly,
        ),
      );
    } catch (error) {
      return ApiResult.failure(ErrorMapper.fromObject(error).message);
    }
  }

  @override
  Future<ApiResult<QueueEntry>> getQueueEntry(String id) async {
    try {
      return ApiResult.success(await _apiService.getQueueEntry(id));
    } catch (error) {
      return ApiResult.failure(ErrorMapper.fromObject(error).message);
    }
  }

  @override
  Future<ApiResult<List<QueueEntryEvent>>> listEvents(
    String queueEntryId,
  ) async {
    try {
      return ApiResult.success(await _apiService.listEvents(queueEntryId));
    } catch (error) {
      return ApiResult.failure(ErrorMapper.fromObject(error).message);
    }
  }

  @override
  Future<ApiResult<WaitTimePrediction?>> getLatestPrediction(
    String queueEntryId,
  ) async {
    try {
      return ApiResult.success(
        await _apiService.getLatestPrediction(queueEntryId),
      );
    } catch (error) {
      return ApiResult.failure(ErrorMapper.fromObject(error).message);
    }
  }
}
