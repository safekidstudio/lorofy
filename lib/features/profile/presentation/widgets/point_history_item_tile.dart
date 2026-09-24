import 'package:flutter/cupertino.dart';
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
    final icon = isReward
        ? CupertinoIcons.add_circled_solid
        : CupertinoIcons.minus_circle_fill;
    final sign = isReward && item.points > 0 ? '+' : '';

    final formattedTime = AppDateFormatter.formatDateTime(item.timestamp);

    return Container(
      padding: const EdgeInsets.all(AppPadding.md),
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
            padding: const EdgeInsets.all(AppPadding.sm),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: AppPadding.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title.isNotEmpty ? item.title : (isReward ? 'Reward Points' : 'Penalty Points'),
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.foreground,
                  ),
                ),
                if (item.description.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    item.description,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.mutedForeground,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      formattedTime,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.mutedForeground.withValues(alpha: 0.8),
                        fontSize: 11,
                      ),
                    ),
                    if (item.blockMode != null && item.blockMode!.isNotEmpty) ...[
                      const SizedBox(width: AppPadding.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
            '$sign${item.points}',
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}
