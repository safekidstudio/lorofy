import 'package:lorofy/features/auth/data/repositories/auth_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'create_password_controller.g.dart';

@riverpod
class CreatePasswordController extends _$CreatePasswordController {
  @override
  FutureOr<void> build() {
    return null;
  }

  // Step 3: Tạo tài khoản → auto login
  Future<void> createAccount({
    required String signupToken,
    required String password,
    required String email,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).register(
        signupToken: signupToken,
        password: password,
        email: email,
      );
    });
  }
}
