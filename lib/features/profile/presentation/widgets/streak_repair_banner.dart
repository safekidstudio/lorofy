import 'package:flutter/cupertino.dart';
import 'package:lorofy/core/theme/app_theme.dart';
import 'package:lorofy/features/auth/data/models/user_profile.dart';
import 'package:lorofy/features/profile/presentation/widgets/streak_repair_dialog.dart';

class StreakRepairBanner extends StatelessWidget {
  final UserProfile profile;

  const StreakRepairBanner({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    if (!profile.canRepairStreak || profile.repairableStreak <= 0) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: () => StreakRepairDialog.show(context, profile),
      child: Container(
        padding: const EdgeInsets.all(AppPadding.md),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [CupertinoColors.activeOrange, CupertinoColors.systemRed],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppRadius.md),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.activeOrange.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(
              CupertinoIcons.flame_fill,
              color: CupertinoColors.white,
              size: 28,
            ),
            const SizedBox(width: AppPadding.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Restore your ${profile.repairableStreak}-day Streak!',
                    style: AppTextStyles.body.copyWith(
                      color: CupertinoColors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Tap to restore using Streak Freeze or Coins',
                    style: AppTextStyles.caption.copyWith(
                      color: CupertinoColors.white.withValues(alpha: 0.85),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              CupertinoIcons.chevron_right,
              color: CupertinoColors.white,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
