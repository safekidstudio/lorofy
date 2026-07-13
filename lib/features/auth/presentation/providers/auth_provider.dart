import 'package:lorofy/core/storage/auth_storage.dart';
import 'package:lorofy/features/auth/data/repositories/auth_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_provider.g.dart';

enum AuthState { initial, authenticated, unauthenticated }

class AuthStatus {
  final AuthState state;
  final String? accessToken;
  final bool? isOnboarded;
  final String? displayName;

  AuthStatus({
    required this.state,
    this.accessToken,
    this.isOnboarded,
    this.displayName,
  });

  AuthStatus copyWith({
    AuthState? state,
    String? accessToken,
    bool? isOnboarded,
    String? displayName,
  }) {
    return AuthStatus(
      state: state ?? this.state,
      accessToken: accessToken ?? this.accessToken,
      isOnboarded: isOnboarded ?? this.isOnboarded,
      displayName: displayName ?? this.displayName,
    );
  }
}

@Riverpod(keepAlive: true)
class Auth extends _$Auth {
  late final AuthStorage _authStorage;

  @override
  AuthStatus build() {
    _authStorage = ref.read(authStorageProvider);

    _checkInitialAuth();

    return AuthStatus(state: AuthState.initial);
  }

  // Check initial auth state
  Future<void> _checkInitialAuth() async {
    try {
      final token = await _authStorage.getAccessToken();
      if (token != null) {
        state = AuthStatus(state: AuthState.authenticated, accessToken: token);

        final profile = await ref.read(authRepositoryProvider).getMe();
        state = AuthStatus(
          state: AuthState.authenticated,
          accessToken: token,
          isOnboarded: profile.isOnboarded,
          displayName: profile.displayName,
        );
      } else {
        state = AuthStatus(state: AuthState.unauthenticated);
      }
    } catch (e) {
      // Nếu có lỗi (ví dụ không hỗ trợ secure storage trên web Chrome), fallback về unauthenticated
      state = AuthStatus(state: AuthState.unauthenticated);
    }
  }

  // Handle successful login from API response
  Future<void> loginSuccess({
    required String accessToken,
    required String refreshToken,
    required bool isOnboarded,
    required String? displayName,
  }) async {
    // Save to Secure Storage
    await _authStorage.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
    // Update RAM and change state
    state = AuthStatus(
      state: AuthState.authenticated,
      accessToken: accessToken,
      isOnboarded: isOnboarded,
      displayName: displayName,
    );
  }

  // Handle logout
  Future<void> logout() async {
    // Clear from Secure Storage
    await _authStorage.clearTokens();

    // Reset RAM to default
    state = AuthStatus(state: AuthState.unauthenticated);
  }

  void updateOnboardedState({
    required bool onboarded,
    required String displayName,
  }) {
    state = state.copyWith(isOnboarded: onboarded, displayName: displayName);
  }
}
