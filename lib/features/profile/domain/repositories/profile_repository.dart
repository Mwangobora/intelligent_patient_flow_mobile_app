import '../../../../core/network/api_result.dart';
import '../../data/models/patient_profile.dart';

abstract interface class ProfileRepository {
  Future<ApiResult<PatientProfile>> currentProfile();

  Future<ApiResult<PatientProfile>> updateCurrentProfile({
    String? email,
    String? phoneNumber,
  });
}
