import 'package:flutter/cupertino.dart';
import 'package:lorofy/components/shared/drawing_container.dart';
import 'package:lorofy/components/ui/animated_points_flow.dart';
import 'package:lorofy/components/ui/svg_asset.dart';
import 'package:lorofy/core/theme/app_theme.dart';
import 'package:lorofy/features/explore/domain/models/leaderboard.dart';
import 'package:lorofy/features/explore/presentation/widgets/leaderboard/leaderboard_constants.dart';

class PodiumStage extends StatelessWidget {
  final List<LeaderboardItem> top3;
  final int Function(LeaderboardItem)? getPoints;
  final LeaderboardItem? currentUserRank;
  final Set<String> recentlyBoosted;

  const PodiumStage({
    super.key,
    required this.top3,
    this.getPoints,
    required this.currentUserRank,
    this.recentlyBoosted = const {},
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final double colWidth = (totalWidth - 16) / 3;

        final podiumItems = <_PodiumItemData>[];
        for (int i = 0; i < top3.length; i++) {
          final item = top3[i];
          final rank = i + 1;
          double left;
          double top;
          bool isCenter = false;
          Color borderColor;
          Color badgeColor;

          switch (rank) {
            case 1:
              left = colWidth + 8;
              top = 45.0;
              isCenter = true;
              borderColor = const Color(0xFFFFB61D);
              badgeColor = const Color(0xFFFFCA28);
            case 2:
              left = 0.0;
              top = 85.0;
              borderColor = const Color(0xFFD5DEEA);
              badgeColor = const Color(0xFFFFFFFF);
            case 3:
              left = (colWidth + 8) * 2;
              top = 85.0;
              borderColor = const Color(0xFFD96806);
              badgeColor = const Color(0xFFF6A661);
            default:
              left = 0.0;
              top = 85.0;
              borderColor = const Color(0xFFD5DEEA);
              badgeColor = const Color(0xFFFFFFFF);
          }

          podiumItems.add(_PodiumItemData(
            item: item,
            rank: rank,
            left: left,
            top: top,
            colWidth: colWidth,
            isCenter: isCenter,
            borderColor: borderColor,
            badgeColor: badgeColor,
          ));
        }

        podiumItems.sort((a, b) => b.rank.compareTo(a.rank));

        return SizedBox(
          height: LeaderboardConstants.podiumHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: podiumItems.map((slot) {
              final user = slot.item;
              final isYou = currentUserRank?.profileId == user.profileId;
              final isBoosted = recentlyBoosted.contains(user.profileId);

              return AnimatedPositioned(
                key: ValueKey('podium_avatar_${user.profileId}'),
                duration: LeaderboardConstants.positionDuration,
                curve: LeaderboardConstants.springCurve,
                left: slot.left,
                top: slot.top,
                width: slot.colWidth,
                height: LeaderboardConstants.podiumAvatarColumnHeight,
                child: RepaintBoundary(
                  child: _PodiumAvatarColumn(
                    user: user,
                    rank: slot.rank,
                    effectivePoints: getPoints != null ? getPoints!(user) : user.points,
                    isCenter: slot.isCenter,
                    borderColor: slot.borderColor,
                    badgeColor: slot.badgeColor,
                    isYou: isYou,
                    isBoosted: isBoosted,
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

class _PodiumItemData {
  final LeaderboardItem item;
  final int rank;
  final double left;
  final double top;
  final double colWidth;
  final bool isCenter;
  final Color borderColor;
  final Color badgeColor;

  _PodiumItemData({
    required this.item,
    required this.rank,
    required this.left,
    required this.top,
    required this.colWidth,
    required this.isCenter,
    required this.borderColor,
    required this.badgeColor,
  });
}

class _PodiumAvatarColumn extends StatelessWidget {
  final LeaderboardItem user;
  final int rank;
  final int effectivePoints;
  final bool isCenter;
  final Color borderColor;
  final Color badgeColor;
  final bool isYou;
  final bool isBoosted;

  const _PodiumAvatarColumn({
    required this.user,
    required this.rank,
    required this.effectivePoints,
    required this.isCenter,
    required this.borderColor,
    required this.badgeColor,
    required this.isYou,
    required this.isBoosted,
  });

  @override
  Widget build(BuildContext context) {
    final double avatarSize = isCenter ? 100.0 : 80.0;

    return AnimatedScale(
      duration: const Duration(milliseconds: 350),
      scale: isBoosted ? 1.08 : 1.0,
      curve: Curves.easeOutBack,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              DrawingContainer(
                shape: DrawingShape.blob,
                width: avatarSize,
                height: avatarSize,
                borderColor: borderColor,
                borderWidth: 4.0,
                fillColor: CupertinoColors.transparent,
                child: Image.network(
                  user.avatarUrl ??
                      'https://res.cloudinary.com/ikupgdru/image/upload/v1784619368/08_tqar6z_nvbvsx.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: const Color(0xFFE5E5EA),
                    child: Icon(
                      CupertinoIcons.person_fill,
                      size: avatarSize * 0.5,
                      color: const Color(0xFF8E8E93),
                    ),
                  ),
                ),
              ),

              // Crown on Rank 1
              Positioned(
                top: -45,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 350),
                  opacity: rank == 1 ? 1.0 : 0.0,
                  child: const SVG(
                    'assets/illustrations/crown.svg',
                    width: 65,
                    height: 65,
                  ),
                ),
              ),

              // Rank Badge
              Positioned(
                bottom: -14,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: badgeColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: borderColor,
                      width: 3,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        rank.toString(),
                        style: TextStyle(
                          fontFamily: AppTextStyles.titleFontFamily,
                          fontSize: 14,
                          foreground: Paint()
                            ..style = PaintingStyle.stroke
                            ..strokeWidth = 1
                            ..color = borderColor,
                        ),
                      ),
                      Text(
                        rank.toString(),
                        style: const TextStyle(
                          fontFamily: AppTextStyles.titleFontFamily,
                          color: AppColors.primary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          // User Name
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Text(
              isYou ? 'You' : user.displayName,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 2),
          // Pure Numerical Points Flow (Symbol Icon Removed)
          AnimatedPointsFlow(
            value: effectivePoints,
            showFlowerIcon: false,
          ),
        ],
      ),
    );
  }
}
