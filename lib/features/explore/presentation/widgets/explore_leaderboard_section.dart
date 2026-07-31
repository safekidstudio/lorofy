import 'package:flutter/cupertino.dart';
import 'package:lorofy/components/shared/drawing_container.dart';
import 'package:lorofy/components/ui/svg_asset.dart';
import 'package:lorofy/core/theme/app_theme.dart';
import 'package:lorofy/components/ui/toast.dart';

class ExploreLeaderboardSection extends StatelessWidget {
  const ExploreLeaderboardSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Leaderboard Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Leaderboard',
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                onPressed: () {
                  AppToast.show(
                    context,
                    message: "Leaderboard details coming soon!",
                  );
                },

                child: Row(
                  children: [
                    Text(
                      'View more ',
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        color: AppColors.secondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SVG(
                      'icons/chevron-right.svg',
                      width: 16,
                      height: 16,
                      color: AppColors.primary.withValues(alpha: 0.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Leaderboard Podium
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildPodiumUser(
                name: 'Graves',
                points: 90,
                rank: 2,
                avatarUrl:
                    'https://res.cloudinary.com/ikupgdru/image/upload/v1784619368/08_tqar6z_nvbvsx.png',
                highlightColor: const Color(0xFFD5DEEA), // green
              ),
              _buildPodiumUser(
                name: 'James',
                points: 120,
                rank: 1,
                avatarUrl:
                    'https://res.cloudinary.com/ikupgdru/image/upload/v1784619376/64_d4fo1k_wnebqr.png',
                highlightColor: const Color(0xFFFFB61D), // gold
                isCenter: true,
              ),
              _buildPodiumUser(
                name: 'David',
                points: 75,
                rank: 3,
                avatarUrl:
                    'https://res.cloudinary.com/ikupgdru/image/upload/v1784619368/02_aus2zc_tfpypg.png',
                highlightColor: const Color(0xFFD96806), // orange
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumUser({
    required String name,
    required int points,
    required int rank,
    required String avatarUrl,
    required Color highlightColor,
    bool isCenter = false,
  }) {
    final avatarSize = isCenter ? 100.0 : 80.0;
    Color badgeColor;
    switch (rank) {
      case 1:
        badgeColor = Color(0xFFFFCA28);
      case 2:
        badgeColor = Color(0xFFFFFFFF);
      case 3:
        badgeColor = Color(0xFFF6A661);
      default:
        badgeColor = highlightColor;
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // Organic blob avatar drawn & clipped via DrawingContainer
            DrawingContainer(
              shape: DrawingShape.blob,
              width: avatarSize,
              height: avatarSize,
              borderColor: highlightColor,
              borderWidth: 4.0,
              fillColor: CupertinoColors.transparent,
              child: Image.network(
                avatarUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: const Color(0xFFE5E5EA),
                    child: Icon(
                      CupertinoIcons.person_fill,
                      size: avatarSize * 0.5,
                      color: const Color(0xFF8E8E93),
                    ),
                  );
                },
              ),
            ),

            // Rank badge at bottom-center
            Positioned(
              bottom: -16,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: badgeColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: highlightColor, width: 4),
                ),
                alignment: Alignment.center,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outline / Stroke
                    Text(
                      rank.toString(),
                      style: TextStyle(
                        fontFamily: AppTextStyles.titleFontFamily,
                        fontSize: 16,
                        foreground: Paint()
                          ..style = PaintingStyle.stroke
                          ..strokeWidth = 1
                          ..color = highlightColor,
                      ),
                    ),
                    // Solid text fill
                    Text(
                      rank.toString(),
                      style: const TextStyle(
                        fontFamily: AppTextStyles.titleFontFamily,
                        color: AppColors.primary,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          name,
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 2,
          children: [
            SVG('illustrations/flower.svg', width: 14, height: 14),
            Text(
              '$points pts',
              style: const TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 12,
                color: AppColors.secondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
