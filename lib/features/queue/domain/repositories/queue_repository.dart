import '../../../../core/network/api_result.dart';

abstract interface class QueueRepository {
  Future<ApiResult<List<dynamic>>> listQueueEntries();
}
