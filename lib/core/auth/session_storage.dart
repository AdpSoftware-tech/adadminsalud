import 'package:shared_preferences/shared_preferences.dart';

class SessionStorage {
  static const _kToken = 'auth_token';

  Future<void> saveToken(String token) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kToken, token);
  }

  Future<String?> getToken() async {
    final sp = await SharedPreferences.getInstance();
    final t = sp.getString(_kToken);
    if (t == null || t.trim().isEmpty) return null;
    return t.trim();
  }

  Future<void> clear() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_kToken);
  }
}
