import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lorofy/components/ui/button.dart';
import 'package:lorofy/components/ui/input.dart';
import 'package:lorofy/components/shared/wavy_divider.dart';
import 'package:lorofy/components/ui/social_button.dart';
import 'package:lorofy/components/layout/top_bar.dart';
import 'package:lorofy/components/layout/page_wrapper.dart';
import 'package:lorofy/components/ui/toast.dart';
import 'package:lorofy/core/theme/app_theme.dart';
import 'package:lorofy/core/errors/exceptions.dart';
import 'package:reactive_forms/reactive_forms.dart';
import '../providers/login_controller.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  late FormGroup _form;

  @override
  void initState() {
    super.initState();
    _form = FormGroup({
      'email': FormControl<String>(
        validators: [Validators.required, Validators.email],
      ),
      'password': FormControl<String>(
        validators: [Validators.required, Validators.minLength(6)],
      ),
    });
  }

  Future<void> _handleLogin() async {
    final email = (_form.value['email'] as String?)?.trim() ?? '';
    final password = (_form.value['password'] as String?)?.trim() ?? '';

    if (email.isEmpty || password.isEmpty) return;

    await ref
        .read(loginControllerProvider.notifier)
        .login(email: email, password: password);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(loginControllerProvider, (previous, next) {
      next.whenOrNull(
        error: (error, _) {
          AppToast.show(
            context,
            message: error.errorMessage,
            type: ToastType.error,
          );
        },
        data: (_) {
          AppToast.show(
            context,
            message: 'Welcome back to Lorofy!',
            type: ToastType.success,
          );
        },
      );
    });

    final loginState = ref.watch(loginControllerProvider);

    return PageWrapper(
      child: ReactiveForm(
        formGroup: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Header Back Button
            const TopBar(),
            const Spacer(),

            // 2. Title "Login your account"
            Text(
              'Login your account',
              style: TextStyle(
                fontFamily: AppTextStyles.titleFontFamily,
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF232321),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),

            // 3. Flat input fields (without top label text)
            Input(
              placeholder: 'example@lorofy.com',
              formControlName: 'email',
              keyboardType: TextInputType.emailAddress,
              disabled: loginState.isLoading,
            ),
            const SizedBox(height: 16),
            Input(
              placeholder: '****************',
              formControlName: 'password',
              obscureText: true,
              disabled: loginState.isLoading,
            ),
            const SizedBox(height: 28),

            // 4. Centered, smaller Login button
            Center(
              child: SizedBox(
                width: 180,
                child: ReactiveFormConsumer(
                  builder: (context, form, child) {
                    return Button.primary(
                      text: 'Login',
                      isLoading: loginState.isLoading,
                      onPressed: (form.valid && !loginState.isLoading)
                          ? _handleLogin
                          : null,
                    );
                  },
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
                    type: ToastType.success,
                  ),
                ),
              ],
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
