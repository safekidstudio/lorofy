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
        );
  }

  // STEP 1: Gửi OTP về email
  Future<void> sendOtp(String email) async {
    await _remoteDataSource.sendOtp(email);
  }

  // STEP 2: Xác thực OTP → trả về signupToken
  Future<String> verifyOtp(String email, String otpCode) async {
    return await _remoteDataSource.verifyOtp(email, otpCode);
  }

  // STEP 3: Tạo tài khoản bằng signupToken + password, sau đó tự động login
  Future<void> register({
    required String signupToken,
    required String password,
    required String email,
  }) async {
    await _remoteDataSource.register(signupToken, password);
    // Auto-login sau khi tạo tài khoản thành công
    await login(email, password);
  }

  Future<UserProfile> getMe() async {
    return await _remoteDataSource.getMyProfile();
  }

  Future<void> onboardProfile({
    required String displayName,
    required String countryCode,
    required String timezone,
  }) async {
    final profile = await _remoteDataSource.onboardProfile(
      displayName: displayName,
      countryCode: countryCode,
      timezone: timezone,
    );
    _ref
        .read(authProvider.notifier)
        .updateOnboardedState(
          onboarded: profile.isOnboarded,
          displayName: profile.displayName ?? displayName,
        );
  }

  Future<void> logout() async {
    await _remoteDataSource.logout();
    _ref.read(authProvider.notifier).logout();
  }
}

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  final remoteDataSource = ref.read(authRemoteDataSourceProvider);
  return AuthRepository(remoteDataSource, ref);
}
