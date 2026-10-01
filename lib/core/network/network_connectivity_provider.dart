import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lorofy/core/utils/logger.dart';
import 'package:lorofy/features/auth/presentation/providers/auth_provider.dart';
import 'package:lorofy/features/explore/presentation/providers/explore_stats_provider.dart';
import 'package:lorofy/features/explore/presentation/providers/leaderboard_provider.dart';
import 'package:lorofy/features/focus/presentation/providers/categories_provider.dart';
import 'package:lorofy/features/profile/presentation/providers/activities_provider.dart';
import 'package:lorofy/features/profile/presentation/providers/notifications_provider.dart';
import 'package:lorofy/features/profile/presentation/providers/point_history_provider.dart';

/// Riverpod provider for network connectivity stream
final networkConnectivityProvider = StreamProvider<List<ConnectivityResult>>((ref) {
  return Connectivity().onConnectivityChanged;
});

/// Auto-retry notifier that listens for network restoration (offline -> online)
/// and automatically refreshes all failed data providers across the app!
class NetworkRetryNotifier extends Notifier<bool> {
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  Timer? _debounceTimer;
  @override
  bool build() {
    _checkInitialConnectivity();

    // Listen to continuous connectivity changes
    _subscription = Connectivity().onConnectivityChanged.listen((results) {
      final bool isOffline =
          results.isEmpty || results.every((r) => r == ConnectivityResult.none);

      if (isOffline) {
        AppLogger.info('Internet connection lost (Offline)',
            tag: 'NetworkConnectivity');
      } else {
        // Network interface connected (WiFi / Cellular)
        AppLogger.info(
            'Internet connection detected! Scheduling auto-retries...',
            tag: 'NetworkConnectivity');
        _scheduleRetry();
      }
    });

    ref.onDispose(() {
      _subscription?.cancel();
      _debounceTimer?.cancel();
    });

    return true;
  }

  Future<void> _checkInitialConnectivity() async {
    try {
      final results = await Connectivity().checkConnectivity();
      final bool isOffline =
          results.isEmpty || results.every((r) => r == ConnectivityResult.none);
      if (isOffline) {
        AppLogger.info('App started in Offline state',
            tag: 'NetworkConnectivity');
      }
    } catch (e) {
      AppLogger.error('Failed to check initial connectivity',
          error: e, tag: 'NetworkConnectivity');
    }
  }

  void _scheduleRetry() {
    _debounceTimer?.cancel();

    // Attempt 1: 800ms delay to allow OS socket binding, IP acquisition, and DNS resolution
    _debounceTimer = Timer(const Duration(milliseconds: 800), () {
      AppLogger.info('Auto-retrying failed data requests (Attempt 1)...',
          tag: 'NetworkConnectivity');
      invalidateAllAppProviders();

      // Attempt 2: 2500ms fallback retry for slower network handshakes
      Future.delayed(const Duration(milliseconds: 1700), () {
        AppLogger.info('Auto-retrying failed data requests (Attempt 2)...',
            tag: 'NetworkConnectivity');
        invalidateAllAppProviders();
      });
    });
  }

  /// Invalidate all app data providers and family variants
  void invalidateAllAppProviders() {
    // Leaderboard family variants
    for (final tf in ['TODAY', 'WEEK', 'ALL']) {
      ref.invalidate(leaderboardProvider(timeframe: tf));
    }

    // Filtered activities family variants
    for (final tf in ['ALL', 'TODAY', 'WEEK']) {
      for (final st in ['ALL', 'COMPLETED', 'FAILED']) {
        ref.invalidate(filteredActivitiesProvider(timeframe: tf, status: st));
      }
    }

    ref.invalidate(pointHistoryProvider);
    ref.invalidate(todayActivitiesProvider);
    ref.invalidate(monthActivitiesProvider);
    ref.invalidate(exploreStatsProvider);
    ref.invalidate(focusCategoriesProvider);
    ref.invalidate(notificationsProvider);
    try {
      ref.read(authProvider.notifier).refreshProfile();
    } catch (_) {}
  }
}

final networkRetryNotifierProvider =
    NotifierProvider<NetworkRetryNotifier, bool>(NetworkRetryNotifier.new);
