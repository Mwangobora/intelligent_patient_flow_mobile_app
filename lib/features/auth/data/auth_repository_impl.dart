import '../../../core/errors/error_mapper.dart';
import '../../../core/network/api_result.dart';
import '../domain/repositories/auth_repository.dart';
import 'auth_api_service.dart';
import 'models/auth_response.dart';
import 'models/auth_user.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._apiService);

  final AuthApiService _apiService;

  @override
  Future<ApiResult<AuthResponse>> login({
    required String emailOrPhone,
    required String password,
  }) async {
    try {
      return ApiResult.success(
        await _apiService.login(emailOrPhone: emailOrPhone, password: password),
      );
    } catch (error) {
      return ApiResult.failure(ErrorMapper.fromObject(error).message);
    }
  }

  @override
  Future<ApiResult<AuthUser>> currentUser() async {
    try {
      return ApiResult.success(await _apiService.currentUser());
    } catch (error) {
      return ApiResult.failure(ErrorMapper.fromObject(error).message);
    }
  }

  @override
  Future<ApiResult<AuthUser>> updateCurrentUser({
    String? firstName,
    String? middleName,
    String? lastName,
  }) async {
    try {
      return ApiResult.success(
        await _apiService.updateCurrentUser(
          firstName: firstName,
          middleName: middleName,
          lastName: lastName,
        ),
      );
    } catch (error) {
      return ApiResult.failure(ErrorMapper.fromObject(error).message);
    }
  }

  @override
  Future<ApiResult<void>> logout() async {
    try {
      await _apiService.logout();
      return const ApiResult.success(null);
    } catch (error) {
      return ApiResult.failure(ErrorMapper.fromObject(error).message);
    }
  }
}
