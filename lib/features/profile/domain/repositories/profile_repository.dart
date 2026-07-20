import '../../../../core/network/api_result.dart';
import '../../data/models/patient_profile.dart';

abstract interface class ProfileRepository {
  Future<ApiResult<List<PatientProfile>>> listProfiles({
    required String userId,
  });
}
