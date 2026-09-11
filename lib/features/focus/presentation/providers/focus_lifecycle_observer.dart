import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lorofy/core/services/notification_service.dart';
import 'package:lorofy/features/focus/domain/enums/block_mode.dart';
import 'package:lorofy/features/focus/domain/models/pomodoro_state.dart';
import 'package:lorofy/features/focus/presentation/providers/pomodoro_notifier.dart';
import 'package:lorofy/features/focus/presentation/providers/pomodoro_settings.dart';

class FocusLifecycleObserver extends ConsumerStatefulWidget {
  final Widget child;
  final int strictGracePeriodSeconds;

  const FocusLifecycleObserver({
    super.key,
    required this.child,
    this.strictGracePeriodSeconds = 10,
  });

  @override
  ConsumerState<FocusLifecycleObserver> createState() => _FocusLifecycleObserverState();
}

class _FocusLifecycleObserverState extends ConsumerState<FocusLifecycleObserver>
    with WidgetsBindingObserver {
  Timer? _gracePeriodTimer;

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

      final seconds = widget.strictGracePeriodSeconds;

      if (activeBlockMode == BlockMode.strict) {
        // Strict Mode: Send warning notification and start grace period timer
        NotificationService().showStrictWarningNotification(seconds: seconds);

        _gracePeriodTimer = Timer(Duration(seconds: seconds), () {
          if (mounted) {
            ref.read(pomodoroTimerProvider.notifier).confirmGiveUp();
            NotificationService().showSessionFailedNotification();
          }
        });
      } else if (activeBlockMode == BlockMode.medium) {
        // Medium Mode (Whitelist): Send warning notification with whitelisted app count
        final allowedCount = settings.allowedAppPackages.length;
        final String bodyText = allowedCount > 0
            ? 'You have $seconds seconds to return to Lorofy or whitelisted apps ($allowedCount allowed).'
            : 'You have $seconds seconds to return to Lorofy before your session fails.';

        NotificationService().showStrictWarningNotification(
          seconds: seconds,
          title: 'Focus Session Active (Whitelist Mode)',
          body: bodyText,
        );

        _gracePeriodTimer = Timer(Duration(seconds: seconds), () {
          if (mounted) {
            ref.read(pomodoroTimerProvider.notifier).confirmGiveUp();
            NotificationService().showSessionFailedNotification(
              title: 'Focus Session Failed',
              body: 'Your focus session failed because you stayed outside of Lorofy.',
            );
          }
        });
      }
    } else if (state == AppLifecycleState.resumed) {
      // Return to app within grace period: cancel timer and clear notifications
      _cancelGraceTimer();
      NotificationService().cancelAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
