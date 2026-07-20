import '../../../../core/network/api_result.dart';
import '../../data/models/auth_response.dart';
import '../../data/models/auth_user.dart';

abstract interface class AuthRepository {
  Future<ApiResult<AuthResponse>> login({
    required String emailOrPhone,
    required String password,
  });

  Future<ApiResult<AuthUser>> currentUser();

  Future<ApiResult<AuthUser>> updateCurrentUser({
    String? firstName,
    String? middleName,
    String? lastName,
  });

  Future<ApiResult<void>> changePassword({
    required String oldPassword,
    required String newPassword,
  });

  Future<ApiResult<void>> logout();
}
