import '../../../core/errors/error_mapper.dart';
import '../../../core/network/api_result.dart';
import '../domain/repositories/profile_repository.dart';
import 'models/patient_profile.dart';
import 'profile_api_service.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl(this._apiService);

  final ProfileApiService _apiService;

  @override
  Future<ApiResult<List<PatientProfile>>> listProfiles({
    required String userId,
  }) async {
    try {
      return ApiResult.success(
        await _apiService.listPatientProfiles(userId: userId),
      );
    } catch (error) {
      return ApiResult.failure(ErrorMapper.fromObject(error).message);
    }
  }
}
