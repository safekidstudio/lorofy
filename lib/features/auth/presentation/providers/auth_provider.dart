import 'package:dio/dio.dart';
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
  final String? avatarUrl;
  final String? username;
  final int? rankPoints;

  AuthStatus({
    required this.state,
    this.accessToken,
    this.isOnboarded,
    this.displayName,
    this.avatarUrl,
    this.username,
    this.rankPoints,
  });

  AuthStatus copyWith({
    AuthState? state,
    String? accessToken,
    bool? isOnboarded,
    String? displayName,
    String? avatarUrl,
    String? username,
    int? rankPoints,
  }) {
    return AuthStatus(
      state: state ?? this.state,
      accessToken: accessToken ?? this.accessToken,
      isOnboarded: isOnboarded ?? this.isOnboarded,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      username: username ?? this.username,
      rankPoints: rankPoints ?? this.rankPoints,
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
        final cachedIsOnboarded = await _authStorage.getIsOnboarded();
        final cachedDisplayName = await _authStorage.getDisplayName();
        final cachedAvatarUrl = await _authStorage.getAvatarUrl();
        final cachedUsername = await _authStorage.getUsername();

        if (cachedIsOnboarded != null) {
          // Optimistic: instantly login with cached data for instant feed/homepage
          state = AuthStatus(
            state: AuthState.authenticated,
            accessToken: token,
            isOnboarded: cachedIsOnboarded,
            displayName: cachedDisplayName,
            avatarUrl: cachedAvatarUrl,
            username: cachedUsername,
          );
        }

        // Fetch fresh profile in the background
        final profile = await ref.read(authRepositoryProvider).getMe();
        
        // Cache the fresh profile
        await _authStorage.saveProfileCache(
          isOnboarded: profile.isOnboarded,
          displayName: profile.displayName,
          avatarUrl: profile.avatarUrl,
          username: profile.username,
        );

        // Update RAM state with fresh details
        state = AuthStatus(
          state: AuthState.authenticated,
          accessToken: token,
          isOnboarded: profile.isOnboarded,
          displayName: profile.displayName,
          avatarUrl: profile.avatarUrl,
          username: profile.username,
          rankPoints: profile.rankPoints,
        );
      } else {
        state = AuthStatus(state: AuthState.unauthenticated);
      }
    } catch (e) {
      // If error is 401 Unauthorized, token is invalid -> logout
      // Otherwise (offline/network errors), keep the cached session!
      final isAuthError = e is DioException && e.response?.statusCode == 401;
      if (isAuthError) {
        await logout();
      } else if (state.state == AuthState.initial) {
        // If we are offline and have no cache (e.g. initial launch offline), fallback to unauthenticated
        state = AuthStatus(state: AuthState.unauthenticated);
      }
    }
  }

  // Handle successful login from API response
  Future<void> loginSuccess({
    required String accessToken,
    required String refreshToken,
    required bool isOnboarded,
    required String? displayName,
    required String? avatarUrl,
    required String? username,
    required int rankPoints,
  }) async {
    // Save to Secure Storage
    await _authStorage.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
    // Cache the profile details
    await _authStorage.saveProfileCache(
      isOnboarded: isOnboarded,
      displayName: displayName,
      avatarUrl: avatarUrl,
      username: username,
    );
    // Update RAM and change state
    state = AuthStatus(
      state: AuthState.authenticated,
      accessToken: accessToken,
      isOnboarded: isOnboarded,
      displayName: displayName,
      avatarUrl: avatarUrl,
      username: username,
      rankPoints: rankPoints,
    );
  }

  // Handle logout
  Future<void> logout() async {
    // Clear from Secure Storage
    await _authStorage.clearTokens();

    // Reset RAM to default
    state = AuthStatus(state: AuthState.unauthenticated);
  }

  Future<void> updateOnboardedState({
    required bool onboarded,
    required String displayName,
  }) async {
    String? avatarUrl;
    String? username;
    try {
      final profile = await ref.read(authRepositoryProvider).getMe();
      avatarUrl = profile.avatarUrl;
      username = profile.username;
    } catch (e) {
      // ignore
    }

    await _authStorage.saveProfileCache(
      isOnboarded: onboarded,
      displayName: displayName,
      avatarUrl: avatarUrl,
      username: username,
    );
    state = state.copyWith(
      isOnboarded: onboarded,
      displayName: displayName,
      avatarUrl: avatarUrl,
      username: username,
    );
  }

  Future<void> updateProfileState({
    required String displayName,
    required String? avatarUrl,
    required String? username,
  }) async {
    await _authStorage.saveProfileCache(
      isOnboarded: state.isOnboarded ?? true,
      displayName: displayName,
      avatarUrl: avatarUrl,
      username: username,
    );
    state = state.copyWith(
      displayName: displayName,
      avatarUrl: avatarUrl,
      username: username,
    );
  }

  Future<void> updateTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _authStorage.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
    state = state.copyWith(
      state: AuthState.authenticated,
      accessToken: accessToken,
    );
  }

  void updatePointsState(int points) {
    state = state.copyWith(rankPoints: points);
  }
}
