import 'package:flutter/cupertino.dart';
import 'package:lorofy/components/layout/app_header.dart';
import 'package:lorofy/components/ui/button.dart';
import 'package:lorofy/components/ui/svg_asset.dart';
import 'package:lorofy/core/theme/app_theme.dart';
import 'package:lorofy/features/profile/presentation/pages/streak_celebration_page.dart';
import 'package:lorofy/components/ui/safe_rive_animation.dart';

class PomodoroCompletePage extends StatefulWidget {
  final VoidCallback onBackToHome;
  final VoidCallback onHaveARest;
  final int earnedPoints;
  final int earnedCoins;
  final int currentStreak;
  final bool streakIncreased;

  const PomodoroCompletePage({
    super.key,
    required this.onBackToHome,
    required this.onHaveARest,
    this.earnedPoints = 0,
    this.earnedCoins = 0,
    this.currentStreak = 0,
    this.streakIncreased = false,
  });

  @override
  State<PomodoroCompletePage> createState() => _PomodoroCompletePageState();
}

class _PomodoroCompletePageState extends State<PomodoroCompletePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _scaleAnim = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
      ),
    );

    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0.0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _triggerActionWithStreakFlow(VoidCallback defaultAction) {
    if (widget.currentStreak > 0 && widget.streakIncreased) {
      StreakCelebrationPage.show(
        context,
        currentStreak: widget.currentStreak,
        streakIncreased: widget.streakIncreased,
        onDismiss: () {
          Navigator.of(context).pop();
          defaultAction();
        },
      );
    } else {
      defaultAction();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Rive Confetti falling in the background
        const Positioned.fill(
          child: SafeRiveAnimation.asset(
            'assets/rive/confetti.riv',
            fit: BoxFit.cover,
          ),
        ),

        // Main content column
        Positioned.fill(
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // AppHeader with close button
                AppHeader(
                  leftActions: CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: widget.onBackToHome,
                    child: const Icon(
                      CupertinoIcons.xmark,
                      color: Color(0xFF232321),
                      size: 24,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Spacer(),

                        // Success checkmark illustration with bounce animation
                        Center(
                          child: ScaleTransition(
                            scale: _scaleAnim,
                            child: FadeTransition(
                              opacity: _fadeAnim,
                              child: const SVG(
                                'assets/illustrations/success_checkmark.svg',
                                width: 220,
                                height: 220,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 48),

                        // Subtitle & Reward Badges with slide & fade entry animation
                        SlideTransition(
                          position: _slideAnim,
                          child: FadeTransition(
                            opacity: _fadeAnim,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'Wow!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: AppTextStyles.titleFontFamily,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF232321),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'The plant has grown up',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: AppTextStyles.fontFamily,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF8E8E93),
                                  ),
                                ),

                                if (widget.earnedPoints > 0) ...[
                                  const SizedBox(height: 20),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(
                                            0xFFFFD60A,
                                          ).withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        child: Row(
                                          children: [
                                            const SVG(
                                              'assets/icons/point.svg',
                                              width: 16,
                                              height: 16,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '+${widget.earnedPoints} PTS',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFFFFCC00),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],

                                if (widget.currentStreak > 0) ...[
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: CupertinoColors.activeOrange
                                              .withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(
                                            color: CupertinoColors.activeOrange
                                                .withValues(alpha: 0.3),
                                            width: 1,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              CupertinoIcons.flame_fill,
                                              color: CupertinoColors.activeOrange,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              '${widget.currentStreak}-Day Streak!',
                                              style: const TextStyle(
                                                fontFamily: AppTextStyles.fontFamily,
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: CupertinoColors.activeOrange,
                                              ),
                                            ),
                                            if (widget.streakIncreased) ...[
                                              const SizedBox(width: 6),
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 6,
                                                  vertical: 2,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: CupertinoColors.activeOrange,
                                                  borderRadius: BorderRadius.circular(
                                                    10,
                                                  ),
                                                ),
                                                child: const Text(
                                                  '+1 Today 🎉',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                    color: CupertinoColors.white,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        const Spacer(),

                        // Have a Rest Button with slide & fade entry animation
                        SlideTransition(
                          position: _slideAnim,
                          child: FadeTransition(
                            opacity: _fadeAnim,
                            child: Center(
                              child: SizedBox(
                                width: 180,
                                child: Button.secondary(
                                  text: 'Have a rest',
                                  onPressed: () => _triggerActionWithStreakFlow(
                                    widget.onHaveARest,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
