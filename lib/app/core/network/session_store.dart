import 'package:shared_preferences/shared_preferences.dart';

class SessionStore {
  static const _accessKey = 'wavoo_access_token';
  static const _refreshKey = 'wavoo_refresh_token';

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<String?> get accessToken async {
    await init();
    return _prefs!.getString(_accessKey);
  }

  Future<String?> get refreshToken async {
    await init();
    return _prefs!.getString(_refreshKey);
  }

  Future<bool> get hasSession async {
    final refresh = await refreshToken;
    return refresh != null && refresh.isNotEmpty;
  }

  Future<void> saveAccessToken(String token) async {
    await init();
    await _prefs!.setString(_accessKey, token);
  }

  Future<void> saveRefreshToken(String token) async {
    await init();
    await _prefs!.setString(_refreshKey, token);
  }

  Future<void> clear() async {
    await init();
    final keys = _prefs!.getKeys().where((key) => key.startsWith('wavoo_')).toList();
    for (final key in keys) {
      await _prefs!.remove(key);
    }
  }
}
