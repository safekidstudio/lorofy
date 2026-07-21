import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lorofy/components/ui/button.dart';
import 'package:lorofy/components/ui/input.dart';
import 'package:lorofy/components/ui/wavy_divider.dart';
import 'package:lorofy/components/ui/social_button.dart';
import 'package:lorofy/components/ui/top_bar.dart';
import 'package:lorofy/components/ui/page_wrapper.dart';
import 'package:lorofy/components/ui/toast.dart';
import 'package:lorofy/core/theme/app_theme.dart';
import '../providers/register_controller.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _onContinue() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) return;

    await ref.read(registerControllerProvider.notifier).sendOtp(email: email);

    // Chỉ navigate nếu không có lỗi
    final state = ref.read(registerControllerProvider);
    if (state.hasError) return;

    if (mounted) {
      context.push('/register/verify-otp?email=${Uri.encodeComponent(email)}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final registerState = ref.watch(registerControllerProvider);
    final isLoading = registerState.isLoading;
    final errorMessage = registerState.hasError
        ? _parseError(registerState.error)
        : null;

    return PageWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
              // 1. Header Back Button
              const TopBar(),
              const Spacer(),

              // 2. Title "What's your email?"
              Text(
                "What's your email?",
                style: TextStyle(
                  fontFamily: AppTextStyles.titleFontFamily,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF232321),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),

              // 3. Flat email input field (without top label text)
              Input(
                placeholder: 'example@lorofy.com',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                disabled: isLoading,
                errorMessage: errorMessage,
              ),
              const SizedBox(height: 28),

              // 4. Centered, smaller Continue button
              Center(
                child: SizedBox(
                  width: 180,
                  child: Button.primary(
                    text: 'Continue',
                    isLoading: isLoading,
                    onPressed: isLoading ? null : _onContinue,
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // 5. Wavy Divider
              const WavyDivider(text: 'Or'),
              const SizedBox(height: 24),

              // 6. Circular Social Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SocialIconButton(
                    svgPath: 'assets/icons/apple-drawing.svg',
                    onPressed: () => AppToast.show(
                      context,
                      message: 'Apple Sign-in is coming soon!',
                      type: ToastType.info,
                    ),
                  ),
                  const SizedBox(width: 20),
                  SocialIconButton(
                    svgPath: 'assets/icons/google-drawing.svg',
                    onPressed: () => AppToast.show(
                      context,
                      message: 'Google Sign-in is coming soon!',
                      type: ToastType.info,
                    ),
                  ),
                ],
              ),
              const Spacer(),
            ],
          ),
    );
  }

  String _parseError(Object? error) {
    if (error == null) return 'Something went wrong';
    final msg = error.toString();
    if (msg.contains('already registered') || msg.contains('already exists')) {
      return 'This email is already registered';
    }
    if (msg.contains('invalid') || msg.contains('Email')) {
      return 'Please enter a valid email';
    }
    if (msg.contains('wait') || msg.contains('cooldown')) {
      return 'Please wait before sending another OTP';
    }
    return 'Failed to send OTP. Please try again.';
  }
}
