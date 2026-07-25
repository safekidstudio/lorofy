import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lorofy/features/home/domain/pomodoro_state.dart';
import 'package:lorofy/features/home/presentation/providers/pomodoro_settings.dart';

// ---------------------------------------------------------------------------
// Immutable state
// ---------------------------------------------------------------------------

class PomodoroTimerState {
  final PomodoroState phase;
  final int countdownSeconds;
  final int totalSessionSeconds;
  final int currentRound;
  final bool isLongBreak;

  const PomodoroTimerState({
    this.phase = PomodoroState.idle,
    this.countdownSeconds = 60,
    this.totalSessionSeconds = 60,
    this.currentRound = 1,
    this.isLongBreak = false,
  });

  PomodoroTimerState copyWith({
    PomodoroState? phase,
    int? countdownSeconds,
    int? totalSessionSeconds,
    int? currentRound,
    bool? isLongBreak,
  }) {
    return PomodoroTimerState(
      phase: phase ?? this.phase,
      countdownSeconds: countdownSeconds ?? this.countdownSeconds,
      totalSessionSeconds: totalSessionSeconds ?? this.totalSessionSeconds,
      currentRound: currentRound ?? this.currentRound,
      isLongBreak: isLongBreak ?? this.isLongBreak,
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

    state = state.copyWith(
      phase: PomodoroState.focus,
      totalSessionSeconds: totalSeconds,
      countdownSeconds: totalSeconds,
    );

    _runTicker(PomodoroState.focus, onComplete: _onFocusCompleted);
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
  void pauseTicker() {
    _ticker?.cancel();
    _stopwatch?.stop();
  }

  /// Resumes the ticker after the give-up sheet is dismissed without confirming.
  void resumeFocusTicker() {
    _stopwatch?.start();
    _runTicker(PomodoroState.focus, onComplete: _onFocusCompleted);
  }

  void confirmGiveUp() {
    _cancelTicker();
    state = state.copyWith(phase: PomodoroState.giveup);
  }

  void skipBreak() {
    _cancelTicker();
    _onBreakCompleted();
  }

  void resetToIdle() {
    _cancelTicker();
    state = const PomodoroTimerState();
  }

  void restartFocus() {
    final settings = ref.read(pomodoroSettingsProvider);
    state = state.copyWith(currentRound: 1, isLongBreak: false);
    startFocus(settings.focusMinutes);
  }

  // ── Private helpers ─────────────────────────────────────────────────────

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
