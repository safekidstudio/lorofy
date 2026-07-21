import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_storage.g.dart';

class AuthStorage {
  final FlutterSecureStorage _storage;

  AuthStorage(this._storage);

  static const _accessTokenKey = "access_token";
  static const _refreshTokenKey = "refresh_token";
  static const _isOnboardedKey = "is_onboarded";
  static const _displayNameKey = "display_name";

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  Future<void> saveProfileCache({
    required bool isOnboarded,
    required String? displayName,
  }) async {
    await _storage.write(key: _isOnboardedKey, value: isOnboarded ? 'true' : 'false');
    if (displayName != null) {
      await _storage.write(key: _displayNameKey, value: displayName);
    } else {
      await _storage.delete(key: _displayNameKey);
    }
  }

  Future<bool?> getIsOnboarded() async {
    final value = await _storage.read(key: _isOnboardedKey);
    if (value == null) return null;
    return value == 'true';
  }

  Future<String?> getDisplayName() async {
    return await _storage.read(key: _displayNameKey);
  }

  Future<void> clearProfileCache() async {
    await _storage.delete(key: _isOnboardedKey);
    await _storage.delete(key: _displayNameKey);
  }

  Future<void> clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await clearProfileCache();
  }
}

@Riverpod(keepAlive: true)
AuthStorage authStorage(Ref ref) {
  const androidOptions = AndroidOptions();

  const iosOptions = IOSOptions(
    accessibility: KeychainAccessibility.first_unlock,
  );

  return AuthStorage(
    const FlutterSecureStorage(aOptions: androidOptions, iOptions: iosOptions),
  );
}
