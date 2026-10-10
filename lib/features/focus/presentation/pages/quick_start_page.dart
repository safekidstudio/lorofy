import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smooth_sheets/smooth_sheets.dart';
import 'package:lorofy/components/ui/toast.dart';
import 'package:lorofy/features/focus/domain/models/pomodoro_state.dart';
import 'package:lorofy/features/focus/presentation/providers/pomodoro_notifier.dart';
import 'package:lorofy/features/focus/presentation/providers/pomodoro_settings.dart';
import 'package:lorofy/features/focus/presentation/providers/categories_provider.dart';
import 'package:lorofy/features/focus/presentation/pages/pomodoro_complete_page.dart';
import 'package:lorofy/features/focus/presentation/pages/pomodoro_giveup_page.dart';
import 'package:lorofy/features/focus/presentation/widgets/timer/quick_start_header.dart';
import 'package:lorofy/features/focus/presentation/widgets/timer/pomodoro_action_buttons.dart';
import 'package:lorofy/features/focus/presentation/widgets/modals/pomodoro_giveup_confirmation_sheet.dart';
import 'package:lorofy/features/focus/presentation/widgets/timer/pomodoro_timer_display.dart';
import 'package:lorofy/features/focus/presentation/widgets/timer/swipe_to_explore_nudge.dart';
import 'package:lorofy/features/mascot/presentation/providers/mascot_notifier.dart';
import 'package:lorofy/features/mascot/presentation/widgets/mascot_graphic.dart';
import 'package:lorofy/features/auth/presentation/providers/auth_provider.dart';

import 'package:lorofy/core/storage/settings_storage.dart';
import 'package:lorofy/features/focus/presentation/widgets/timer/first_time_coachmark_overlay.dart';
import 'package:flutter/foundation.dart';

class QuickStartPage extends ConsumerStatefulWidget {
  final ValueChanged<bool> onFocusStateChanged;
  final VoidCallback? onExploreTap;
  final ValueListenable<bool>? isFullyVisibleListenable;

  const QuickStartPage({
    super.key,
    required this.onFocusStateChanged,
    this.onExploreTap,
    this.isFullyVisibleListenable,
  });

  @override
  ConsumerState<QuickStartPage> createState() => _QuickStartPageState();
}

class _QuickStartPageState extends ConsumerState<QuickStartPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final GlobalKey _settingsKey = GlobalKey();
  final GlobalKey _startKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final storage = ref.read(settingsStorageProvider);
      if (!storage.isFirstTourCompleted()) {
        Future.delayed(const Duration(milliseconds: 2500), () {
          if (mounted) {
            showFirstTimeCoachmarkTour(
              context: context,
              settingsKey: _settingsKey,
              startButtonKey: _startKey,
              onFinish: () {
                ref.read(settingsStorageProvider).setFirstTourCompleted(true);
              },
            );
          }
        });
      }
    });
  }

  // ── Navigation & Sheet Helpers ─────────────────────────────────────────

  Future<void> _handleGiveUp(BuildContext context, WidgetRef ref) async {
    HapticFeedback.mediumImpact();
    final notifier = ref.read(pomodoroTimerProvider.notifier);
    notifier.pauseTicker();

    final confirmed = await Navigator.push<bool>(
      context,
      ModalSheetRoute(
        swipeDismissible: true,
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
      widget.onFocusStateChanged(true);
    } else {
      notifier.resumeFocusTicker();
    }
  }

  // ── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    super.build(context); // Keep the state alive via mixin

    final phase = ref.watch(pomodoroTimerProvider.select((s) => s.phase));
    final settings = ref.watch(pomodoroSettingsProvider);
    final notifier = ref.read(pomodoroTimerProvider.notifier);

    // Automatically select the first category as default if none is selected
    ref.watch(focusCategoriesProvider).whenData((categories) {
      if (categories.isNotEmpty && settings.selectedCategory == null) {
        Future.microtask(() {
          ref
              .read(pomodoroSettingsProvider.notifier)
              .updateSettings(
                settings.copyWith(selectedCategory: categories.first),
              );
        });
      }
    });

    void onReset() {
      HapticFeedback.lightImpact();
      notifier.resetToIdle();
      widget.onFocusStateChanged(false);
    }

    // Sync focus lock state whenever phase changes
    ref.listen(pomodoroTimerProvider.select((s) => s.phase), (_, next) {
      widget.onFocusStateChanged(next != PomodoroState.idle);
    });

    Widget currentScreen;
    if (phase == PomodoroState.completed) {
      final userProfileStreak = ref.watch(authProvider).userProfile?.currentStreak ?? 0;
      final timerState = ref.read(pomodoroTimerProvider);
      currentScreen = PomodoroCompletePage(
        key: const ValueKey('completed_page'),
        onBackToHome: onReset,
        onHaveARest: onReset,
        earnedPoints: timerState.earnedPoints ?? 0,
        earnedCoins: timerState.earnedCoins ?? 0,
        currentStreak: timerState.currentStreak ?? userProfileStreak,
        streakIncreased: timerState.streakIncreased,
      );
    } else if (phase == PomodoroState.giveup) {
      currentScreen = PomodoroGiveupPage(
        key: const ValueKey('giveup_page'),
        onBackToHome: onReset,
        onRestart: () {
          HapticFeedback.mediumImpact();
          notifier.restartFocus();
          widget.onFocusStateChanged(true);
        },
      );
    } else {
      currentScreen = SafeArea(
        key: const ValueKey('active_page'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Modular Clean Header
            QuickStartHeader(
              phase: phase,
              onReset: onReset,
              settingsKey: _settingsKey,
            ),

            // Main focus content (Mascot + Timer + Action buttons)
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // 1. Mascot Graphic
                            Consumer(
                              builder: (context, ref, child) {
                                final mascotState = ref.watch(mascotProvider);
                                final activeMascot = mascotState.activeMascot;
                                if (activeMascot == null) {
                                  return const SizedBox.shrink();
                                }
                                final focusProgressRatio = ref.watch(
                                  pomodoroTimerProvider.select(
                                    (s) => s.progressRatio,
                                  ),
                                );
                                return MascotGraphic(
                                  mascot: activeMascot,
                                  isFocusing: phase == PomodoroState.focus,
                                  focusProgressRatio: focusProgressRatio,
                                );
                              },
                            ),

                            const SizedBox(height: 24),

                            // 2. Pomodoro Timer Display (Isolated tick rebuilds)
                            Consumer(
                              builder: (context, ref, child) {
                                final timerState = ref.watch(pomodoroTimerProvider);
                                final int displaySeconds =
                                    (phase == PomodoroState.focus ||
                                            phase == PomodoroState.breakTime)
                                        ? timerState.countdownSeconds
                                        : settings.focusMinutes * 60;

                                return AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 400),
                                  transitionBuilder:
                                      (Widget child, Animation<double> animation) {
                                        return FadeTransition(
                                          opacity: animation,
                                          child: SlideTransition(
                                            position:
                                                Tween<Offset>(
                                                  begin: const Offset(0.0, 0.15),
                                                  end: Offset.zero,
                                                ).animate(
                                                  CurvedAnimation(
                                                    parent: animation,
                                                    curve: Curves.easeOutBack,
                                                  ),
                                                ),
                                            child: child,
                                          ),
                                        );
                                      },
                                  child: PomodoroTimerDisplay(
                                    key: ValueKey(phase),
                                    pomodoroState: phase,
                                    displaySeconds: displaySeconds,
                                    currentRound: timerState.currentRound,
                                    targetRounds: settings.isPomodoroMode
                                        ? settings.targetRounds
                                        : 1,
                                    isLongBreak: timerState.isLongBreak,
                                  ),
                                );
                              },
                            ),

                            const SizedBox(height: 32),

                            // 3. Pomodoro Action Buttons
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 400),
                              transitionBuilder:
                                  (Widget child, Animation<double> animation) {
                                    return FadeTransition(
                                      opacity: animation,
                                      child: ScaleTransition(
                                        scale: Tween<double>(begin: 0.9, end: 1.0)
                                            .animate(
                                              CurvedAnimation(
                                                parent: animation,
                                                curve: Curves.easeOutBack,
                                              ),
                                            ),
                                        child: child,
                                      ),
                                    );
                                  },
                              child: PomodoroActionButtons(
                                key: ValueKey(phase),
                                pomodoroState: phase,
                                startButtonKey: _startKey,
                                onStart: () {
                                  HapticFeedback.mediumImpact();
                                  notifier.startFocus(settings.focusMinutes);
                                  widget.onFocusStateChanged(true);
                                },
                                onGiveUp: () => _handleGiveUp(context, ref),
                                onSkip: () {
                                  HapticFeedback.lightImpact();
                                  notifier.skipBreak();
                                  AppToast.show(
                                    context,
                                    message: 'Break skipped! Starting next round... 🌿',
                                    type: ToastType.info,
                                  );
                                },
                                onRest: onReset,
                                onRestart: () {
                                  HapticFeedback.mediumImpact();
                                  notifier.restartFocus();
                                  widget.onFocusStateChanged(true);
                                },
                                onHome: onReset,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // 4. Swipe to explore nudge at bottom (only in idle state AND when 100% fully visible)
            if (phase == PomodoroState.idle && widget.onExploreTap != null)
              ValueListenableBuilder<bool>(
                valueListenable: widget.isFullyVisibleListenable ?? ValueNotifier<bool>(true),
                builder: (context, isVisible, child) {
                  return AnimatedOpacity(
                    duration: const Duration(milliseconds: 180),
                    opacity: isVisible ? 1.0 : 0.0,
                    child: child,
                  );
                },
                child: SwipeToExploreNudge(onTap: widget.onExploreTap),
              )
            else
              const SizedBox(height: 24),
          ],
        ),
      );
    }

    final mainContent = AnimatedSwitcher(
      duration: const Duration(milliseconds: 450),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
        return Stack(
          alignment: Alignment.topCenter,
          fit: StackFit.expand,
          children: <Widget>[
            ...previousChildren,
            ?currentChild,
          ],
        );
      },
      transitionBuilder: (Widget child, Animation<double> animation) {
        final Key? key = child.key;
        final bool isTargetPage = key == const ValueKey('completed_page') ||
            key == const ValueKey('giveup_page');

        final curveAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );

        if (isTargetPage) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 0.15),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutBack,
              ),
            ),
            child: FadeTransition(
              opacity: curveAnimation,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.88, end: 1.0).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutBack,
                  ),
                ),
                child: child,
              ),
            ),
          );
        }

        return FadeTransition(
          opacity: curveAnimation,
          child: child,
        );
      },
      child: currentScreen,
    );

    return mainContent;
  }
}
