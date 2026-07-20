import 'package:shared_preferences/shared_preferences.dart';

class LocalPreferencesService {
  SharedPreferencesAsync get _prefs => SharedPreferencesAsync();

  Future<void> setBool(String key, bool value) => _prefs.setBool(key, value);

  Future<bool?> getBool(String key) => _prefs.getBool(key);
}
