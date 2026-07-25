import 'package:flutter/cupertino.dart';
import 'package:lorofy/core/theme/app_theme.dart';
import 'package:lorofy/features/home/domain/pomodoro_state.dart';

/// Displays the description text and countdown timer appropriate for the
/// current [pomodoroState].
class PomodoroTimerDisplay extends StatelessWidget {
  final PomodoroState pomodoroState;
  final int displaySeconds;
  final int currentRound;
  final int targetRounds;
  final bool isLongBreak;

  const PomodoroTimerDisplay({
    super.key,
    required this.pomodoroState,
    required this.displaySeconds,
    required this.currentRound,
    required this.targetRounds,
    required this.isLongBreak,
  });

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    switch (pomodoroState) {
      case PomodoroState.completed:
        return const Column(
          key: ValueKey('complete_text'),
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Wow!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTextStyles.titleFontFamily,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF232321),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'The plant has grown up',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF8E8E93),
              ),
            ),
          ],
        );

      case PomodoroState.giveup:
        return const Column(
          key: ValueKey('giveup_text'),
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Oh no, your plant is dead',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00160A),
              ),
            ),
            SizedBox(height: 50), // height anchor to prevent layout jump
          ],
        );

      case PomodoroState.focus:
      case PomodoroState.breakTime:
        final description = pomodoroState == PomodoroState.focus
            ? 'Plant is growing..'
            : isLongBreak
            ? 'Time for a long rest.\nJust let it continue to rest.'
            : "This plant hasn't fully recovered yet.\nJust let it continue to rest.";

        return Column(
          key: const ValueKey('active_text'),
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 42,
              child: Center(
                child: Text(
                  description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF232321),
                    height: 1.3,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _formatDuration(displaySeconds),
              style: const TextStyle(
                fontFamily: AppTextStyles.titleFontFamily,
                fontSize: 54,
                fontWeight: FontWeight.w900,
                color: Color(0xFF232321),
                letterSpacing: 1.2,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ],
        );

      case PomodoroState.idle:
        return const SizedBox.shrink(key: ValueKey('idle_text'));
    }
  }
}
