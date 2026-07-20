import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  const SecureStorageService({this.storage = const FlutterSecureStorage()});

  final FlutterSecureStorage storage;

  Future<void> write(String key, String value) =>
      storage.write(key: key, value: value);

  Future<String?> read(String key) => storage.read(key: key);

  Future<void> delete(String key) => storage.delete(key: key);
}
