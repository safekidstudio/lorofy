import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lorofy/features/focus/domain/models/pomodoro_state.dart';
import 'package:lorofy/features/focus/domain/models/ambient_sound.dart';
import 'package:lorofy/features/focus/domain/models/ambient_sound_meta.dart';
import 'package:lorofy/features/focus/domain/models/focus_category.dart';
import 'package:lorofy/features/focus/domain/models/pomodoro_settings.dart';
import 'package:lorofy/features/focus/domain/repositories/focus_repository.dart';
import 'package:lorofy/features/focus/data/repositories/focus_repository_impl.dart';
import 'package:lorofy/features/focus/presentation/providers/pomodoro_settings.dart';
import 'package:lorofy/features/focus/domain/enums/block_mode.dart';
import 'package:lorofy/features/mascot/presentation/providers/mascot_notifier.dart';
import 'package:lorofy/features/focus/presentation/providers/music_player_provider.dart';
import 'package:lorofy/features/auth/presentation/providers/auth_provider.dart';
import 'package:lorofy/features/settings/presentation/providers/system_settings_provider.dart';
import 'package:lorofy/features/focus/domain/models/focus_session.dart';
import 'package:lorofy/features/profile/presentation/providers/activities_provider.dart';

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
  final int? currentStreak;
  final bool streakIncreased;

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
    this.currentStreak,
    this.streakIncreased = false,
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
    int? currentStreak,
    bool? streakIncreased,
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
      currentStreak: currentStreak ?? this.currentStreak,
      streakIncreased: streakIncreased ?? this.streakIncreased,
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

  void startFocus(int focusMinutes, {bool force = false}) {
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

    // Start ambient sound if configured
    _playAmbientSound(settings);

    // Call API startSession in the background
    _apiStartSession(focusMinutes, force: force);
  }

  /// Resumes an unfinished session from the server
  void resumeSession({
    required FocusSession session,
    required int remainingSeconds,
  }) {
    _cancelTicker();
    final totalSeconds = session.plannedMinutes * 60;
    _stopwatch = Stopwatch()..start();

    final settings = ref.read(pomodoroSettingsProvider);

    state = state.copyWith(
      phase: PomodoroState.focus,
      totalSessionSeconds: totalSeconds,
      countdownSeconds: remainingSeconds,
      selectedCategory: settings.selectedCategory,
      backendSessionId: session.id,
      earnedPoints: 0,
      earnedCoins: 0,
    );

    _runTicker(PomodoroState.focus, onComplete: _onFocusCompleted);

    // Start ambient sound if configured
    _playAmbientSound(settings);
  }

  void _playAmbientSound(PomodoroSettings settings) {
    if (settings.ambientSound == AmbientSound.none) return;
    ref.read(musicPlayerProvider.notifier).play(settings.ambientSound.toSong());
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

    // Stop ambient sound during break
    ref.read(musicPlayerProvider.notifier).stop();
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

    // Stop ambient sound on give up
    ref.read(musicPlayerProvider.notifier).stop();

    final settings = ref.read(pomodoroSettingsProvider);
    final systemSettings = ref.read(systemSettingsProvider);
    final isStrict =
        !settings.isPomodoroMode && settings.blockMode == BlockMode.strict;
    final penaltyPoints = isStrict
        ? systemSettings.penaltyPointsStrict
        : systemSettings.penaltyPointsMedium;

    final elapsedSeconds = state.totalSessionSeconds - state.countdownSeconds;
    final elapsedMins = (elapsedSeconds / 60).round();

    // Deduct points optimistically ONLY if elapsedSeconds >= 60 or elapsedMins >= 1 (Server Grace Period rule)
    if (elapsedSeconds >= 60 || elapsedMins >= 1) {
      final currentPoints = ref.read(authProvider).rankPoints ?? 0;
      final updatedPoints = (currentPoints - penaltyPoints).clamp(0, 999999).toInt();
      ref.read(authProvider.notifier).updatePointsState(updatedPoints);
    }

    // Call API failSession
    final sessionId = state.backendSessionId;
    if (sessionId != null) {
      try {
        final session = await ref
            .read(focusRepositoryProvider)
            .failSession(
              sessionId: sessionId,
              actualMinutes: elapsedMins,
              failureReason: 'User clicked Give Up',
            );
        state = state.copyWith(earnedPoints: session.earnedPoints);
        // Refresh fresh profile details & rank points from backend
        ref.read(authProvider.notifier).refreshProfile();
        ref.invalidate(filteredActivitiesProvider);
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
    ref.read(musicPlayerProvider.notifier).stop();
    final settings = ref.read(pomodoroSettingsProvider);
    state = PomodoroTimerState(selectedCategory: settings.selectedCategory);
  }

  void restartFocus() {
    final settings = ref.read(pomodoroSettingsProvider);
    state = state.copyWith(currentRound: 1, isLongBreak: false);
    startFocus(settings.focusMinutes);
  }

  Future<void> _apiStartSession(int focusMinutes, {bool force = false}) async {
    try {
      final FocusRepository repository = ref.read(focusRepositoryProvider);
      final settings = ref.read(pomodoroSettingsProvider);
      final activeBlockMode = !settings.isPomodoroMode
          ? settings.blockMode
          : BlockMode.medium;

      FocusSession session;
      try {
        session = await repository.startSession(
          categoryId: state.selectedCategory?.id,
          blockMode: activeBlockMode,
          plannedMinutes: focusMinutes,
          force: force,
        );
      } catch (e) {
        final errStr = e.toString().toLowerCase();
        // When active session conflict is detected (409 Conflict or active session error) and force was not set
        if (!force &&
            (errStr.contains('active focus session') ||
                errStr.contains('in progress') ||
                errStr.contains('conflict') ||
                errStr.contains('409'))) {
          debugPrint(
            'Active session conflict detected on backend. Retrying atomically with force=true...',
          );
          // Automatically force start to supersede old session and create a new one in a single atomic transaction
          session = await repository.startSession(
            categoryId: state.selectedCategory?.id,
            blockMode: activeBlockMode,
            plannedMinutes: focusMinutes,
            force: true,
          );
        } else {
          rethrow;
        }
      }

      if (state.phase == PomodoroState.focus) {
        state = state.copyWith(backendSessionId: session.id);
        debugPrint('Backend session started successfully: ${session.id}');
      }
    } catch (e) {
      debugPrint('Error starting backend session: $e');
    }
  }

  void _runTicker(
    PomodoroState expectedPhase, {
    required VoidCallback onComplete,
  }) {
    _ticker = Timer.periodic(const Duration(milliseconds: 50), (_) {
      if (state.phase != expectedPhase) {
        _ticker?.cancel();
        return;
      }

      final elapsed = (_stopwatch!.elapsedMilliseconds / 1000.0);
      final remaining = (state.totalSessionSeconds - elapsed).clamp(
        0.0,
        state.totalSessionSeconds.toDouble(),
      );
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

  void _onFocusCompleted() async {
    final settings = ref.read(pomodoroSettingsProvider);
    final systemSettings = ref.read(systemSettingsProvider);

    final focusMinutes = (state.totalSessionSeconds / 60).round();
    final isStrict =
        !settings.isPomodoroMode && settings.blockMode == BlockMode.strict;
    final multiplier = isStrict
        ? systemSettings.rewardMultiplierStrict
        : systemSettings.rewardMultiplierMedium;

    final calculatedPoints =
        (focusMinutes * systemSettings.rewardBasePointsPerMin * multiplier).round();
    final calculatedCoins =
        (focusMinutes * systemSettings.rewardBaseCoinsPerMin * multiplier).round();

    // Record daily streak update
    final streakResult = await ref
        .read(authProvider.notifier)
        .recordFocusCompletionStreak();

    // Optimistically set earned points & coins based on settings conversion formula
    state = state.copyWith(
      earnedPoints: calculatedPoints,
      earnedCoins: calculatedCoins,
      currentStreak: streakResult.currentStreak,
      streakIncreased: streakResult.streakIncreased,
    );

    // Call API completeSession
    final sessionId = state.backendSessionId;
    if (sessionId != null) {
      final actualMins = (state.totalSessionSeconds / 60).round();
      ref
          .read(focusRepositoryProvider)
          .completeSession(sessionId, actualMins)
          .then((session) {
            final points = session.earnedPoints;
            final coins = session.earnedCoins;

            state = state.copyWith(
              earnedPoints: points,
              earnedCoins: coins,
            );
            // Add growth points to the active mascot
            ref
                .read(mascotProvider.notifier)
                .addGrowthPoints(points);
            // Sync points in Auth provider
            final currentPoints = ref.read(authProvider).rankPoints ?? 0;
            ref
                .read(authProvider.notifier)
                .updatePointsState(currentPoints + points);

            // Refresh user profile from backend
            ref.read(authProvider.notifier).refreshProfile();
            ref.invalidate(filteredActivitiesProvider);
          })
          .catchError((e) {
            debugPrint('Error completing backend session: $e');
            ref.read(mascotProvider.notifier).addGrowthPoints(calculatedPoints);
            final currentPoints = ref.read(authProvider).rankPoints ?? 0;
            ref
                .read(authProvider.notifier)
                .updatePointsState(currentPoints + calculatedPoints);
          });
    } else {
      ref.read(mascotProvider.notifier).addGrowthPoints(calculatedPoints);
      final currentPoints = ref.read(authProvider).rankPoints ?? 0;
      ref
          .read(authProvider.notifier)
          .updatePointsState(currentPoints + calculatedPoints);
    }

    final targetRounds = settings.isPomodoroMode ? settings.targetRounds : 1;
    if (state.currentRound >= targetRounds) {
      state = state.copyWith(phase: PomodoroState.completed);
      // Stop ambient sound on session completion
      ref.read(musicPlayerProvider.notifier).stop();
    } else {
      final breakMinutes = settings.isPomodoroMode ? settings.breakMinutes : 0;
      startBreak(breakMinutes, isLong: false);
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
    NotifierProvider<PomodoroNotifier, PomodoroTimerState>(
      PomodoroNotifier.new,
    );
