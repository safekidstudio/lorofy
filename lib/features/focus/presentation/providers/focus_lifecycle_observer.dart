import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:lorofy/core/services/foreground_app_service.dart';
import 'package:lorofy/core/services/notification_service.dart';
import 'package:lorofy/features/focus/domain/enums/block_mode.dart';
import 'package:lorofy/features/focus/domain/models/pomodoro_state.dart';
import 'package:lorofy/features/focus/presentation/providers/pomodoro_notifier.dart';
import 'package:lorofy/features/focus/presentation/providers/pomodoro_settings.dart';

class FocusLifecycleObserver extends ConsumerStatefulWidget {
  final Widget child;
  final int strictGracePeriodSeconds;
  final int mediumGracePeriodSeconds;

  const FocusLifecycleObserver({
    super.key,
    required this.child,
    this.strictGracePeriodSeconds = 10,
    this.mediumGracePeriodSeconds = 20,
  });

  @override
  ConsumerState<FocusLifecycleObserver> createState() => _FocusLifecycleObserverState();
}

class _FocusLifecycleObserverState extends ConsumerState<FocusLifecycleObserver>
    with WidgetsBindingObserver {
  Timer? _gracePeriodTimer;
  Timer? _mediumPeriodicTimer;
  int _unallowedSecondsCounter = 0;
  String? _lastNotifiedStatus;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Initialize notification service
    NotificationService().init();
  }

  @override
  void dispose() {
    _cancelGraceTimer();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _cancelGraceTimer() {
    _gracePeriodTimer?.cancel();
    _gracePeriodTimer = null;
    _mediumPeriodicTimer?.cancel();
    _mediumPeriodicTimer = null;
    _unallowedSecondsCounter = 0;
    _lastNotifiedStatus = null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    final timerState = ref.read(pomodoroTimerProvider);
    if (timerState.phase != PomodoroState.focus) {
      _cancelGraceTimer();
      return;
    }

    final settings = ref.read(pomodoroSettingsProvider);
    final activeBlockMode =
        settings.isDeepFocusMode ? settings.blockMode : BlockMode.medium;

    if (state == AppLifecycleState.paused) {
      _cancelGraceTimer();

      if (activeBlockMode == BlockMode.strict) {
        final seconds = widget.strictGracePeriodSeconds;
        // Strict Mode: Send warning notification and start grace period timer
        NotificationService().showStrictWarningNotification(seconds: seconds);

        _gracePeriodTimer = Timer(Duration(seconds: seconds), () {
          if (mounted) {
            ref.read(pomodoroTimerProvider.notifier).confirmGiveUp();
            NotificationService().showSessionFailedNotification();
          }
        });
      } else if (activeBlockMode == BlockMode.medium) {
        final seconds = widget.mediumGracePeriodSeconds;
        _handleMediumModePaused(seconds, settings.allowedAppPackages);
      }
    } else if (state == AppLifecycleState.resumed) {
      // Return to app within grace period: cancel timer and clear notifications
      _cancelGraceTimer();
      NotificationService().cancelAll();
    }
  }

  Future<void> _handleMediumModePaused(int maxAllowedSeconds, Set<String> allowedPackages) async {
    _cancelGraceTimer();

    final myPackage = (await PackageInfo.fromPlatform()).packageName;
    const intervalSeconds = 2;

    _mediumPeriodicTimer = Timer.periodic(const Duration(seconds: intervalSeconds), (timer) async {
      if (!mounted) {
        _cancelGraceTimer();
        return;
      }

      final timerState = ref.read(pomodoroTimerProvider);
      if (timerState.phase != PomodoroState.focus) {
        _cancelGraceTimer();
        return;
      }

      final fgPackage = await ForegroundAppService().getForegroundAppPackage();

      // Case A: User is in Lorofy OR in a Whitelisted app (e.g. Hive, Spotify)
      if (fgPackage != null && (fgPackage == myPackage || allowedPackages.contains(fgPackage))) {
        _unallowedSecondsCounter = 0;
        _lastNotifiedStatus = 'whitelisted';
        return;
      }

      // Case B: User is on Home Launcher / System UI -> Safe Neutral Zone!
      final isLauncher = fgPackage != null && await ForegroundAppService().isLauncherPackage(fgPackage);
      if (isLauncher) {
        _unallowedSecondsCounter = 0;
        _lastNotifiedStatus = 'launcher';
        return;
      }

      // Case C: User is in an UNALLOWED app (e.g. Facebook, TikTok)
      _unallowedSecondsCounter += intervalSeconds;
      final remainingSeconds = maxAllowedSeconds - _unallowedSecondsCounter;

      if (remainingSeconds <= 0) {
        _cancelGraceTimer();
        ref.read(pomodoroTimerProvider.notifier).confirmGiveUp();
        NotificationService().showSessionFailedNotification(
          title: 'Focus Session Failed',
          body: 'Your focus session failed because you stayed in an unallowed app.',
        );
        return;
      }

      // Send warning notification ONLY ONCE when entering an unallowed app!
      if (_lastNotifiedStatus != 'unallowed') {
        _lastNotifiedStatus = 'unallowed';
        NotificationService().showStrictWarningNotification(
          seconds: maxAllowedSeconds,
          title: 'Warning: Unallowed App Detected! 🥀',
          body: 'Return to Lorofy or your whitelisted apps before your session fails.',
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
