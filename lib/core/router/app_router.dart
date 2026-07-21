import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:lorofy/features/home/presentation/pages/home_page.dart';
import 'package:lorofy/features/profile/presentation/pages/onboard_page.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:lorofy/features/auth/presentation/providers/auth_provider.dart';
import 'package:lorofy/features/auth/presentation/pages/splash_page.dart';
import 'package:lorofy/features/auth/presentation/pages/overview_page.dart';
import 'package:lorofy/features/auth/presentation/pages/login_page.dart';
import 'package:lorofy/features/auth/presentation/pages/register_page.dart';
import 'package:lorofy/features/auth/presentation/pages/verify_otp_page.dart';
import 'package:lorofy/features/auth/presentation/pages/create_password_page.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(Ref ref) {
  ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/splash', // Bắt đầu chạy từ màn hình Splash
    refreshListenable: GoRouterRefreshNotifier(ref),
    routes: [
      // 1. Màn hình Splash
      GoRoute(path: '/splash', builder: (context, state) => const SplashPage()),
      // 2. Màn hình Landing/Overview
      GoRoute(
        path: '/overview',
        builder: (context, state) => const OverviewPage(),
      ),
      // 3. Màn hình Login
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      // 4. Màn hình Đăng ký (Nhập Email)
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      // 5. Màn hình Nhập OTP Đăng ký
      GoRoute(
        path: '/register/verify-otp',
        builder: (context, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          return VerifyOtpPage(email: email);
        },
      ),
      // 6. Màn hình Tạo mật khẩu
      GoRoute(
        path: '/register/create-password',
        builder: (context, state) {
          final signupToken = state.uri.queryParameters['signupToken'] ?? '';
          final email = state.uri.queryParameters['email'] ?? '';
          return CreatePasswordPage(signupToken: signupToken, email: email);
        },
      ),
      // 7. Màn hình chính (Home)
      GoRoute(path: '/', builder: (context, state) => const HomePage()),

      // 8. Màn hình Onboard
      GoRoute(
        path: '/onboard',
        builder: (context, state) => const OnboardPage(),
      ),
    ],

    // --- XỬ LÝ ĐIỀU HƯỚNG TỰ ĐỘNG (REDIRECT LOGIC) ---
    redirect: (context, state) {
      final authStatus = ref.read(authProvider);
      final isLoggedIn = authStatus.state == AuthState.authenticated;
      final isChecking = authStatus.state == AuthState.initial;
      final isOnboarded = authStatus.isOnboarded == true;
      if (isChecking) return '/splash';
      final goingToSplash = state.matchedLocation == '/splash';
      final goingToOnboard = state.matchedLocation == '/onboard';
      if (goingToSplash) {
        if (!isLoggedIn) return '/overview';
        return isOnboarded ? '/' : '/onboard';
      }
      final isGoingToAuthArea =
          state.matchedLocation == '/overview' ||
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/register/verify-otp' ||
          state.matchedLocation == '/register/create-password';
      if (!isLoggedIn && !isGoingToAuthArea) {
        return '/overview';
      }
      if (isLoggedIn && !isOnboarded && !goingToOnboard) {
        return '/onboard';
      }
      if (isLoggedIn && isOnboarded && (isGoingToAuthArea || goingToOnboard)) {
        return '/';
      }
      return null;
    },
  );
}

class GoRouterRefreshNotifier extends ChangeNotifier {
  GoRouterRefreshNotifier(Ref ref) {
    ref.listen(authProvider, (previous, next) {
      notifyListeners(); // Kích hoạt chạy lại redirect khi auth status thay đổi
    });
  }
}

class PlaceholderPage extends StatelessWidget {
  final String title;
  const PlaceholderPage({super.key, required this.title});
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Lorofy')),
      child: Center(child: Text(title)),
    );
  }
}
