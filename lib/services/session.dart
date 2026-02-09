import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const _keyUserName = 'current_user_name';
  static const _keyAuthToken = 'auth_token';
  static const FlutterSecureStorage _secure = FlutterSecureStorage();

  static Future<void> setUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserName, name);
  }

  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserName);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserName);
    await _secure.delete(key: _keyAuthToken);
  }

  // Auth token (secure storage)
  static Future<void> setAuthToken(String token) async {
    await _secure.write(key: _keyAuthToken, value: token);
  }

  static Future<String?> getAuthToken() async {
    return await _secure.read(key: _keyAuthToken);
  }

  static Future<void> clearAuthToken() async {
    await _secure.delete(key: _keyAuthToken);
  }
}
