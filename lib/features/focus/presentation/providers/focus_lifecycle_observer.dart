import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lorofy/core/services/notification_service.dart';
import 'package:lorofy/features/focus/domain/enums/block_mode.dart';
import 'package:lorofy/features/focus/domain/models/pomodoro_state.dart';
import 'package:lorofy/features/focus/presentation/providers/pomodoro_notifier.dart';
import 'package:lorofy/features/focus/presentation/providers/pomodoro_settings.dart';

class FocusLifecycleObserver extends ConsumerStatefulWidget {
  final Widget child;

  const FocusLifecycleObserver({super.key, required this.child});

  @override
  ConsumerState<FocusLifecycleObserver> createState() => _FocusLifecycleObserverState();
}

class _FocusLifecycleObserverState extends ConsumerState<FocusLifecycleObserver>
    with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Initialize notification service
    NotificationService().init();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    final timerState = ref.read(pomodoroTimerProvider);
    if (timerState.phase != PomodoroState.focus) {
      return;
    }

    final settings = ref.read(pomodoroSettingsProvider);
    final activeBlockMode =
        settings.isDeepFocusMode ? settings.blockMode : BlockMode.medium;

    if (state == AppLifecycleState.paused) {
      if (activeBlockMode == BlockMode.strict) {
        // Strict Mode: Fail focus session immediately when leaving app
        ref.read(pomodoroTimerProvider.notifier).confirmGiveUp();
        NotificationService().showSessionFailedNotification();
      } else if (activeBlockMode == BlockMode.medium) {
        // Medium Mode: Send reminder notification to return to Lorofy
        NotificationService().showFocusReminderNotification();
      }
    } else if (state == AppLifecycleState.resumed) {
      // Clear notifications when user returns to Lorofy
      NotificationService().cancelAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
