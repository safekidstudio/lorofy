import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lorofy/components/ui/button.dart';
import 'package:lorofy/components/ui/input.dart';
import 'package:lorofy/components/ui/svg_asset.dart';
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
                        top: Radius.circular(AppRadius.xl),
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
                              onPressed: () => context.pop(),
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
                              'Signup',
                              style: AppTextStyles.titleMedium.copyWith(
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 36),
                          ],
                        ),
                        const SizedBox(height: 32),
                        Text(
                          'Create your account',
                          style: AppTextStyles.titleLarge,
                        ),
                        const SizedBox(height: 24),

                        // Email field
                        Input(
                          label: 'Email address',
                          placeholder: 'alexsmith@gmail.com',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          disabled: isLoading,
                          errorMessage: errorMessage,
                        ),
                        const SizedBox(height: 24),

                        // Continue button
                        Button.primary(
                          text: 'Continue',
                          isLoading: isLoading,
                          onPressed: isLoading ? null : _onContinue,
                        ),

                        const SizedBox(height: 20),

                        // Divider
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 1,
                                color: AppColors.border,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                              ),
                              child: Text(
                                'or',
                                style: AppTextStyles.body.copyWith(
                                  color: AppColors.secondary,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                height: 1,
                                color: AppColors.border,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),
                        Button.outline(
                          text: 'Continue with Google',
                          prefix: const SVG(
                            'assets/logos/google.svg',
                            width: 18,
                            height: 18,
                          ),
                          onPressed: () {},
                        ),
                        const SizedBox(height: 10),
                        Button.outline(
                          text: 'Continue with Apple',
                          prefix: const SVG(
                            'assets/logos/apple.svg',
                            width: 18,
                            height: 18,
                          ),
                          onPressed: () {},
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
