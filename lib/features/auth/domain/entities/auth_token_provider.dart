// auth_token_provider.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecommerce_app/injection_container.dart';

abstract class AuthTokenProvider {
  Future<String?> getToken();
  Future<void> saveToken(String token);
  Future<void> clearToken();
}

class AuthTokenProviderImpl implements AuthTokenProvider {
  final SharedPreferences _sharedPreferences;
  static const _tokenKey = 'auth_token';

  AuthTokenProviderImpl(this._sharedPreferences);

  @override
  Future<String?> getToken() async {
    final token = _sharedPreferences.getString(_tokenKey);
    print('Retrieved token: $token');
    return token;
  }

  @override
  Future<void> saveToken(String token) async {
    print('Saving token: $token');
    await _sharedPreferences.setString(_tokenKey, token);
  }

  @override
  Future<void> clearToken() async {
    print('Clearing token');
    await _sharedPreferences.remove(_tokenKey);
  }
}