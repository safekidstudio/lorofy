import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:lorofy/components/layout/app_header.dart';
import 'package:lorofy/components/ui/logo.dart';
import 'package:lorofy/components/ui/svg_asset.dart';
import 'package:lorofy/core/theme/app_theme.dart';
import 'package:lorofy/features/focus/domain/models/pomodoro_state.dart';
import 'sound_button.dart';

/// Clean Architecture Header component for QuickStartPage.
class QuickStartHeader extends StatelessWidget {
  final PomodoroState phase;
  final VoidCallback onReset;
  final GlobalKey? settingsKey;

  const QuickStartHeader({
    super.key,
    required this.phase,
    required this.onReset,
    this.settingsKey,
  });

  @override
  Widget build(BuildContext context) {
    return AppHeader(
      leftActions: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: phase == PomodoroState.completed
            ? CupertinoButton(
                key: const ValueKey('close_btn'),
                padding: EdgeInsets.zero,
                onPressed: onReset,
                child: const SVG(
                  'assets/icons/cancel.svg',
                  width: 24,
                  height: 24,
                  color: AppColors.foreground,
                ),
              )
            : const Logo(key: ValueKey('logo_text')),
      ),
      rightActions: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: switch (phase) {
          PomodoroState.idle => CupertinoButton(
            key: settingsKey ?? const ValueKey('settings_btn'),
            padding: EdgeInsets.zero,
            onPressed: () => context.push('/session-settings'),
            child: const SVG(
              'assets/icons/settings_drawing.svg',
              width: 24,
              height: 24,
            ),
          ),
          PomodoroState.giveup => CupertinoButton(
            key: const ValueKey('giveup_close_btn'),
            padding: EdgeInsets.zero,
            onPressed: onReset,
            child: const SVG(
              'assets/icons/cancel.svg',
              width: 24,
              height: 24,
              color: AppColors.foreground,
            ),
          ),
          PomodoroState.completed => const SizedBox.shrink(
            key: ValueKey('empty_right'),
          ),
          _ => const KeyedSubtree(
            key: ValueKey('sound_button'),
            child: SoundButton(),
          ),
        },
      ),
    );
  }
}
