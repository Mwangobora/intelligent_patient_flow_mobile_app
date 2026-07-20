import '../../../../core/network/api_result.dart';
import '../../data/models/queue_models.dart';

abstract interface class QueueRepository {
  Future<ApiResult<QueueEntry?>> getCurrentQueue();

  Future<ApiResult<List<QueueEntry>>> listQueueHistory();
}
