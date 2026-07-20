import '../../../../core/network/api_result.dart';

abstract interface class CheckinRepository {
  Future<ApiResult<Map<String, dynamic>>> consumeToken(String token);
}
