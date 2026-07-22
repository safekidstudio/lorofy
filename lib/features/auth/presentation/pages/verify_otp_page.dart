import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lorofy/components/ui/button.dart';
import 'package:lorofy/components/ui/otp_input.dart';
import 'package:lorofy/components/ui/page_wrapper.dart';
import 'package:lorofy/components/ui/top_bar.dart';
import 'package:lorofy/core/theme/app_theme.dart';
import '../providers/verify_otp_controller.dart';

class VerifyOtpPage extends ConsumerStatefulWidget {
  final String email;

  const VerifyOtpPage({super.key, required this.email});

  @override
  ConsumerState<VerifyOtpPage> createState() => _VerifyOtpPageState();
}

class _VerifyOtpPageState extends ConsumerState<VerifyOtpPage> {
  String _otpCode = '';

  // Countdown resend
  int _cooldownSeconds = 60;
  Timer? _cooldownTimer;

  @override
  void initState() {
    super.initState();
    _startCooldown();
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    setState(() => _cooldownSeconds = 60);
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_cooldownSeconds <= 1) {
        timer.cancel();
        setState(() => _cooldownSeconds = 0);
      } else {
        setState(() => _cooldownSeconds--);
      }
    });
  }

  void _onCodeCompleted(String code) {
    setState(() => _otpCode = code);
    if (code.length == 6) {
      _handleVerify(code);
    }
  }

  Future<void> _handleVerify(String code) async {
    await ref
        .read(verifyOtpControllerProvider.notifier)
        .verifyOtp(email: widget.email, otpCode: code);

    final state = ref.read(verifyOtpControllerProvider);
    if (state.signupToken != null && mounted) {
      context.push(
        '/register/create-password'
        '?signupToken=${Uri.encodeComponent(state.signupToken!)}'
        '&email=${Uri.encodeComponent(widget.email)}',
      );
    }
  }

  Future<void> _handleResend() async {
    if (_cooldownSeconds > 0) return;
    await ref
        .read(verifyOtpControllerProvider.notifier)
        .resendOtp(email: widget.email);
    _startCooldown();
  }

  String get _maskedEmail {
    if (!widget.email.contains('@')) return widget.email;
    final parts = widget.email.split('@');
    final name = parts[0];
    final domain = parts[1];
    if (name.length <= 4) return '****@$domain';
    return '${name.substring(0, 2)}****${name.substring(name.length - 2)}@$domain';
  }

  @override
  Widget build(BuildContext context) {
    final otpState = ref.watch(verifyOtpControllerProvider);
    final isLoading = otpState.isLoading;
    final errorMessage =
        otpState.error != null ? _parseError(otpState.error!) : null;

    return PageWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Back button
          const TopBar(),
          const Spacer(),

          // 2. Title
          Text(
            'Verify your OTP',
            style: TextStyle(
              fontFamily: AppTextStyles.titleFontFamily,
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF232321),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // 3. Subtitle with masked email
          Text.rich(
            TextSpan(
              text: 'Enter your OTP sent to ',
              style: AppTextStyles.body.copyWith(
                color: AppColors.secondary,
                fontSize: 14,
              ),
              children: [
                TextSpan(
                  text: _maskedEmail,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // 4. OTP Input
          OtpInput(
            onCodeCompleted: _onCodeCompleted,
            hasError: errorMessage != null,
          ),

          // 5. Error
          if (errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              errorMessage,
              style: AppTextStyles.body.copyWith(
                color: CupertinoColors.systemRed,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ],

          const SizedBox(height: 28),

          // 6. Verify button
          Center(
            child: SizedBox(
              width: 180,
              child: Button.primary(
                text: 'Verify',
                isLoading: isLoading,
                onPressed: (_otpCode.length == 6 && !isLoading)
                    ? () => _handleVerify(_otpCode)
                    : null,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // 7. Resend section
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Didn't receive it? ",
                style: AppTextStyles.body.copyWith(
                  color: AppColors.secondary,
                  fontSize: 14,
                ),
              ),
              _cooldownSeconds > 0
                  ? Text(
                      'Resend in ${_cooldownSeconds}s',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.secondary,
                        fontSize: 14,
                      ),
                    )
                  : CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: isLoading ? null : _handleResend,
                      child: Text(
                        'Resend OTP',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.primary,
                        ),
                      ),
                    ),
            ],
          ),

          const Spacer(),
        ],
      ),
    );
  }

  String _parseError(String error) {
    if (error.contains('invalid or expired')) {
      return 'OTP expired. Please request a new code.';
    }
    if (error.contains('invalid')) {
      return 'Incorrect code. Please try again.';
    }
    return error;
  }
}
