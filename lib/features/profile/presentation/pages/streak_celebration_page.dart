import 'package:flutter/material.dart';
import 'package:lorofy/components/ui/button.dart';
import 'package:lorofy/components/ui/number_flow_text.dart';
import 'package:lorofy/components/ui/safe_rive_animation.dart';
import 'package:lorofy/core/theme/app_theme.dart';
import 'package:lorofy/features/profile/presentation/widgets/weekly_streak_tracker.dart';
import 'package:rive/rive.dart' hide Animation;

class StreakCelebrationPage extends StatefulWidget {
  final int currentStreak;
  final int longestStreak;
  final bool streakIncreased;
  final int streakFreezeCount;
  final VoidCallback? onDismiss;

  const StreakCelebrationPage({
    super.key,
    required this.currentStreak,
    this.longestStreak = 251,
    this.streakIncreased = true,
    this.streakFreezeCount = 0,
    this.onDismiss,
  });

  static Future<void> show(
    BuildContext context, {
    required int currentStreak,
    int longestStreak = 251,
    bool streakIncreased = true,
    int streakFreezeCount = 0,
    VoidCallback? onDismiss,
  }) {
    return Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: false,
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: StreakCelebrationPage(
              currentStreak: currentStreak,
              longestStreak: longestStreak,
              streakIncreased: streakIncreased,
              streakFreezeCount: streakFreezeCount,
              onDismiss: onDismiss,
            ),
          );
        },
      ),
    );
  }

  @override
  State<StreakCelebrationPage> createState() => _StreakCelebrationPageState();
}

class _StreakCelebrationPageState extends State<StreakCelebrationPage>
    with SingleTickerProviderStateMixin {
  RiveWidgetController? _riveController;
  final Map<String, ViewModelInstance> _vmInstances = {};

  bool _showBoardAndButton = false;
  bool _showSubtitle = false;
  bool _showStreakNumber = false;

  late AnimationController _countController;
  late Animation<double> _countAnimation;
  int _displayedStreak = 0;

  @override
  void initState() {
    super.initState();

    final startStreak = (widget.streakIncreased && widget.currentStreak > 0)
        ? (widget.currentStreak - 1)
        : widget.currentStreak;

    _displayedStreak = startStreak;

    _countController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    _countAnimation =
        Tween<double>(
          begin: startStreak.toDouble(),
          end: widget.currentStreak.toDouble(),
        ).animate(
          CurvedAnimation(parent: _countController, curve: Curves.easeOutCubic),
        );

    _countAnimation.addListener(() {
      final val = _countAnimation.value.round();
      if (val != _displayedStreak) {
        setState(() {
          _displayedStreak = val;
        });
      }
    });
  }

  @override
  void dispose() {
    _countController.dispose();
    for (final vmi in _vmInstances.values) {
      vmi.dispose();
    }
    _vmInstances.clear();
    super.dispose();
  }

  void _startCountAnimation() {
    final startStreak = (widget.streakIncreased && widget.currentStreak > 0)
        ? (widget.currentStreak - 1)
        : widget.currentStreak;

    setState(() {
      _displayedStreak = startStreak;
    });
    _countController.reset();
    _countController.forward();
  }

  void _onRiveControllerInit(RiveWidgetController controller) {
    _riveController = controller;

    // Staggered Timeline Flow:
    // 1. Fire burst plays first (0s -> 2.0s)
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (!mounted) return;

      // Step 1: Show Weekly Board Card & Continue Button
      setState(() {
        _showBoardAndButton = true;
      });

      // Step 2: Show Subtitle 'day streak this week!' (+300ms after Board & Button appear)
      Future.delayed(const Duration(milliseconds: 300), () {
        if (!mounted) return;

        setState(() {
          _showSubtitle = true;
        });

        // Step 3: Show Streak Number - Scale up from small (0.2) to large (1.0) (+300ms after Subtitle)
        Future.delayed(const Duration(milliseconds: 300), () {
          if (!mounted) return;

          setState(() {
            _showStreakNumber = true;
          });

          // Step 4: AFTER Streak Number finishes scaling up (+550ms), RUN THE SLIDE ANIMATION!
          if (widget.streakIncreased && widget.currentStreak > 0) {
            Future.delayed(const Duration(milliseconds: 550), () {
              if (!mounted) return;
              _startCountAnimation();
            });
          }
        });
      });
    });
  }

  void _setupRiveDataBinding(File file) {
    final ab = _riveController?.artboard;
    if (ab == null) return;

    _vmInstances.clear();

    for (int i = 0; i < file.viewModelCount; i++) {
      final vm = file.viewModelByIndex(i);
      if (vm != null) {
        final vmi = vm.createDefaultInstance() ?? vm.createInstance();
        if (vmi != null) {
          ab.bindViewModelInstance(vmi);
          _vmInstances[vm.name] = vmi;
        }
      }
    }

    _updateStreakValues();
  }

  void _updateStreakValues() {
    final streakVM = _vmInstances['VMStreak'];
    final sphereVM = _vmInstances['VMSphere'];

    streakVM?.number('counter')?.value = widget.currentStreak.toDouble();
    sphereVM?.number('numStates')?.value = widget.currentStreak.toDouble();
  }

  void _handleDismiss() {
    if (widget.onDismiss != null) {
      widget.onDismiss!();
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final screenHeight = MediaQuery.sizeOf(context).height;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // 1. Rive Background Animation (Pure background, no overlay tint/dimming)
          Positioned.fill(
            child: SafeRiveAnimation.asset(
              'assets/rive/fire-streak.riv',
              onInitController: _onRiveControllerInit,
              onInitFile: _setupRiveDataBinding,
              fit: BoxFit.cover,
            ),
          ),

          // 2. UI Overlay Content
          SafeArea(
            child: Column(
              children: [
                // Reserved box for Rive flame background artwork (responsive for phones & tablets)
                SizedBox(height: screenHeight * 0.33),

                // Step 3 in Timeline: Big Streak Number (Scales up from small 0.2 to large 1.0, THEN slides digit!)
                AnimatedOpacity(
                  opacity: _showStreakNumber ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 450),
                  child: AnimatedScale(
                    scale: _showStreakNumber ? 1.0 : 0.2,
                    duration: const Duration(milliseconds: 450),
                    curve: Curves.easeOutBack,
                    child: GestureDetector(
                      onTap: _startCountAnimation,
                      child: NumberFlowText(
                        text: _displayedStreak.toString().padLeft(2, '0'),
                        duration: const Duration(milliseconds: 450),
                        style: TextStyle(
                          fontFamily: AppTextStyles.titleFontFamily,
                          fontSize: 136,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          height: 1.0,
                          shadows: const [
                            Shadow(
                              color: Color.fromARGB(255, 241, 113, 28),
                              blurRadius: 0,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Step 2 in Timeline: Subtitle 'day streak this week!' appears after board/button
                AnimatedOpacity(
                  opacity: _showSubtitle ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 400),
                  child: AnimatedSlide(
                    offset: _showSubtitle
                        ? Offset.zero
                        : const Offset(0.0, 0.2),
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOutCubic,
                    child: Text(
                      'day streak this week!',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.titleLarge.copyWith(
                        fontSize: 24,
                        color: Colors.white,
                        shadows: const [
                          Shadow(color: Colors.black54, blurRadius: 8),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Step 1 in Timeline: Weekly Tracker Card & Continue Button appear FIRST
                AnimatedOpacity(
                  opacity: _showBoardAndButton ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 500),
                  child: AnimatedSlide(
                    offset: _showBoardAndButton
                        ? Offset.zero
                        : const Offset(0.0, 0.2),
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOutCubic,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: WeeklyStreakTracker(
                        currentStreak: widget.currentStreak,
                        isDark: isDark,
                      ),
                    ),
                  ),
                ),

                const Spacer(),

                // Standardized App Button anchored at the VERY BOTTOM
                AnimatedOpacity(
                  opacity: _showBoardAndButton ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 500),
                  child: AnimatedSlide(
                    offset: _showBoardAndButton
                        ? Offset.zero
                        : const Offset(0.0, 0.2),
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOutCubic,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppPadding.xl,
                        vertical: AppPadding.lg,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: Button.secondary(
                          text: 'Continue',
                          onPressed: _handleDismiss,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
