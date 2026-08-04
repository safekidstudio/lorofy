import 'package:flutter/cupertino.dart';
import 'package:lorofy/components/ui/button.dart';
import 'package:lorofy/features/focus/domain/models/pomodoro_state.dart';

/// Renders the correct action button group for the current [pomodoroState].
class PomodoroActionButtons extends StatelessWidget {
  final PomodoroState pomodoroState;
  final VoidCallback onStart;
  final VoidCallback onGiveUp;
  final VoidCallback onSkip;
  final VoidCallback onRest;
  final VoidCallback onRestart;
  final VoidCallback onHome;

  const PomodoroActionButtons({
    super.key,
    required this.pomodoroState,
    required this.onStart,
    required this.onGiveUp,
    required this.onSkip,
    required this.onRest,
    required this.onRestart,
    required this.onHome,
  });

  @override
  Widget build(BuildContext context) {
    switch (pomodoroState) {
      case PomodoroState.idle:
        return SizedBox(
          key: const ValueKey('idle_btn'),
          width: 146,
          child: Button.primary(text: 'Start', onPressed: onStart),
        );

      case PomodoroState.focus:
        return SizedBox(
          key: const ValueKey('focus_btn'),
          width: 146,
          child: Button.secondary(text: 'Give up', onPressed: onGiveUp),
        );

      case PomodoroState.breakTime:
        return SizedBox(
          key: const ValueKey('break_btn'),
          width: 146,
          child: Button.secondary(text: 'Skip', onPressed: onSkip),
        );

      case PomodoroState.completed:
        return SizedBox(
          key: const ValueKey('completed_btn'),
          width: 146,
          child: Button.secondary(text: 'Have a rest', onPressed: onRest),
        );

      case PomodoroState.giveup:
        return Column(
          key: const ValueKey('giveup_btn'),
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 146,
              child: Button.secondary(
                text: 'Restart',
                prefix: const Icon(
                  CupertinoIcons.refresh,
                  size: 16,
                  color: Color(0xFF232321),
                ),
                onPressed: onRestart,
              ),
            ),
            const SizedBox(height: 16),
            Button.link(text: 'Back to home', onPressed: onHome),
          ],
        );
    }
  }
}
