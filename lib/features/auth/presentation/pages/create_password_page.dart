import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lorofy/components/ui/button.dart';
import 'package:lorofy/components/ui/input.dart';
import 'package:lorofy/core/theme/app_theme.dart';
import '../providers/create_password_controller.dart';

class CreatePasswordPage extends ConsumerStatefulWidget {
  final String signupToken;
  final String email;

  const CreatePasswordPage({
    super.key,
    required this.signupToken,
    required this.email,
  });

  @override
  ConsumerState<CreatePasswordPage> createState() => _CreatePasswordPageState();
}

class _CreatePasswordPageState extends ConsumerState<CreatePasswordPage> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  String? _validationError;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  // Tính toán password strength (0-3)
  int _getPasswordStrength(String password) {
    if (password.isEmpty) return 0;
    int score = 0;
    if (password.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    return score;
  }

  Future<void> _handleSubmit() async {
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    // Validation
    if (password.length < 6) {
      setState(() => _validationError = 'Password must be at least 6 characters');
      return;
    }
    if (password != confirm) {
      setState(() => _validationError = 'Passwords do not match');
      return;
    }
    setState(() => _validationError = null);

    await ref.read(createPasswordControllerProvider.notifier).createAccount(
      signupToken: widget.signupToken,
      password: password,
      email: widget.email,
    );

    // Nếu thành công, authProvider sẽ tự đổi state → router tự redirect về /
    // Nếu có lỗi, hiển thị bên dưới
  }

  @override
  Widget build(BuildContext context) {
    final createState = ref.watch(createPasswordControllerProvider);
    final isLoading = createState.isLoading;
    final serverError = createState.hasError
        ? _parseError(createState.error)
        : null;
    final password = _passwordController.text;
    final strength = _getPasswordStrength(password);
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
                        // Header
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
                              'Create Password',
                              style: AppTextStyles.titleMedium.copyWith(
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 36),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Title & subtitle
                        Text(
                          'Set your password',
                          style: AppTextStyles.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Choose a strong password to protect your account',
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.secondary,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Password field
                        Input(
                          label: 'Password',
                          placeholder: '••••••••',
                          controller: _passwordController,
                          obscureText: true,
                          disabled: isLoading,
                          onChanged: (_) => setState(() {}),
                          errorMessage: _validationError != null &&
                                  _validationError!.contains('least')
                              ? _validationError
                              : null,
                        ),

                        // Password strength indicator
                        if (password.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          _PasswordStrengthBar(strength: strength),
                          const SizedBox(height: 4),
                          Text(
                            _strengthLabel(strength),
                            style: AppTextStyles.body.copyWith(
                              fontSize: 12,
                              color: _strengthColor(strength),
                            ),
                          ),
                        ],

                        const SizedBox(height: 16),

                        // Confirm password field
                        Input(
                          label: 'Confirm Password',
                          placeholder: '••••••••',
                          controller: _confirmController,
                          obscureText: true,
                          disabled: isLoading,
                          onChanged: (_) => setState(() {}),
                          errorMessage: _validationError != null &&
                                  _validationError!.contains('match')
                              ? _validationError
                              : null,
                        ),

                        const SizedBox(height: 24),

                        // Server error
                        if (serverError != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  CupertinoColors.systemRed.withOpacity(0.08),
                              borderRadius:
                                  BorderRadius.circular(AppRadius.sm),
                              border: Border.all(
                                color: CupertinoColors.systemRed
                                    .withOpacity(0.3),
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
                                    serverError,
                                    style: AppTextStyles.body.copyWith(
                                      color: CupertinoColors.systemRed,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Submit button
                        Button.primary(
                          text: 'Create Account',
                          isLoading: isLoading,
                          onPressed: isLoading ? null : _handleSubmit,
                        ),

                        const SizedBox(height: 20),

                        // Terms note
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text.rich(
                            TextSpan(
                              text: 'By creating an account you agree to our ',
                              style: AppTextStyles.caption,
                              children: [
                                TextSpan(
                                  text: 'Terms of Service',
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const TextSpan(text: ' and '),
                                TextSpan(
                                  text: 'Privacy Policy',
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
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

  String _strengthLabel(int strength) {
    switch (strength) {
      case 1:
        return 'Weak';
      case 2:
        return 'Fair';
      case 3:
        return 'Strong';
      default:
        return 'Too short';
    }
  }

  Color _strengthColor(int strength) {
    switch (strength) {
      case 1:
        return CupertinoColors.systemRed;
      case 2:
        return CupertinoColors.systemOrange;
      case 3:
        return CupertinoColors.systemGreen;
      default:
        return AppColors.secondary;
    }
  }

  String _parseError(Object? error) {
    if (error == null) return 'Something went wrong';
    final msg = error.toString();
    if (msg.contains('Signup token is invalid') ||
        msg.contains('expired')) {
      return 'Session expired. Please restart the registration.';
    }
    if (msg.contains('already registered')) {
      return 'This email is already registered.';
    }
    return 'Failed to create account. Please try again.';
  }
}

// Password strength visual bar
class _PasswordStrengthBar extends StatelessWidget {
  final int strength; // 0-3

  const _PasswordStrengthBar({required this.strength});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(3, (i) {
        final isActive = i < strength;
        Color color;
        if (strength == 1) {
          color = CupertinoColors.systemRed;
        } else if (strength == 2) {
          color = CupertinoColors.systemOrange;
        } else {
          color = CupertinoColors.systemGreen;
        }
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: i < 2 ? 4 : 0),
            height: 4,
            decoration: BoxDecoration(
              color: isActive ? color : AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}
