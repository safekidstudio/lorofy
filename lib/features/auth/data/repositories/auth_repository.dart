import 'package:lorofy/core/errors/exceptions.dart';
import 'package:lorofy/core/storage/auth_storage.dart';
import 'package:lorofy/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:lorofy/features/auth/data/models/user_profile.dart';
import 'package:lorofy/features/auth/presentation/providers/auth_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_repository.g.dart';

class AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final Ref _ref;

  AuthRepository(this._remoteDataSource, this._ref);

  Future<void> login(String email, String password) async {
    try {
      final authResponse = await _remoteDataSource.login(email, password);

      await _ref
          .read(authStorageProvider)
          .saveTokens(
            accessToken: authResponse.accessToken,
            refreshToken: authResponse.refreshToken,
          );

      final profile = await _remoteDataSource.getMyProfile();

      await _ref
          .read(authProvider.notifier)
          .loginSuccess(
            accessToken: authResponse.accessToken,
            refreshToken: authResponse.refreshToken,
            isOnboarded: profile.isOnboarded,
            displayName: profile.displayName,
            avatarUrl: profile.avatarUrl,
            username: profile.username,
            rankPoints: profile.rankPoints,
          );
    } catch (e) {
      throw e.toFailure();
    }
  }

  Future<void> loginWithOAuth({
    required String provider,
    required String token,
    String? fullName,
  }) async {
    try {
      final authResponse = await _remoteDataSource.loginWithOAuth(
        provider: provider,
        token: token,
        fullName: fullName,
      );

      await _ref
          .read(authStorageProvider)
          .saveTokens(
            accessToken: authResponse.accessToken,
            refreshToken: authResponse.refreshToken,
          );

      final profile = await _remoteDataSource.getMyProfile();

      await _ref
          .read(authProvider.notifier)
          .loginSuccess(
            accessToken: authResponse.accessToken,
            refreshToken: authResponse.refreshToken,
            isOnboarded: profile.isOnboarded,
            displayName: profile.displayName,
            avatarUrl: profile.avatarUrl,
            username: profile.username,
            rankPoints: profile.rankPoints,
          );
    } catch (e) {
      throw e.toFailure();
    }
  }

  // STEP 1: Send OTP to email
  Future<void> sendOtp(String email) async {
    try {
      await _remoteDataSource.sendOtp(email);
    } catch (e) {
      throw e.toFailure();
    }
  }

  // STEP 2: Verify OTP -> returns signupToken
  Future<String> verifyOtp(String email, String otpCode) async {
    try {
      return await _remoteDataSource.verifyOtp(email, otpCode);
    } catch (e) {
      throw e.toFailure();
    }
  }

  // STEP 3: Create account using signupToken + password, then auto-login
  Future<void> register({
    required String signupToken,
    required String password,
    required String email,
  }) async {
    try {
      await _remoteDataSource.register(signupToken, password);
      // Auto-login after successful registration
      await login(email, password);
    } catch (e) {
      throw e.toFailure();
    }
  }

  Future<UserProfile> getMe() async {
    try {
      return await _remoteDataSource.getMyProfile();
    } catch (e) {
      throw e.toFailure();
    }
  }

  Future<UserProfile> onboardProfile({
    required String displayName,
    required String countryCode,
    required String timezone,
    String? avatarAssetId,
  }) async {
    try {
      final profile = await _remoteDataSource.onboardProfile(
        displayName: displayName,
        countryCode: countryCode,
        timezone: timezone,
        avatarAssetId: avatarAssetId,
      );
      return profile;
    } catch (e) {
      throw e.toFailure();
    }
  }

  Future<UserProfile> updateProfile({
    String? displayName,
    String? timezone,
    String? avatarAssetId,
  }) async {
    try {
      final profile = await _remoteDataSource.updateProfile(
        displayName: displayName,
        timezone: timezone,
        avatarAssetId: avatarAssetId,
      );

      await _ref.read(authProvider.notifier).updateProfileState(
        displayName: profile.displayName ?? '',
        avatarUrl: profile.avatarUrl,
        username: profile.username,
      );

      return profile;
    } catch (e) {
      throw e.toFailure();
    }
  }

  Future<void> logout() async {
    try {
      await _remoteDataSource.logout();
      _ref.read(authProvider.notifier).logout();
    } catch (e) {
      // Clean local storage even if remote logout fails
      _ref.read(authProvider.notifier).logout();
      throw e.toFailure();
    }
  }
}

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  final remoteDataSource = ref.read(authRemoteDataSourceProvider);
  return AuthRepository(remoteDataSource, ref);
}
