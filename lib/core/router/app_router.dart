import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:lorofy/features/home/presentation/pages/home_page.dart';
import 'package:lorofy/features/explore/presentation/pages/explore_page.dart';
import 'package:lorofy/features/profile/presentation/pages/onboard_page.dart';
import 'package:lorofy/features/profile/presentation/pages/my_profile_page.dart';
import 'package:lorofy/features/profile/presentation/pages/my_activities_page.dart';
import 'package:lorofy/features/profile/presentation/pages/my_points_page.dart';
import 'package:lorofy/features/profile/presentation/pages/notifications_page.dart';
import 'package:lorofy/features/focus/presentation/pages/session_settings_page.dart';
import 'package:lorofy/features/settings/presentation/pages/settings_page.dart';
import 'package:lorofy/features/focus/presentation/pages/sound_settings_page.dart';
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
  return GoRouter(
    initialLocation: '/splash', // Initial route starting at Splash screen
    refreshListenable: GoRouterRefreshNotifier(ref),
    routes: [
      // 1. Splash screen
      GoRoute(path: '/splash', builder: (context, state) => const SplashPage()),
      // 2. Landing/Overview screen
      GoRoute(
        path: '/overview',
        builder: (context, state) => const OverviewPage(),
      ),
      // 3. Login screen
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      // 4. Register screen (Enter Email)
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      // 5. Verify OTP screen
      GoRoute(
        path: '/register/verify-otp',
        builder: (context, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          return VerifyOtpPage(email: email);
        },
      ),
      // 6. Create Password screen
      GoRoute(
        path: '/register/create-password',
        builder: (context, state) {
          final signupToken = state.uri.queryParameters['signupToken'] ?? '';
          final email = state.uri.queryParameters['email'] ?? '';
          return CreatePasswordPage(signupToken: signupToken, email: email);
        },
      ),
      // 7. Home screen
      GoRoute(path: '/', builder: (context, state) => const HomePage()),
      // 7a. Explore screen (Slide up transition)
      GoRoute(
        path: '/explore',
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: const ExplorePage(),
            transitionDuration: const Duration(milliseconds: 350),
            reverseTransitionDuration: const Duration(milliseconds: 350),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.0, 1.0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                    reverseCurve: Curves.easeInCubic,
                  ),
                ),
                child: FadeTransition(
                  opacity: Tween<double>(
                    begin: 0.0,
                    end: 1.0,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeIn,
                    ),
                  ),
                  child: child,
                ),
              );
            },
          );
        },
      ),

      // 8. Onboard screen
      GoRoute(
        path: '/onboard',
        builder: (context, state) => const OnboardPage(),
      ),
      // 8a. My Profile screen
      GoRoute(
        path: '/my-profile',
        builder: (context, state) => const MyProfilePage(),
      ),
      // 8b. My Activities screen
      GoRoute(
        path: '/my-activities',
        builder: (context, state) => const MyActivitiesPage(),
      ),
      // 8c. Notifications screen
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsPage(),
      ),
      // 8d. My Points screen
      GoRoute(
        path: '/my-points',
        builder: (context, state) => const MyPointsPage(),
      ),
      // 9. Settings screen
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsPage(),
      ),
      // 9a. Focus Settings screen
      GoRoute(
        path: '/session-settings',
        builder: (context, state) => const SessionSettingsPage(),
      ),
      // 9b. Sound Settings screen
      GoRoute(
        path: '/sound-settings',
        builder: (context, state) => const SoundSettingsPage(),
      ),
    ],

    // --- AUTOMATIC REDIRECT LOGIC ---
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
      notifyListeners(); // Re-trigger router redirect evaluation when auth status changes
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
