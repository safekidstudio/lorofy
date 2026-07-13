import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lorofy/components/ui/button.dart';
import 'package:lorofy/components/ui/otp_input.dart';
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
    // Auto-verify khi nhập đủ 6 số
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
    final errorMessage = otpState.error != null
        ? _parseError(otpState.error!)
        : null;
    final screenHeight = MediaQuery.of(context).size.height;

    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      child: Stack(
        children: [
          // 1. Background Image
          Positioned.fill(
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/auth_bg_1.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Container(color: CupertinoColors.black),
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    color: CupertinoColors.black.withOpacity(0.4),
                  ),
                ),
              ],
            ),
          ),

          // 2. Scrollable content
          Positioned(
            bottom: 4,
            left: 4,
            right: 4,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(AppRadius.lg),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CupertinoButton(
                              padding: EdgeInsets.zero,
                              onPressed: isLoading ? null : () => context.pop(),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: const BoxDecoration(
                                  color: AppColors.inputBg,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  CupertinoIcons.left_chevron,
                                  size: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            Text(
                              'Verify Email',
                              style: AppTextStyles.titleMedium.copyWith(
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 36),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Title
                        Text(
                          'Check your email',
                          style: AppTextStyles.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text.rich(
                          TextSpan(
                            text: 'We sent a 6-digit code to ',
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
                        ),
                        const SizedBox(height: 24),

                        // OTP Input
                        OtpInput(
                          onCodeCompleted: _onCodeCompleted,
                          hasError: errorMessage != null,
                        ),

                        // Error message
                        if (errorMessage != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: CupertinoColors.systemRed.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                              border: Border.all(
                                color: CupertinoColors.systemRed.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  CupertinoIcons.exclamationmark_circle,
                                  size: 16,
                                  color: CupertinoColors.systemRed,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    errorMessage,
                                    style: AppTextStyles.body.copyWith(
                                      color: CupertinoColors.systemRed,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 24),

                        // Verify button (manual fallback)
                        Button.primary(
                          text: 'Verify Code',
                          isLoading: isLoading,
                          onPressed: (_otpCode.length == 6 && !isLoading)
                              ? () => _handleVerify(_otpCode)
                              : null,
                        ),

                        const SizedBox(height: 20),

                        // Resend section
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
                                      ),
                                    ),
                                  ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
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
    return 'Verification failed. Please try again.';
  }
}
