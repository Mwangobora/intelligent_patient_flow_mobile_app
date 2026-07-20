import '../../../../core/network/api_result.dart';

abstract interface class ProfileRepository {
  Future<ApiResult<List<dynamic>>> listProfiles();
}
