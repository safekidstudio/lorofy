import 'package:google_sign_in/google_sign_in.dart';
import 'package:lorofy/features/auth/data/repositories/auth_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'login_controller.g.dart';

@riverpod
class LoginController extends _$LoginController {
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
      final googleSignIn = GoogleSignIn();
      final googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        // User canceled sign-in
        state = const AsyncValue.data(null);
        return;
      }

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        state = AsyncValue.error(
          'Failed to retrieve Google Auth ID Token',
          StackTrace.current,
        );
        return;
      }

      state = await AsyncValue.guard(() async {
        await ref.read(authRepositoryProvider).loginWithOAuth(
              provider: 'GOOGLE',
              token: idToken,
              fullName: googleUser.displayName,
            );
      });
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
