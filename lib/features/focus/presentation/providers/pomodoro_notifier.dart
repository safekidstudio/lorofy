import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lorofy/features/focus/domain/models/pomodoro_state.dart';
import 'package:lorofy/features/focus/presentation/providers/pomodoro_settings.dart';
import 'package:lorofy/features/focus/domain/enums/block_mode.dart';
import 'package:lorofy/features/focus/data/models/focus_category.dart';
import 'package:lorofy/features/focus/data/repositories/focus_repository.dart';
import 'package:lorofy/features/mascot/presentation/providers/mascot_notifier.dart';

// ---------------------------------------------------------------------------
// Immutable state
// ---------------------------------------------------------------------------

class PomodoroTimerState {
  final PomodoroState phase;
  final int countdownSeconds;
  final int totalSessionSeconds;
  final int currentRound;
  final bool isLongBreak;
  final String? backendSessionId;
  final FocusCategory? selectedCategory;
  final int? earnedPoints;
  final int? earnedCoins;

  const PomodoroTimerState({
    this.phase = PomodoroState.idle,
    this.countdownSeconds = 60,
    this.totalSessionSeconds = 60,
    this.currentRound = 1,
    this.isLongBreak = false,
    this.backendSessionId,
    this.selectedCategory,
    this.earnedPoints,
    this.earnedCoins,
  });

  PomodoroTimerState copyWith({
    PomodoroState? phase,
    int? countdownSeconds,
    int? totalSessionSeconds,
    int? currentRound,
    bool? isLongBreak,
    String? backendSessionId,
    FocusCategory? selectedCategory,
    int? earnedPoints,
    int? earnedCoins,
  }) {
    return PomodoroTimerState(
      phase: phase ?? this.phase,
      countdownSeconds: countdownSeconds ?? this.countdownSeconds,
      totalSessionSeconds: totalSessionSeconds ?? this.totalSessionSeconds,
      currentRound: currentRound ?? this.currentRound,
      isLongBreak: isLongBreak ?? this.isLongBreak,
      backendSessionId: backendSessionId ?? this.backendSessionId,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      earnedPoints: earnedPoints ?? this.earnedPoints,
      earnedCoins: earnedCoins ?? this.earnedCoins,
    );
  }

  /// Progress ratio [0.0, 1.0] of elapsed time in the current session.
  double get progressRatio {
    if (totalSessionSeconds == 0) return 0.0;
    final elapsed = totalSessionSeconds - countdownSeconds;
    return (elapsed / totalSessionSeconds).clamp(0.0, 1.0);
  }
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

class PomodoroNotifier extends Notifier<PomodoroTimerState> {
  Timer? _ticker;
  Stopwatch? _stopwatch;

  @override
  PomodoroTimerState build() => const PomodoroTimerState();

  // ── Public API ──────────────────────────────────────────────────────────

  void startFocus(int focusMinutes) {
    _cancelTicker();
    final totalSeconds = focusMinutes * 60;
    _stopwatch = Stopwatch()..start();

    final settings = ref.read(pomodoroSettingsProvider);

    state = state.copyWith(
      phase: PomodoroState.focus,
      totalSessionSeconds: totalSeconds,
      countdownSeconds: totalSeconds,
      selectedCategory: settings.selectedCategory,
      backendSessionId: null,
      earnedPoints: 0,
      earnedCoins: 0,
    );

    _runTicker(PomodoroState.focus, onComplete: _onFocusCompleted);

    // Call API startSession in the background
    _apiStartSession(focusMinutes);
  }

  void startBreak(int breakMinutes, {required bool isLong}) {
    _cancelTicker();
    final totalSeconds = breakMinutes * 60;
    _stopwatch = Stopwatch()..start();

    state = state.copyWith(
      phase: PomodoroState.breakTime,
      totalSessionSeconds: totalSeconds,
      countdownSeconds: totalSeconds,
      isLongBreak: isLong,
    );

    _runTicker(PomodoroState.breakTime, onComplete: _onBreakCompleted);
  }

  /// Pauses the ticker (used while the give-up sheet is open).
  void pauseTicker() async {
    _ticker?.cancel();
    _stopwatch?.stop();

    // Call API pauseSession
    final sessionId = state.backendSessionId;
    if (sessionId != null) {
      try {
        await ref.read(focusRepositoryProvider).pauseSession(sessionId);
      } catch (e) {
        debugPrint('Error pausing backend session: $e');
      }
    }
  }

  /// Resumes the ticker after the give-up sheet is dismissed without confirming.
  void resumeFocusTicker() {
    _stopwatch?.start();
    _runTicker(PomodoroState.focus, onComplete: _onFocusCompleted);
  }

  void confirmGiveUp() async {
    _cancelTicker();
    state = state.copyWith(phase: PomodoroState.giveup);

    // Call API failSession
    final sessionId = state.backendSessionId;
    if (sessionId != null) {
      final elapsedSeconds = state.totalSessionSeconds - state.countdownSeconds;
      final elapsedMins = (elapsedSeconds / 60).round();
      try {
        await ref.read(focusRepositoryProvider).failSession(
          sessionId: sessionId,
          actualMinutes: elapsedMins,
          failureReason: 'User clicked Give Up',
        );
      } catch (e) {
        debugPrint('Error failing backend session: $e');
      }
    }
  }

  void skipBreak() {
    _cancelTicker();
    _onBreakCompleted();
  }

  void resetToIdle() {
    _cancelTicker();
    final settings = ref.read(pomodoroSettingsProvider);
    state = PomodoroTimerState(
      selectedCategory: settings.selectedCategory,
    );
  }

  void restartFocus() {
    final settings = ref.read(pomodoroSettingsProvider);
    state = state.copyWith(currentRound: 1, isLongBreak: false);
    startFocus(settings.focusMinutes);
  }

  Future<void> _apiStartSession(int focusMinutes) async {
    try {
      final repository = ref.read(focusRepositoryProvider);
      final settings = ref.read(pomodoroSettingsProvider);
      final activeBlockMode = settings.isDeepFocusMode ? settings.blockMode : BlockMode.MEDIUM;
      final session = await repository.startSession(
        categoryId: state.selectedCategory?.id,
        blockMode: activeBlockMode,
        plannedMinutes: focusMinutes,
      );
      if (state.phase == PomodoroState.focus) {
        state = state.copyWith(backendSessionId: session.id);
      }
    } catch (e) {
      debugPrint('Error starting backend session: $e');
    }
  }

  void _runTicker(PomodoroState expectedPhase, {required VoidCallback onComplete}) {
    _ticker = Timer.periodic(const Duration(milliseconds: 50), (_) {
      if (state.phase != expectedPhase) {
        _ticker?.cancel();
        return;
      }

      final elapsed = (_stopwatch!.elapsedMilliseconds / 1000.0);
      final remaining = (state.totalSessionSeconds - elapsed).clamp(0.0, state.totalSessionSeconds.toDouble());
      final newCountdown = remaining.ceil();

      if (newCountdown != state.countdownSeconds) {
        state = state.copyWith(countdownSeconds: newCountdown);
      }

      if (elapsed >= state.totalSessionSeconds) {
        _stopwatch!.stop();
        _ticker?.cancel();
        onComplete();
      }
    });
  }

  void _onFocusCompleted() {
    final settings = ref.read(pomodoroSettingsProvider);

    // Call API completeSession
    final sessionId = state.backendSessionId;
    if (sessionId != null) {
      final actualMins = (state.totalSessionSeconds / 60).round();
      ref.read(focusRepositoryProvider).completeSession(sessionId, actualMins).then((session) {
        state = state.copyWith(
          earnedPoints: session.earnedPoints,
          earnedCoins: session.earnedCoins,
        );
        // Add growth points to the active mascot
        ref.read(mascotProvider.notifier).addGrowthPoints(session.earnedPoints);
      }).catchError((e) {
        debugPrint('Error completing backend session: $e');
      });
    }

    if (state.currentRound >= settings.targetRounds) {
      state = state.copyWith(phase: PomodoroState.completed);
    } else {
      startBreak(settings.breakMinutes, isLong: false);
    }
  }

  void _onBreakCompleted() {
    final settings = ref.read(pomodoroSettingsProvider);
    if (state.isLongBreak) {
      resetToIdle();
    } else {
      state = state.copyWith(
        currentRound: state.currentRound + 1,
        isLongBreak: false,
      );
      startFocus(settings.focusMinutes);
    }
  }

  void _cancelTicker() {
    _ticker?.cancel();
    _stopwatch?.stop();
    _stopwatch = null;
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final pomodoroTimerProvider =
    NotifierProvider<PomodoroNotifier, PomodoroTimerState>(PomodoroNotifier.new);

