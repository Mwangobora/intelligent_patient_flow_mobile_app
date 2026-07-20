import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/network/api_client.dart';
import '../core/network/network_info.dart';
import '../core/storage/local_preferences_service.dart';
import '../core/storage/secure_storage_service.dart';
import 'app_router.dart';

final secureStorageProvider = Provider<SecureStorageService>(
  (ref) => const SecureStorageService(),
);

final localPreferencesProvider = Provider<LocalPreferencesService>(
  (ref) => LocalPreferencesService(),
);

final networkInfoProvider = Provider<NetworkInfo>((ref) => NetworkInfo());

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(networkInfo: ref.watch(networkInfoProvider));
});

final appRouterProvider = Provider<GoRouter>((ref) => createAppRouter());
