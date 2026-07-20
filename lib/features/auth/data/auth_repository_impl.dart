import '../../../core/errors/error_mapper.dart';
import '../../../core/network/api_result.dart';
import '../domain/repositories/auth_repository.dart';
import 'auth_api_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._apiService);

  final AuthApiService _apiService;

  @override
  Future<ApiResult<Map<String, dynamic>>> currentUser() async {
    try {
      return ApiResult.success(await _apiService.currentUser());
    } catch (error) {
      return ApiResult.failure(ErrorMapper.fromObject(error).message);
    }
  }
}
