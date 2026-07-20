import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';

import '../core/network/api_client.dart';
import '../core/network/network_info.dart';
import '../core/storage/secure_cookie_storage.dart';
import '../core/storage/local_preferences_service.dart';
import '../core/storage/secure_storage_service.dart';
import '../features/auth/data/auth_api_service.dart';
import '../features/auth/data/auth_repository_impl.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/presentation/controllers/auth_controller.dart';
import '../features/appointments/data/appointments_api_service.dart';
import '../features/appointments/data/appointments_repository_impl.dart';
import '../features/appointments/domain/repositories/appointments_repository.dart';
import '../features/appointments/presentation/controllers/appointments_controller.dart';
import '../features/profile/data/profile_api_service.dart';
import '../features/profile/data/profile_repository_impl.dart';
import '../features/profile/domain/repositories/profile_repository.dart';
import '../features/profile/presentation/controllers/profile_controller.dart';
import 'app_router.dart';

final secureStorageProvider = Provider<SecureStorageService>(
  (ref) => const SecureStorageService(),
);

final localPreferencesProvider = Provider<LocalPreferencesService>(
  (ref) => LocalPreferencesService(),
);

final networkInfoProvider = Provider<NetworkInfo>((ref) => NetworkInfo());

final apiClientProvider = Provider<ApiClient>((ref) {
  final cookieJar = PersistCookieJar(
    storage: SecureCookieStorage(ref.watch(secureStorageProvider)),
  );
  return ApiClient(
    networkInfo: ref.watch(networkInfoProvider),
    cookieJar: cookieJar,
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(AuthApiService(ref.watch(apiClientProvider)));
});

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) {
    return AuthController(repository: ref.watch(authRepositoryProvider));
  },
);

final appointmentsRepositoryProvider = Provider<AppointmentsRepository>((ref) {
  return AppointmentsRepositoryImpl(
    AppointmentsApiService(ref.watch(apiClientProvider)),
  );
});

final appointmentsControllerProvider =
    StateNotifierProvider<AppointmentsController, AppointmentsState>((ref) {
      return AppointmentsController(
        repository: ref.watch(appointmentsRepositoryProvider),
      );
    });

final appointmentDetailControllerProvider =
    StateNotifierProvider<AppointmentDetailController, AppointmentDetailState>((
      ref,
    ) {
      return AppointmentDetailController(
        repository: ref.watch(appointmentsRepositoryProvider),
      );
    });

final bookingControllerProvider =
    StateNotifierProvider<BookingController, BookingState>((ref) {
      return BookingController(
        repository: ref.watch(appointmentsRepositoryProvider),
      );
    });

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl(ProfileApiService(ref.watch(apiClientProvider)));
});

final profileControllerProvider =
    StateNotifierProvider<ProfileController, ProfileState>((ref) {
      return ProfileController(
        repository: ref.watch(profileRepositoryProvider),
      );
    });

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);
  return createAppRouter(authState: authState);
});
