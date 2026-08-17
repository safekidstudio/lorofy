import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lorofy/core/theme/app_theme.dart';
import 'package:lorofy/components/ui/svg_asset.dart';
import 'package:lorofy/components/ui/sliding_segmented_control.dart';
import 'package:lorofy/components/ui/shimmer.dart';
import 'package:lorofy/features/explore/presentation/providers/explore_stats_provider.dart';
import 'package:lorofy/features/focus/domain/models/focus_session.dart';

class ExploreRecordSection extends ConsumerStatefulWidget {
  const ExploreRecordSection({super.key});

  @override
  ConsumerState<ExploreRecordSection> createState() => _ExploreRecordSectionState();
}

class _ExploreRecordSectionState extends ConsumerState<ExploreRecordSection> {
  bool _isDayToggle = true;

  String _getMonthAbbreviation(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    if (month >= 1 && month <= 12) {
      return months[month - 1];
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final todayAsync = ref.watch(todayActivitiesProvider);
    final monthAsync = ref.watch(monthActivitiesProvider);

    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Focus Record Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Focus Record',
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              _buildRecordToggle(),
            ],
          ),
          const SizedBox(height: 16),
          _isDayToggle
              ? todayAsync.when(
                  loading: () => const _RecordListSkeleton(itemCount: 3, isDay: true),
                  error: (err, stack) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: Text('Error loading today records: $err')),
                  ),
                  data: (sessions) => _buildDayRecordList(sessions),
                )
              : monthAsync.when(
                  loading: () => const _RecordListSkeleton(itemCount: 4, isDay: false),
                  error: (err, stack) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: Text('Error loading month records: $err')),
                  ),
                  data: (sessions) => _buildMonthRecordList(sessions),
                ),
        ],
      ),
    );
  }

  Widget _buildRecordToggle() {
    return SlidingSegmentedControl(
      height: 30,
      tabs: const ['Day', 'Month'],
      selectedIndex: _isDayToggle ? 0 : 1,
      onTabChanged: (index) {
        setState(() {
          _isDayToggle = index == 0;
        });
      },
    );
  }

  Widget _buildDayRecordList(List<FocusSession> sessions) {
    final completedSessions = sessions.where((s) => s.status == 'COMPLETED').toList()
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));

    if (completedSessions.isEmpty) {
      return const SizedBox(
        height: 100,
        child: Center(
          child: Text(
            'No focus records today',
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              color: AppColors.secondary,
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    return Column(
      children: completedSessions.asMap().entries.map((entry) {
        final index = entry.key;
        final session = entry.value;

        // Parse and format local time
        final localTime = DateTime.parse(session.startedAt).toLocal();
        final hour = localTime.hour;
        final minute = localTime.minute.toString().padLeft(2, '0');
        final period = hour >= 12 ? 'PM' : 'AM';
        final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
        final timeStrFormatted = '${displayHour.toString().padLeft(2, '0')}:$minute';

        final int flowerCount = session.earnedPoints;
        final String durationStr = '${session.actualMinutes} mins';
        final bool isHighlight = index == 0;

        final Color numberColor = isHighlight ? AppColors.primary : AppColors.secondary;
        final Color labelColor = AppColors.secondary.withValues(alpha: 0.6);
        final Color durationColor = AppColors.secondary.withValues(alpha: 0.6);

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  // Left: Time Column
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        timeStrFormatted,
                        style: TextStyle(
                          fontFamily: AppTextStyles.titleFontFamily,
                          fontSize: 24,
                          color: numberColor,
                          height: 0.9,
                        ),
                      ),
                      Text(
                        period,
                        style: TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 14,
                          color: labelColor,
                          fontWeight: FontWeight.w500,
                          height: 1.0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 24),
                  // Middle: Flower streak row
                  Expanded(
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: List.generate(
                        flowerCount,
                        (i) => const SVG(
                          'illustrations/flower.svg',
                          width: 30,
                          height: 30,
                        ),
                      ),
                    ),
                  ),
                  // Right: Duration
                  const SizedBox(width: 12),
                  Text(
                    durationStr,
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 14,
                      color: durationColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildMonthRecordList(List<FocusSession> sessions) {
    final completedSessions = sessions.where((s) => s.status == 'COMPLETED').toList();

    // Group by local date string "yyyy-MM-dd"
    final Map<String, int> dailyFlowers = {};
    for (var session in completedSessions) {
      final localDate = DateTime.parse(session.startedAt).toLocal();
      final dateKey = '${localDate.year}-${localDate.month.toString().padLeft(2, '0')}-${localDate.day.toString().padLeft(2, '0')}';
      dailyFlowers[dateKey] = (dailyFlowers[dateKey] ?? 0) + session.earnedPoints;
    }

    final sortedDates = dailyFlowers.keys.toList()..sort((a, b) => b.compareTo(a));

    if (sortedDates.isEmpty) {
      return const SizedBox(
        height: 100,
        child: Center(
          child: Text(
            'No focus records in the last 30 days',
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              color: AppColors.secondary,
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    final todayLocal = DateTime.now().toLocal();
    final todayKey = '${todayLocal.year}-${todayLocal.month.toString().padLeft(2, '0')}-${todayLocal.day.toString().padLeft(2, '0')}';

    return Column(
      spacing: 10,
      children: sortedDates.asMap().entries.map((entry) {
        final index = entry.key;
        final dateKey = entry.value;
        final int flowerCount = dailyFlowers[dateKey]!;

        final date = DateTime.parse(dateKey);
        final bool isToday = dateKey == todayKey;

        final String dayStr = date.day.toString();
        final String monthStr = isToday ? 'Today' : _getMonthAbbreviation(date.month);

        final bool isHighlight = isToday || index == 0;
        final Color numberColor = isHighlight ? AppColors.primary : AppColors.secondary;
        final Color labelColor = AppColors.secondary.withValues(alpha: 0.6);

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  // Left: Date Column
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        dayStr,
                        style: TextStyle(
                          fontFamily: AppTextStyles.titleFontFamily,
                          fontSize: 32,
                          color: numberColor,
                          height: 0.9,
                        ),
                      ),
                      Text(
                        monthStr,
                        style: TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 14,
                          color: labelColor,
                          fontWeight: FontWeight.w500,
                          height: 1.0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 24),
                  // Middle: Flower streak row
                  Expanded(
                    child: Wrap(
                      spacing: 16,
                      runSpacing: 4,
                      children: List.generate(
                        flowerCount,
                        (i) => const SVG(
                          'illustrations/flower.svg',
                          width: 44,
                          height: 44,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}

class _RecordListSkeleton extends StatelessWidget {
  final int itemCount;
  final bool isDay;
  const _RecordListSkeleton({required this.itemCount, required this.isDay});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        itemCount,
        (index) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              const Column(
                children: [
                  ShimmerPlaceholder.rectangular(height: 24, width: 40),
                  SizedBox(height: 4),
                  ShimmerPlaceholder.rectangular(height: 12, width: 30),
                ],
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Row(
                  children: List.generate(
                    3,
                    (i) => Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ShimmerPlaceholder.circular(size: isDay ? 30 : 44),
                    ),
                  ),
                ),
              ),
              if (isDay) const ShimmerPlaceholder.rectangular(height: 16, width: 50),
            ],
          ),
        ),
      ),
    );
  }
}
