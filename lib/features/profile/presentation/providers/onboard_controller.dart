import 'package:lorofy/features/auth/data/repositories/auth_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'onboard_controller.g.dart';

@riverpod
class OnboardController extends _$OnboardController {
  @override
  FutureOr<void> build() {
    // Trạng thái ban đầu là AsyncData(null)
    return null;
  }

  Future<void> onboard({
    required String displayName,
    required String countryCode,
    required String timezone,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(authRepositoryProvider)
          .onboardProfile(
            displayName: displayName,
            countryCode: countryCode,
            timezone: timezone,
          );
    });
  }
}
