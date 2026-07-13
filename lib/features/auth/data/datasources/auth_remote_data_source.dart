import 'package:dio/dio.dart';
import 'package:lorofy/core/network/response/api_response.dart';
import 'package:lorofy/core/network/dio_client.dart';
import 'package:lorofy/features/auth/data/models/auth_response.dart';
import 'package:lorofy/features/auth/data/models/user_profile.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_remote_data_source.g.dart';

class AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSource(this._dio);

  // LOGIN
  Future<AuthResponse> login(String email, String password) async {
    final response = await _dio.post(
      '/auth/login',
      data: {'email': email, 'password': password},
      options: ApiOptions.public,
    );

    return response.unwrap(
      (json) => AuthResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  // SIGN UP
  // STEP 1: Send OTP to email
  Future<void> sendOtp(String email) async {
    await _dio.post(
      '/auth/register/send-otp',
      data: {'email': email},
      options: ApiOptions.public,
    );
  }

  // STEP 2: Verify OTP → returns signupToken
  Future<String> verifyOtp(String email, String otpCode) async {
    final response = await _dio.post(
      '/auth/register/verify-otp',
      data: {'email': email, 'otpCode': otpCode},
      options: ApiOptions.public,
    );
    return response.unwrap((json) => json as String);
  }

  // STEP 3: Create account using signupToken + password
  Future<void> register(String signupToken, String password) async {
    await _dio.post(
      '/auth/register',
      data: {'signupToken': signupToken, 'password': password},
      options: ApiOptions.public,
    );
  }

  // GET ME
  Future<UserProfile> getMyProfile() async {
    final response = await _dio.get('/auth/me', options: ApiOptions.protected);
    return response.unwrap(
      (json) => UserProfile.fromJson(json as Map<String, dynamic>),
    );
  }

  // UPDATE PROFILE
  Future<UserProfile> onboardProfile({
    required String displayName,
    required String countryCode,
    required String timezone,
  }) async {
    final response = await _dio.put(
      '/profiles/onboard',
      data: {
        'displayName': displayName,
        'countryCode': countryCode,
        'timezone': timezone,
      },
      options: ApiOptions.protected,
    );
    return response.unwrap(
      (json) => UserProfile.fromJson(json as Map<String, dynamic>),
    );
  }

  // LOGOUT
  Future<void> logout() async {
    await _dio.post('/auth/logout', options: ApiOptions.protected);
  }
}

@Riverpod(keepAlive: true)
AuthRemoteDataSource authRemoteDataSource(Ref ref) {
  final dio = ref.read(dioProvider);
  return AuthRemoteDataSource(dio);
}
