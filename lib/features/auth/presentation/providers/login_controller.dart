import 'dart:async';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lorofy/core/config/app_config.dart';
import 'package:lorofy/core/utils/logger.dart';
import 'package:lorofy/features/auth/data/repositories/auth_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'login_controller.g.dart';

@riverpod
class LoginController extends _$LoginController {
  late final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: AppConfig.googleWebClientId.isNotEmpty
        ? AppConfig.googleWebClientId
        : null,
  );

  @override
  FutureOr<void> build() {
    return null;
  }

  Future<void> login({required String email, required String password}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).login(email, password);
    });
  }

  Future<void> loginWithGoogle() async {
    state = const AsyncLoading();
    try {
      final googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User canceled sign-in
        state = const AsyncValue.data(null);
        return;
      }

      final googleAuth = await googleUser.authentication;
      final token = googleAuth.idToken ?? googleAuth.accessToken;

      AppLogger.debug('=== GOOGLE AUTH DEBUG ===', tag: 'GoogleAuth');
      AppLogger.debug('idToken: ${googleAuth.idToken}', tag: 'GoogleAuth');
      AppLogger.debug('accessToken: ${googleAuth.accessToken}', tag: 'GoogleAuth');

      if (token == null || token.isEmpty) {
        state = AsyncValue.error(
          'Failed to retrieve Google Auth Token',
          StackTrace.current,
        );
        return;
      }

      state = await AsyncValue.guard(() async {
        await ref.read(authRepositoryProvider).loginWithOAuth(
              provider: 'GOOGLE',
              token: token,
              fullName: googleUser.displayName,
            );
      });
    } catch (e, st) {
      AppLogger.error('Google Sign-In Error: $e', tag: 'GoogleAuth');
      state = AsyncValue.error(e, st);
    }
  }
}
