import 'package:lorofy/features/auth/data/repositories/auth_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'verify_otp_controller.g.dart';

// State chứa signupToken sau khi verify thành công
class VerifyOtpState {
  final bool isLoading;
  final String? signupToken;
  final String? error;

  const VerifyOtpState({
    this.isLoading = false,
    this.signupToken,
    this.error,
  });

  VerifyOtpState copyWith({
    bool? isLoading,
    String? signupToken,
    String? error,
  }) {
    return VerifyOtpState(
      isLoading: isLoading ?? this.isLoading,
      signupToken: signupToken ?? this.signupToken,
      error: error ?? this.error,
    );
  }
}

@riverpod
class VerifyOtpController extends _$VerifyOtpController {
  @override
  VerifyOtpState build() {
    return const VerifyOtpState();
  }

  // Step 2: Xác thực OTP → lưu signupToken vào state
  Future<void> verifyOtp({
    required String email,
    required String otpCode,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final signupToken = await ref
          .read(authRepositoryProvider)
          .verifyOtp(email, otpCode);
      state = state.copyWith(isLoading: false, signupToken: signupToken);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // Gửi lại OTP (gọi lại sendOtp)
  Future<String?> resendOtp({required String email}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await ref.read(authRepositoryProvider).sendOtp(email);
      state = state.copyWith(isLoading: false);
      return null; // success
    } catch (e) {
      final errorMsg = e.toString();
      state = state.copyWith(isLoading: false, error: errorMsg);
      return errorMsg;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
