import 'package:flutter/cupertino.dart';
import 'package:lorofy/components/ui/animated_points_flow.dart';
import 'package:lorofy/components/ui/app_avatar.dart';
import 'package:lorofy/core/theme/app_theme.dart';
import 'package:lorofy/features/explore/domain/models/leaderboard.dart';
import 'package:lorofy/features/explore/presentation/widgets/leaderboard/leaderboard_constants.dart';

class ReorderingCardsList extends StatelessWidget {
  final List<LeaderboardItem> listItems;
  final int Function(LeaderboardItem)? getPoints;
  final LeaderboardItem? currentUserRank;
  final Set<String> recentlyBoosted;

  const ReorderingCardsList({
    super.key,
    required this.listItems,
    this.getPoints,
    required this.currentUserRank,
    this.recentlyBoosted = const {},
  });

  @override
  Widget build(BuildContext context) {
    final double stackHeight = listItems.length * LeaderboardConstants.cardSlotHeight;

    final sortedIndices = List<int>.generate(listItems.length, (i) => i);
    sortedIndices.sort((a, b) {
      final isABoosted = recentlyBoosted.contains(listItems[a].profileId);
      final isBBoosted = recentlyBoosted.contains(listItems[b].profileId);
      if (isABoosted && !isBBoosted) return 1;
      if (!isABoosted && isBBoosted) return -1;
      return 0;
    });

    return SizedBox(
      height: stackHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: sortedIndices.map((index) {
          final entry = listItems[index];
          final displayRank = index + 4;
          final isYou = currentUserRank?.profileId == entry.profileId;
          final isBoosted = recentlyBoosted.contains(entry.profileId);

          return AnimatedPositioned(
            key: ValueKey('rank_card_${entry.profileId}'),
            duration: LeaderboardConstants.positionDuration,
            curve: Curves.easeInOutCubic,
            top: index * LeaderboardConstants.cardSlotHeight,
            left: 0,
            right: 0,
            height: LeaderboardConstants.cardHeight,
            child: RepaintBoundary(
              child: LeaderboardRankCard(
                entry: entry,
                displayRank: displayRank,
                effectivePoints: getPoints != null ? getPoints!(entry) : entry.points,
                isYou: isYou,
                isBoosted: isBoosted,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class LeaderboardRankCard extends StatelessWidget {
  final LeaderboardItem entry;
  final int displayRank;
  final int effectivePoints;
  final bool isYou;
  final bool isBoosted;

  const LeaderboardRankCard({
    super.key,
    required this.entry,
    required this.displayRank,
    required this.effectivePoints,
    required this.isYou,
    required this.isBoosted,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey('slide_down_${entry.profileId}'),
      tween: Tween<double>(begin: 1.0, end: 0.0),
      duration: LeaderboardConstants.slideDownDuration,
      curve: Curves.easeOutCubic,
      builder: (context, progress, child) {
        final slideY = -60.0 * progress;
        final scale = 0.95 + (0.05 * (1.0 - progress));
        final opacity = (1.0 - progress).clamp(0.0, 1.0);

        return Transform.translate(
          offset: Offset(0, slideY),
          child: Transform.scale(
            scale: scale,
            child: Opacity(
              opacity: opacity,
              child: child,
            ),
          ),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutBack,
        transform: isBoosted
            ? Matrix4.diagonal3Values(1.05, 1.05, 1.0)
            : Matrix4.identity(),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          color: isYou ? const Color(0xFF072013) : CupertinoColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: CupertinoColors.transparent, width: 0),
          boxShadow: isBoosted
              ? [
                  BoxShadow(
                    color: CupertinoColors.black.withValues(alpha: 0.14),
                    blurRadius: 18,
                    spreadRadius: 1,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [
                  BoxShadow(
                    color: CupertinoColors.black.withValues(alpha: 0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            // Rank Number
            SizedBox(
              width: 28,
              child: Text(
                displayRank.toString(),
                style: TextStyle(
                  fontFamily: AppTextStyles.titleFontFamily,
                  fontSize: 16,
                  color: isYou ? CupertinoColors.white : const Color(0xFF232321),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Avatar
            AppAvatar(
              path: entry.avatarUrl,
              size: 32,
            ),
            const SizedBox(width: 12),
            // Name
            Expanded(
              child: Text(
                isYou ? 'You' : entry.displayName,
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isYou ? CupertinoColors.white : AppColors.primary,
                ),
              ),
            ),
            // Pure Numerical Points Flow (Symbol Icon Removed)
            AnimatedPointsFlow(
              value: effectivePoints,
              showFlowerIcon: false,
              textColor: isYou
                  ? CupertinoColors.white.withValues(alpha: 0.9)
                  : const Color(0xFF8E8E93),
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isYou
                    ? CupertinoColors.white.withValues(alpha: 0.9)
                    : const Color(0xFF8E8E93),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
