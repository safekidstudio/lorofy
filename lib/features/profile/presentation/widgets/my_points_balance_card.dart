import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lorofy/components/ui/svg_asset.dart';
import 'package:lorofy/core/theme/app_theme.dart';
import 'package:lorofy/features/auth/presentation/providers/auth_provider.dart';
import 'package:lorofy/features/profile/presentation/pages/streak_celebration_page.dart';

/// Card showing current user's Rank Points balance, Gold Coins, and Streak.
class MyPointsBalanceCard extends ConsumerWidget {
  const MyPointsBalanceCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authStatus = ref.watch(authProvider);
    final profile = authStatus.userProfile;
    final int rankPoints = profile?.rankPoints ?? authStatus.rankPoints ?? 0;
    final int goldCoins = profile?.goldCoins ?? 0;
    final int currentStreak = profile?.currentStreak ?? 0;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppPadding.lg,
        vertical: AppPadding.sm,
      ),
      padding: const EdgeInsets.all(AppPadding.xl),
      decoration: BoxDecoration(
        color: const Color(0xFF072013),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Flower Icon & Points Label
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Color(0xFF133626),
                  shape: BoxShape.circle,
                ),
                child: const SVG(
                  'assets/illustrations/flower.svg',
                  width: 24,
                  height: 24,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Total Points Balance',
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 14,
                  color: Color(0xB3FFFFFF),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Total Points Number
          Text(
            '$rankPoints pts',
            style: const TextStyle(
              fontFamily: AppTextStyles.titleFontFamily,
              fontSize: 38,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.white,
            ),
          ),
          const SizedBox(height: 20),

          // Coins and Streak Pill Badges
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Coins Pill
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B3D2C),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: CupertinoColors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      CupertinoIcons.money_dollar_circle_fill,
                      color: Color(0xFFFFCA28),
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$goldCoins coins',
                      style: const TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Streak Pill
              GestureDetector(
                onTap: () {
                  if (currentStreak > 0) {
                    StreakCelebrationPage.show(
                      context,
                      currentStreak: currentStreak,
                      streakIncreased: false,
                      streakFreezeCount: profile?.streakFreezeCount ?? 0,
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B3D2C),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: CupertinoColors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        CupertinoIcons.flame_fill,
                        color: Color(0xFFFF6D00),
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$currentStreak-day streak',
                        style: const TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: CupertinoColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
