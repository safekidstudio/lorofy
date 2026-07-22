import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lorofy/components/ui/button.dart';
import 'package:lorofy/components/ui/input.dart';
import 'package:lorofy/components/ui/page_wrapper.dart';
import 'package:lorofy/components/ui/top_bar.dart';
import 'package:lorofy/core/theme/app_theme.dart';
import 'package:lorofy/core/errors/exceptions.dart';
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
  ConsumerState<CreatePasswordPage> createState() =>
      _CreatePasswordPageState();
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

    if (password.length < 6) {
      setState(
          () => _validationError = 'Password must be at least 6 characters');
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
  }

  @override
  Widget build(BuildContext context) {
    final createState = ref.watch(createPasswordControllerProvider);
    final isLoading = createState.isLoading;
    final serverError =
        createState.hasError ? _parseError(createState.error) : null;
    final password = _passwordController.text;
    final strength = _getPasswordStrength(password);

    return PageWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Back button
          const TopBar(),
          const Spacer(),

          // 2. Title
          Text(
            'Create your\npassword',
            style: TextStyle(
              fontFamily: AppTextStyles.titleFontFamily,
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF232321),
              height: 1.15,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          Text(
            'Please create your strong password',
            style: AppTextStyles.body.copyWith(
              color: AppColors.secondary,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // 3. Password field
          Input(
            placeholder: 'Password',
            controller: _passwordController,
            obscureText: true,
            disabled: isLoading,
            onChanged: (_) => setState(() {}),
            errorMessage:
                _validationError != null && _validationError!.contains('least')
                    ? _validationError
                    : null,
          ),

          // 4. Password strength bar
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

          // 5. Confirm password field
          Input(
            placeholder: 'Confirm password',
            controller: _confirmController,
            obscureText: true,
            disabled: isLoading,
            onChanged: (_) => setState(() {}),
            errorMessage: _validationError != null &&
                    _validationError!.contains('match')
                ? _validationError
                : null,
          ),

          // 6. Server error
          if (serverError != null) ...[
            const SizedBox(height: 12),
            Text(
              serverError,
              style: AppTextStyles.body.copyWith(
                color: CupertinoColors.systemRed,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ],

          const SizedBox(height: 28),

          // 7. Create button
          Center(
            child: SizedBox(
              width: 180,
              child: Button.primary(
                text: 'Create',
                isLoading: isLoading,
                onPressed: isLoading ? null : _handleSubmit,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // 8. Terms note
          Text.rich(
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

          const Spacer(),
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
    final msg = error.errorMessage;
    if (msg.contains('Signup token is invalid') || msg.contains('expired')) {
      return 'Session expired. Please restart the registration.';
    }
    if (msg.contains('already registered')) {
      return 'This email is already registered.';
    }
    return msg;
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
