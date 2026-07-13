import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lorofy/components/ui/button.dart';
import 'package:lorofy/components/ui/input.dart';
import 'package:lorofy/components/ui/svg_asset.dart';
import 'package:lorofy/components/ui/toast.dart';
import 'package:lorofy/core/theme/app_theme.dart';
import '../providers/login_controller.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

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
            message: error.toString(),
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

    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset:
          true, // Cho phép đẩy giao diện khi bàn phím hiện
      child: Stack(
        children: [
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

          // 2. Nội dung cuộn toàn màn hình - Chống tràn khi hiện bàn phím
          Positioned(
            bottom: 4,
            left: 4,
            right: 4,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // Card trắng bo tròn ôm sát lề (Full-bleed)
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
                        // Nút Back + Tiêu đề
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
                              'Login',
                              style: AppTextStyles.titleMedium.copyWith(
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 36),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Text('Welcome back', style: AppTextStyles.titleLarge),
                        const SizedBox(height: 20),

                        Input(
                          label: 'Email address',
                          placeholder: 'alexsmith.mobbin@gmail.com',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          disabled: loginState.isLoading,
                        ),
                        const SizedBox(height: 16),
                        Input(
                          label: 'Password',
                          placeholder: '••••••••',
                          controller: _passwordController,
                          obscureText: true,
                          disabled: loginState.isLoading,
                        ),

                        const SizedBox(height: 24),
                        Button.primary(
                          text: 'Log in',
                          isLoading: loginState.isLoading,
                          onPressed: _handleLogin,
                        ),
                        const SizedBox(height: 20),
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
}
