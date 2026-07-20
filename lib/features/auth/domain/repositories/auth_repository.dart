import '../../../../core/network/api_result.dart';

abstract interface class AuthRepository {
  Future<ApiResult<Map<String, dynamic>>> currentUser();
}
