import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smooth_sheets/smooth_sheets.dart';
import 'package:lorofy/components/ui/app_header.dart';
import 'package:lorofy/components/ui/logo.dart';
import 'package:lorofy/components/ui/svg_asset.dart';
import 'package:lorofy/components/ui/toast.dart';
import 'package:lorofy/features/home/domain/pomodoro_state.dart';
import 'package:lorofy/features/home/presentation/providers/pomodoro_notifier.dart';
import 'package:lorofy/features/home/presentation/providers/pomodoro_settings.dart';
import 'package:lorofy/features/home/presentation/pages/pomodoro_settings_page.dart';
import 'package:lorofy/features/home/presentation/widgets/pomodoro_action_buttons.dart';
import 'package:lorofy/features/home/presentation/widgets/pomodoro_giveup_confirmation_sheet.dart';
import 'package:lorofy/features/home/presentation/widgets/pomodoro_plant_graphic.dart';
import 'package:lorofy/features/home/presentation/widgets/pomodoro_timer_display.dart';
import 'package:rive/rive.dart' hide LinearGradient, Image;

class QuickStartPage extends ConsumerWidget {
  final double pageOffset;
  final double pageValue;
  final ValueChanged<bool> onFocusStateChanged;

  const QuickStartPage({
    super.key,
    required this.pageOffset,
    required this.pageValue,
    required this.onFocusStateChanged,
  });

  // ── Navigation helpers ──────────────────────────────────────────────────

  Future<void> _handleGiveUp(BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(pomodoroTimerProvider.notifier);
    notifier.pauseTicker();

    final confirmed = await Navigator.push<bool>(
      context,
      ModalSheetRoute(
        builder: (context) => Sheet(
          decoration: const MaterialSheetDecoration(
            size: SheetSize.fit,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
            color: CupertinoColors.white,
          ),
          child: const PomodoroGiveupConfirmationSheet(),
        ),
      ),
    );

    if (confirmed == true) {
      notifier.confirmGiveUp();
      onFocusStateChanged(true);
    } else {
      notifier.resumeFocusTicker();
    }
  }

  // ── Header builder ──────────────────────────────────────────────────────

  Widget _buildHeader(
    BuildContext context,
    WidgetRef ref,
    PomodoroState phase,
    VoidCallback onReset,
  ) {
    return AppHeader(
      leftActions: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: phase == PomodoroState.completed
            ? CupertinoButton(
                key: const ValueKey('close_btn'),
                padding: EdgeInsets.zero,
                onPressed: onReset,
                child: const Icon(CupertinoIcons.xmark, color: Color(0xFF232321), size: 24),
              )
            : const Logo(key: ValueKey('logo_text'), fontSize: 32),
      ),
      rightActions: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: switch (phase) {
          PomodoroState.idle => CupertinoButton(
              key: const ValueKey('settings_btn'),
              padding: EdgeInsets.zero,
              onPressed: () => Navigator.of(context).push(
                CupertinoPageRoute(builder: (_) => const PomodoroSettingsPage()),
              ),
              child: const SVG('assets/icons/settings_drawing.svg', width: 32, height: 32),
            ),
          PomodoroState.giveup => CupertinoButton(
              key: const ValueKey('giveup_close_btn'),
              padding: EdgeInsets.zero,
              onPressed: onReset,
              child: const Icon(CupertinoIcons.multiply, color: Color(0xFF232321), size: 24),
            ),
          PomodoroState.completed =>
            const SizedBox.shrink(key: ValueKey('empty_right')),
          _ => KeyedSubtree(
              key: const ValueKey('music_pill'),
              child: _MusicPill(),
            ),
        },
      ),
    );
  }

  // ── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(pomodoroTimerProvider);
    final settings = ref.watch(pomodoroSettingsProvider);
    final notifier = ref.read(pomodoroTimerProvider.notifier);
    final phase = timerState.phase;

    final double opacity = (1.0 - pageValue * 2.5).clamp(0.0, 1.0);

    final int displaySeconds = (phase == PomodoroState.focus || phase == PomodoroState.breakTime)
        ? timerState.countdownSeconds
        : settings.focusMinutes * 60;

    void onReset() {
      notifier.resetToIdle();
      onFocusStateChanged(false);
    }

    // Sync focus lock state whenever phase changes
    ref.listen(pomodoroTimerProvider.select((s) => s.phase), (_, next) {
      onFocusStateChanged(next != PomodoroState.idle);
    });

    return Opacity(
      opacity: opacity,
      child: Stack(
        children: [
          // ── Confetti background (completed state only) ──
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedOpacity(
                opacity: phase == PomodoroState.completed ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
                child: phase == PomodoroState.completed
                    ? const RiveAnimation.asset('assets/river/confetti.riv', fit: BoxFit.cover)
                    : const SizedBox.shrink(),
              ),
            ),
          ),

          // ── Main layout ──
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 16),

                  // Header
                  _buildHeader(context, ref, phase, onReset),

                  // Plant + timer + buttons — all centered as one block
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Plant graphic (self-manages Rive state)
                          PomodoroPlantGraphic(
                            pomodoroState: phase,
                            growthRatio: timerState.progressRatio,
                            parallaxOffset: pageOffset,
                          ),

                          const SizedBox(height: 24),

                          // Timer / description text
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: PomodoroTimerDisplay(
                              key: ValueKey(phase),
                              pomodoroState: phase,
                              displaySeconds: displaySeconds,
                              currentRound: timerState.currentRound,
                              targetRounds: settings.targetRounds,
                              isLongBreak: timerState.isLongBreak,
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Action buttons
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: PomodoroActionButtons(
                              key: ValueKey(phase),
                              pomodoroState: phase,
                              onStart: () {
                                notifier.startFocus(settings.focusMinutes);
                                onFocusStateChanged(true);
                              },
                              onGiveUp: () => _handleGiveUp(context, ref),
                              onSkip: () {
                                notifier.skipBreak();
                                AppToast.show(
                                  context,
                                  message: 'Break skipped! Starting next round... 🌿',
                                  type: ToastType.info,
                                );
                              },
                              onRest: onReset,
                              onRestart: () {
                                notifier.restartFocus();
                                onFocusStateChanged(true);
                              },
                              onHome: onReset,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 80), // space for "swipe to explore"
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Local widget — Music pill (only used in this page)
// ---------------------------------------------------------------------------

class _MusicPill extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => AppToast.show(context, message: 'Music player coming soon! 🎵'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFE5E5EA).withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Click to change music',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF8E8E93)),
            ),
            SizedBox(width: 6),
            Icon(CupertinoIcons.music_note_2, color: Color(0xFF232321), size: 14),
          ],
        ),
      ),
    );
  }
}
