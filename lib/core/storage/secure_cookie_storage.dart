import 'package:cookie_jar/cookie_jar.dart';

import 'secure_storage_service.dart';

class SecureCookieStorage extends Storage {
  const SecureCookieStorage(this._secureStorage);

  static const _prefix = 'patient_flow_cookie_';

  final SecureStorageService _secureStorage;

  String _key(String key) => '$_prefix$key';

  @override
  Future<void> init(bool persistSession, bool ignoreExpires) async {}

  @override
  Future<String?> read(String key) => _secureStorage.read(_key(key));

  @override
  Future<void> write(String key, String value) {
    return _secureStorage.write(_key(key), value);
  }

  @override
  Future<void> delete(String key) => _secureStorage.delete(_key(key));

  @override
  Future<void> deleteAll(List<String> keys) async {
    for (final key in keys) {
      await delete(key);
    }
  }
}
