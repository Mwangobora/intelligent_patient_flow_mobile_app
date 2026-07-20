import '../../../core/errors/error_mapper.dart';
import '../../../core/network/api_result.dart';
import '../domain/repositories/checkin_repository.dart';
import 'checkin_api_service.dart';

class CheckinRepositoryImpl implements CheckinRepository {
  const CheckinRepositoryImpl(this._apiService);

  final CheckinApiService _apiService;

  @override
  Future<ApiResult<Map<String, dynamic>>> consumeToken(String token) async {
    try {
      return ApiResult.success(await _apiService.consumeToken(token));
    } catch (error) {
      return ApiResult.failure(ErrorMapper.fromObject(error).message);
    }
  }
}
