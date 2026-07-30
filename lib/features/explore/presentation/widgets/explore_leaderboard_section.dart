import 'package:flutter/cupertino.dart';
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                        color: AppColors.primary.withValues(alpha: 0.4),
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
                highlightColor: const Color(0xFFA6E0B5), // green
              ),
              _buildPodiumUser(
                name: 'James',
                points: 120,
                rank: 1,
                avatarUrl:
                    'https://res.cloudinary.com/ikupgdru/image/upload/v1784619376/64_d4fo1k_wnebqr.png',
                highlightColor: const Color(0xFFFFD465), // gold
                isCenter: true,
              ),
              _buildPodiumUser(
                name: 'David',
                points: 75,
                rank: 3,
                avatarUrl:
                    'https://res.cloudinary.com/ikupgdru/image/upload/v1784619368/02_aus2zc_tfpypg.png',
                highlightColor: const Color(0xFFFFAC7F), // orange
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
    final avatarSize = isCenter ? 80.0 : 64.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Organic blob frame drawn via CustomPainter
            CustomPaint(
              painter: _BlobFramePainter(color: highlightColor),
              size: Size(avatarSize + 24, avatarSize + 24),
            ),

            // Avatar clipped to blob shape — same path as the frame
            ClipPath(
              clipper: _BlobClipper(),
              child: SizedBox(
                width: avatarSize + 24,
                height: avatarSize + 24,
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
            ),

            // Rank badge at bottom-center
            Positioned(
              bottom: 0,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: highlightColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: CupertinoColors.white, width: 2),
                ),
                alignment: Alignment.center,
                child: Text(
                  rank.toString(),
                  style: const TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    color: Color(0xFF232321),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: isCenter ? 16 : 14,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF232321),
          ),
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🌷 ', style: TextStyle(fontSize: 12)),
            Text(
              '$points pts',
              style: const TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 12,
                color: Color(0xFF8E8E93),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Draws the organic blob shape as a stroked path on canvas.
/// Path derived from SVG viewBox 104×104, scaled to any widget size.
class _BlobFramePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  const _BlobFramePainter({required this.color, this.strokeWidth = 4});

  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 104;
    final sy = size.height / 104;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(53.1285 * sx, 2.58257 * sy)
      ..cubicTo(
        8.6957 * sx,
        7.34084 * sy,
        0.744564 * sx,
        28.969 * sy,
        2.14771 * sx,
        50.1649 * sy,
      )
      ..cubicTo(
        3.55085 * sx,
        71.3608 * sy,
        10.5666 * sx,
        95.1518 * sy,
        53.1285 * sx,
        101.208 * sy,
      )
      ..cubicTo(
        95.6905 * sx,
        107.264 * sy,
        98.0291 * sx,
        77.4167 * sy,
        101.303 * sx,
        50.1649 * sy,
      )
      ..cubicTo(
        104.577 * sx,
        22.9132 * sy,
        97.5614 * sx,
        -2.17571 * sy,
        53.1285 * sx,
        2.58257 * sy,
      )
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_BlobFramePainter old) =>
      old.color != color || old.strokeWidth != strokeWidth;
}

/// Clips a widget to the organic blob shape.
/// Mirrors the same bezier path as [_BlobFramePainter].
class _BlobClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final sx = size.width / 104;
    final sy = size.height / 104;

    return Path()
      ..moveTo(53.1285 * sx, 2.58257 * sy)
      ..cubicTo(
        8.6957 * sx, 7.34084 * sy,
        0.744564 * sx, 28.969 * sy,
        2.14771 * sx, 50.1649 * sy,
      )
      ..cubicTo(
        3.55085 * sx, 71.3608 * sy,
        10.5666 * sx, 95.1518 * sy,
        53.1285 * sx, 101.208 * sy,
      )
      ..cubicTo(
        95.6905 * sx, 107.264 * sy,
        98.0291 * sx, 77.4167 * sy,
        101.303 * sx, 50.1649 * sy,
      )
      ..cubicTo(
        104.577 * sx, 22.9132 * sy,
        97.5614 * sx, -2.17571 * sy,
        53.1285 * sx, 2.58257 * sy,
      )
      ..close();
  }

  @override
  bool shouldReclip(_BlobClipper old) => false;
}
