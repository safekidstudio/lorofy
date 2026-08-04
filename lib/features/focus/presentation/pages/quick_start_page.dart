import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lorofy/core/theme/app_theme.dart';
import 'package:smooth_sheets/smooth_sheets.dart';
import 'package:lorofy/components/layout/app_header.dart';
import 'package:lorofy/components/ui/logo.dart';
import 'package:lorofy/components/ui/svg_asset.dart';
import 'package:lorofy/components/ui/toast.dart';
import 'package:lorofy/features/focus/domain/models/pomodoro_state.dart';
import 'package:lorofy/features/focus/presentation/providers/pomodoro_notifier.dart';
import 'package:lorofy/features/focus/presentation/providers/pomodoro_settings.dart';
import 'package:lorofy/features/focus/presentation/providers/categories_provider.dart';
import 'package:lorofy/features/focus/presentation/pages/pomodoro_complete_page.dart';
import 'package:lorofy/features/focus/presentation/pages/pomodoro_giveup_page.dart';
import 'package:lorofy/features/focus/presentation/widgets/focus_timer/pomodoro_action_buttons.dart';
import 'package:lorofy/features/focus/presentation/widgets/focus_timer/pomodoro_giveup_confirmation_sheet.dart';
import 'package:lorofy/features/focus/presentation/widgets/focus_timer/pomodoro_timer_display.dart';
import 'package:lorofy/features/mascot/presentation/providers/mascot_notifier.dart';
import 'package:lorofy/features/mascot/presentation/widgets/mascot_graphic.dart';

class QuickStartPage extends ConsumerStatefulWidget {
  final ValueChanged<bool> onFocusStateChanged;

  const QuickStartPage({super.key, required this.onFocusStateChanged});

  @override
  ConsumerState<QuickStartPage> createState() => _QuickStartPageState();
}

class _QuickStartPageState extends ConsumerState<QuickStartPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

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
      widget.onFocusStateChanged(true);
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
                child: const Icon(
                  CupertinoIcons.xmark,
                  color: Color(0xFF232321),
                  size: 24,
                ),
              )
            : const Padding(
                padding: EdgeInsetsGeometry.only(left: 16),
                child: Logo(key: ValueKey('logo_text')),
              ),
      ),
      rightActions: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: switch (phase) {
          PomodoroState.idle => CupertinoButton(
            key: const ValueKey('settings_btn'),
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
            child: const Icon(
              CupertinoIcons.multiply,
              color: Color(0xFF232321),
              size: 24,
            ),
          ),
          PomodoroState.completed => const SizedBox.shrink(
            key: ValueKey('empty_right'),
          ),
          _ => const KeyedSubtree(
            key: ValueKey('sound_button'),
            child: _SoundButton(),
          ),
        },
      ),
    );
  }

  // ── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    super.build(context); // Keep the state alive via mixin

    final timerState = ref.watch(pomodoroTimerProvider);
    final settings = ref.watch(pomodoroSettingsProvider);
    final notifier = ref.read(pomodoroTimerProvider.notifier);
    final phase = timerState.phase;

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

    final int displaySeconds =
        (phase == PomodoroState.focus || phase == PomodoroState.breakTime)
        ? timerState.countdownSeconds
        : settings.focusMinutes * 60;

    void onReset() {
      notifier.resetToIdle();
      widget.onFocusStateChanged(false);
    }

    // Sync focus lock state whenever phase changes
    ref.listen(pomodoroTimerProvider.select((s) => s.phase), (_, next) {
      widget.onFocusStateChanged(next != PomodoroState.idle);
    });

    Widget currentScreen;
    if (phase == PomodoroState.completed) {
      currentScreen = PomodoroCompletePage(
        key: const ValueKey('completed_page'),
        onBackToHome: onReset,
        onHaveARest: onReset,
        earnedPoints: timerState.earnedPoints ?? 0,
        earnedCoins: timerState.earnedCoins ?? 0,
      );
    } else if (phase == PomodoroState.giveup) {
      currentScreen = PomodoroGiveupPage(
        key: const ValueKey('giveup_page'),
        onBackToHome: onReset,
        onRestart: () {
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
            // Header
            _buildHeader(context, ref, phase, onReset),

            // Plant + timer + buttons — all centered as one block
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Mascot graphic (driven by active mascot from provider)
                    Consumer(
                      builder: (context, ref, child) {
                        final mascotState = ref.watch(mascotProvider);
                        final activeMascot = mascotState.activeMascot;
                        if (activeMascot == null)
                          return const SizedBox.shrink();
                        return MascotGraphic(
                          mascot: activeMascot,
                          isFocusing: phase == PomodoroState.focus,
                          focusProgressRatio: timerState.progressRatio,
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    // Timer / description text
                    AnimatedSwitcher(
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
                        targetRounds: settings.targetRounds,
                        isLongBreak: timerState.isLongBreak,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Action buttons
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
                        onStart: () {
                          notifier.startFocus(settings.focusMinutes);
                          widget.onFocusStateChanged(true);
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
                          widget.onFocusStateChanged(true);
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
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (Widget child, Animation<double> animation) {
        final curveAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.98, end: 1.0).animate(curveAnimation),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 0.03),
                end: Offset.zero,
              ).animate(curveAnimation),
              child: child,
            ),
          ),
        );
      },
      child: currentScreen,
    );
  }
}

// ---------------------------------------------------------------------------
// Local widget — Sound button with animated tooltip
// ---------------------------------------------------------------------------

class _SoundButton extends StatefulWidget {
  const _SoundButton();

  @override
  State<_SoundButton> createState() => _SoundButtonState();
}

class _SoundButtonState extends State<_SoundButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  Timer? _periodicTimer;
  Timer? _hideTimer;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.1, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    // Show tooltip after 2 seconds
    _showTooltipAfterDelay(2);

    // Setup periodic check every 45 seconds to show tooltip
    _periodicTimer = Timer.periodic(const Duration(seconds: 45), (timer) {
      _showTooltip();
    });
  }

  void _showTooltipAfterDelay(int seconds) {
    Future.delayed(Duration(seconds: seconds), () {
      _showTooltip();
    });
  }

  void _showTooltip() {
    if (!mounted) return;
    setState(() {
      _isVisible = true;
    });
    _controller.forward();
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 4), () {
      _hideTooltip();
    });
  }

  void _hideTooltip() {
    if (!mounted) return;
    _controller.reverse().then((_) {
      if (mounted) {
        setState(() {
          _isVisible = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _periodicTimer?.cancel();
    _hideTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_isVisible)
          FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF232321),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Tap to change sound',
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        color: CupertinoColors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text('🎧', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ),
          ),
        const SizedBox(width: 8),
        CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            _hideTooltip();
            _hideTimer?.cancel();
            context.push('/session-settings?tab=1');
          },
          child: const SVG(
            'assets/icons/sounds_drawing.svg',
            width: 24,
            height: 24,
          ),
        ),
      ],
    );
  }
}
