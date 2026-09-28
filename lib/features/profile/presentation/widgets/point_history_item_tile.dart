import 'package:flutter/cupertino.dart';
import 'package:lorofy/components/ui/svg_asset.dart';
import 'package:lorofy/core/theme/app_theme.dart';
import 'package:lorofy/core/utils/app_date_formatter.dart';
import 'package:lorofy/features/profile/domain/models/point_history_model.dart';

class PointHistoryItemTile extends StatelessWidget {
  final PointHistoryModel item;

  const PointHistoryItemTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final isReward = item.isReward;
    final color = isReward ? const Color(0xFF00B074) : const Color(0xFFFF4B4B);
    final sign = isReward && item.points > 0 ? '+' : '';

    final formattedDate = AppDateFormatter.formatDotDate(item.timestamp);

    final titleText = item.title.isNotEmpty
        ? item.title
        : (isReward ? 'Reward Points' : 'Penalty Points');

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppPadding.md,
        vertical: AppPadding.sm + 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: SVG(
              'assets/icons/point.svg',
              width: 18,
              height: 18,
              color: color,
            ),
          ),
          const SizedBox(width: AppPadding.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  titleText,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.foreground,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      formattedDate,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.mutedForeground,
                        fontSize: 11,
                      ),
                    ),
                    if (item.blockMode != null && item.blockMode!.isNotEmpty) ...[
                      const SizedBox(width: AppPadding.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Text(
                          item.blockMode!,
                          style: AppTextStyles.caption.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppPadding.sm),
          Text(
            '$sign${item.points} pts',
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
