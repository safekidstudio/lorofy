import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lorofy/components/layout/app_header.dart';
import 'package:lorofy/components/ui/button.dart';
import 'package:lorofy/components/ui/svg_asset.dart';
import 'package:lorofy/core/theme/app_theme.dart';
import 'package:lorofy/features/auth/presentation/providers/auth_provider.dart';
import 'package:lorofy/features/focus/presentation/pages/pomodoro_complete_page.dart';
import 'package:lorofy/features/profile/presentation/pages/streak_celebration_page.dart';

class StreakTestPage extends ConsumerStatefulWidget {
  const StreakTestPage({super.key});

  @override
  ConsumerState<StreakTestPage> createState() => _StreakTestPageState();
}

class _StreakTestPageState extends ConsumerState<StreakTestPage> {
  int _streakCount = 5;
  bool _streakIncreased = true;
  final int _freezeCount = 1;

  void _openStreakCelebration() {
    StreakCelebrationPage.show(
      context,
      currentStreak: _streakCount,
      streakIncreased: _streakIncreased,
      streakFreezeCount: _freezeCount,
    );
  }

  void _openSimulatedFocusComplete() {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => PomodoroCompletePage(
          earnedPoints: 25,
          earnedCoins: 10,
          currentStreak: _streakCount,
          streakIncreased: _streakIncreased,
          onBackToHome: () => Navigator.pop(context),
          onHaveARest: () => Navigator.pop(context),
        ),
      ),
    );
  }

  void _incrementAuthProviderStreak() async {
    final result = await ref.read(authProvider.notifier).recordFocusCompletionStreak();
    setState(() {
      _streakCount = result.currentStreak;
      _streakIncreased = result.streakIncreased;
    });
    if (mounted) {
      _openStreakCelebration();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentAuthStreak = ref.watch(authProvider).userProfile?.currentStreak ?? 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppHeader(
              leftActions: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(AppPadding.sm),
                  decoration: const BoxDecoration(
                    color: AppColors.secondary,
                    shape: BoxShape.circle,
                  ),
                  child: const SVG(
                    'assets/icons/chevron-left.svg',
                    width: 24,
                    height: 24,
                  ),
                ),
              ),
              title: '🔥 Streak Test Lab',
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Auth state banner
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: CupertinoColors.activeOrange.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: CupertinoColors.activeOrange.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            CupertinoIcons.flame_fill,
                            color: CupertinoColors.activeOrange,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Current User Profile Streak',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.mutedForeground,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  '$currentAuthStreak-day streak',
                                  style: const TextStyle(
                                    fontFamily: AppTextStyles.titleFontFamily,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.foreground,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Section 1: Custom Test Parameters
                    const Text(
                      'Cấu hình thông số Test',
                      style: TextStyle(
                        fontFamily: AppTextStyles.titleFontFamily,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.foreground,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Streak Count Stepper Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Số ngày Streak:',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '$_streakCount ngày',
                                style: const TextStyle(
                                  fontFamily: AppTextStyles.titleFontFamily,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: CupertinoColors.activeOrange,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              CupertinoButton.filled(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                onPressed: () {
                                  if (_streakCount > 1) {
                                    setState(() => _streakCount--);
                                  }
                                },
                                child: const Text('-1'),
                              ),
                              CupertinoButton.filled(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                onPressed: () {
                                  setState(() => _streakCount++);
                                },
                                child: const Text('+1'),
                              ),
                              CupertinoButton.filled(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                onPressed: () {
                                  setState(() => _streakCount += 5);
                                },
                                child: const Text('+5'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Streak Increased Toggle Card
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Trạng thái tăng streak (+1):',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          CupertinoSwitch(
                            value: _streakIncreased,
                            onChanged: (val) {
                              setState(() => _streakIncreased = val);
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Action Launchers
                    const Text(
                      'Thử nghiệm màn hình & Luồng',
                      style: TextStyle(
                        fontFamily: AppTextStyles.titleFontFamily,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.foreground,
                      ),
                    ),
                    const SizedBox(height: 14),

                    Button.primary(
                      text: '🚀 MỞ STREAK CELEBRATION (RIVE)',
                      onPressed: _openStreakCelebration,
                    ),

                    const SizedBox(height: 12),

                    Button.secondary(
                      text: '🔥 SIMULATE SIMULATED FOCUS COMPLETE',
                      onPressed: _openSimulatedFocusComplete,
                    ),

                    const SizedBox(height: 12),

                    CupertinoButton.filled(
                      onPressed: _incrementAuthProviderStreak,
                      child: const Text(
                        '⚡ TEST RECORD STREAK THẬT (+1)',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
