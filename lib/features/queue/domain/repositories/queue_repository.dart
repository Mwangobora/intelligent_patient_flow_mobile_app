import '../../../../core/network/api_result.dart';
import '../../data/models/queue_models.dart';

abstract interface class QueueRepository {
  Future<ApiResult<List<QueueEntry>>> listQueueEntries({
    String? patientId,
    String? patientCheckinId,
    bool? activeOnly,
  });

  Future<ApiResult<QueueEntry>> getQueueEntry(String id);

  Future<ApiResult<List<QueueEntryEvent>>> listEvents(String queueEntryId);

  Future<ApiResult<WaitTimePrediction?>> getLatestPrediction(
    String queueEntryId,
  );
}
