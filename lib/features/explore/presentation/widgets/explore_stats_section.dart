import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lorofy/components/ui/shimmer.dart';
import 'package:lorofy/core/theme/app_theme.dart';
import 'package:lorofy/features/explore/presentation/providers/explore_stats_provider.dart';

/// Converts total minutes from API into a display string:
///   48      → "48 min"
///   60      → "1 hr"
///   125     → "2 hr 5 min"
///   48058   → "800 hr 58 min"
String _formatDuration(int totalMinutes) {
  if (totalMinutes < 60) return '$totalMinutes min';
  final hr = totalMinutes ~/ 60;
  final min = totalMinutes % 60;
  return min == 0 ? '$hr hr' : '$hr hr $min min';
}

/// Parses a duration string like "120 min", "2 hr" or "800 hr 58 min"
/// and builds alternating TextSpans:
///   - value tokens (numbers) → 14px, w500, color
///   - unit tokens (hr/min)   → 10px, w400, color @ 80% opacity
List<InlineSpan> _buildDurationSpans(String duration, Color color) {
  final tokens = duration.trim().split(' ');
  return tokens.asMap().entries.map((entry) {
    final isValue = entry.key.isEven; // 0=value, 1=unit, 2=value, 3=unit...
    final isLast = entry.key == tokens.length - 1;
    return TextSpan(
      text: isLast ? entry.value : '${entry.value} ',
      style: TextStyle(
        fontFamily: AppTextStyles.fontFamily,
        color: isValue ? color : color.withValues(alpha: 0.8),
        fontSize: isValue ? 14 : 10,
        fontWeight: isValue ? FontWeight.w500 : FontWeight.w400,
      ),
    );
  }).toList();
}

class ExploreStatsSection extends ConsumerWidget {
  const ExploreStatsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(exploreStatsProvider);
    final todayActivitiesAsync = ref.watch(todayActivitiesProvider);

    return statsAsync.when(
      loading: () => const _ExploreStatsSkeleton(),
      error: (err, stack) => SizedBox(
        height: 200,
        child: Center(
          child: Text(
            'Error loading statistics: $err',
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              color: CupertinoColors.systemRed,
            ),
          ),
        ),
      ),
      data: (stats) {
        return todayActivitiesAsync.when(
          loading: () => const _ExploreStatsSkeleton(),
          error: (err, stack) => SizedBox(
            height: 200,
            child: Center(
              child: Text(
                'Error loading activities: $err',
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  color: CupertinoColors.systemRed,
                ),
              ),
            ),
          ),
          data: (todayActivities) {
            // Compute values dynamically
            final todayCompleted = todayActivities
                .where((s) => s.status == 'COMPLETED')
                .toList();
            final todayFocusCount = todayCompleted.length;

            final todayFocusMinutes = todayCompleted.fold<int>(
              0,
              (sum, s) => sum + s.actualMinutes,
            );

            final todayKillCount = todayActivities
                .where((s) => s.status == 'FAILED')
                .length;

            final allFocusCount = stats.totalCompletedSessions;
            final allFocusMinutes = stats.totalFocusMinutes;
            final allKillCount = stats.totalFailedSessions;

            final avgFocusMinutes = allFocusCount > 0
                ? (allFocusMinutes / allFocusCount).round()
                : 0;

            final failedToday = todayActivities.where((s) => s.status == 'FAILED').toList();
            final avgKillMinutes = failedToday.isNotEmpty
                ? (failedToday.fold<int>(0, (sum, s) => sum + s.actualMinutes) / failedToday.length).round()
                : 0;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Stats Cards Row (Today Focus / All Focus)
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF072013), // Dark green
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Today Focus',
                                style: TextStyle(
                                  fontFamily: AppTextStyles.fontFamily,
                                  color: const Color(0xFF8E9B93),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Center(
                                child: Text(
                                  todayFocusCount.toString(),
                                  style: TextStyle(
                                    fontFamily: AppTextStyles.titleFontFamily,
                                    color: CupertinoColors.white,
                                    fontSize: 40,
                                  ),
                                ),
                              ),
                              Center(
                                child: RichText(
                                  text: TextSpan(
                                    children: _buildDurationSpans(
                                      _formatDuration(todayFocusMinutes),
                                      CupertinoColors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: CupertinoColors.white,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            boxShadow: [
                              BoxShadow(
                                color: CupertinoColors.systemGrey.withValues(alpha: 0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'All Focus',
                                style: TextStyle(
                                  fontFamily: AppTextStyles.fontFamily,
                                  color: const Color(0xFF8E8E93),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Center(
                                child: Text(
                                  allFocusCount.toString(),
                                  style: TextStyle(
                                    fontFamily: AppTextStyles.titleFontFamily,
                                    color: const Color(0xFF232321),
                                    fontSize: 40,
                                  ),
                                ),
                              ),
                              Center(
                                child: RichText(
                                  text: TextSpan(
                                    children: _buildDurationSpans(
                                      _formatDuration(allFocusMinutes),
                                      const Color(0xFF8E8E93),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Kill Stats Container
                Container(
                  decoration: BoxDecoration(
                    color: CupertinoColors.white,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Today Kill',
                            style: TextStyle(
                              fontFamily: AppTextStyles.fontFamily,
                              color: AppColors.foreground.withValues(alpha: 0.6),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            todayKillCount.toString(),
                            style: const TextStyle(
                              fontFamily: AppTextStyles.titleFontFamily,
                              color: CupertinoColors.activeGreen,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Container(
                          height: 1,
                          color: AppColors.mutedForeground.withValues(alpha: 0.1),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'All Kill',
                            style: TextStyle(
                              fontFamily: AppTextStyles.fontFamily,
                              color: AppColors.foreground.withValues(alpha: 0.6),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            allKillCount.toString(),
                            style: const TextStyle(
                              fontFamily: AppTextStyles.titleFontFamily,
                              color: CupertinoColors.activeGreen,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Average Stats Row
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: CupertinoColors.white,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'Average\nFocus time',
                                style: TextStyle(
                                  fontFamily: AppTextStyles.fontFamily,
                                  color: AppColors.foreground.withValues(alpha: 0.6),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'min',
                                  style: TextStyle(
                                    fontFamily: AppTextStyles.fontFamily,
                                    color: AppColors.mutedForeground.withValues(alpha: 0.6),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  avgFocusMinutes.toString(),
                                  style: const TextStyle(
                                    fontFamily: AppTextStyles.titleFontFamily,
                                    color: AppColors.foreground,
                                    fontSize: 32,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: CupertinoColors.white,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'Average\nKill time',
                                style: TextStyle(
                                  fontFamily: AppTextStyles.fontFamily,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.foreground.withValues(alpha: 0.6),
                                ),
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'min',
                                  style: TextStyle(
                                    fontFamily: AppTextStyles.fontFamily,
                                    color: AppColors.mutedForeground.withValues(alpha: 0.6),
                                    fontSize: 10,
                                  ),
                                ),
                                Text(
                                  avgKillMinutes.toString(),
                                  style: const TextStyle(
                                    fontFamily: AppTextStyles.titleFontFamily,
                                    color: AppColors.foreground,
                                    fontSize: 32,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _ExploreStatsSkeleton extends StatelessWidget {
  const _ExploreStatsSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Top Cards Row
        Row(
          children: [
            Expanded(
              child: ShimmerPlaceholder.rectangular(
                height: 130,
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ShimmerPlaceholder.rectangular(
                height: 130,
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Middle Container (Kill stats)
        ShimmerPlaceholder.rectangular(
          height: 94,
          borderRadius: BorderRadius.circular(14),
        ),
        const SizedBox(height: 16),
        // Bottom Row (Average stats)
        Row(
          children: [
            Expanded(
              child: ShimmerPlaceholder.rectangular(
                height: 80,
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ShimmerPlaceholder.rectangular(
                height: 80,
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
