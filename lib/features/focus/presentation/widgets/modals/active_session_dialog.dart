import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lorofy/features/focus/domain/models/current_session.dart';
import 'package:lorofy/features/focus/presentation/providers/pomodoro_notifier.dart';

void showActiveSessionDialog({
  required BuildContext context,
  required WidgetRef ref,
  required CurrentSession activeState,
}) {
  final session = activeState.session;
  if (session == null) return;

  final remainingMinutes = (activeState.remainingSeconds / 60).ceil();

  showCupertinoDialog(
    context: context,
    builder: (ctx) => CupertinoAlertDialog(
      title: const Text('Unfinished Focus Session'),
      content: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Text(
          'You have an active ${session.plannedMinutes}-minute focus session in progress (approx. $remainingMinutes min remaining). Would you like to resume?',
        ),
      ),
      actions: [
        CupertinoDialogAction(
          isDestructiveAction: true,
          onPressed: () {
            Navigator.of(ctx).pop();
            // User chose to discard previous session: subsequent Start will send force=true
          },
          child: const Text('Discard'),
        ),
        CupertinoDialogAction(
          isDefaultAction: true,
          onPressed: () {
            Navigator.of(ctx).pop();
            // Restore timer and resume focus session
            ref.read(pomodoroTimerProvider.notifier).resumeSession(
                  session: session,
                  remainingSeconds: activeState.remainingSeconds,
                );
          },
          child: const Text('Resume'),
        ),
      ],
    ),
  );
}
