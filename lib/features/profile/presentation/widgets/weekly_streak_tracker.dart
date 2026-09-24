import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lorofy/components/shared/drawing_container.dart';
import 'package:lorofy/components/ui/svg_asset.dart';
import 'package:lorofy/core/theme/app_theme.dart';

class WeeklyStreakTracker extends StatelessWidget {
  final int currentStreak;
  final bool isDark;

  const WeeklyStreakTracker({
    super.key,
    required this.currentStreak,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final now = DateTime.now();
    final todayIndex = now.weekday - 1; // 0 for Mon, 6 for Sun

    return DrawingContainer(
      fillColor: Colors.black.withValues(alpha: 0.45),
      borderColor: Colors.white.withValues(alpha: 0.15),
      borderWidth: 2.0,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(7, (index) {
          final daysAgo = todayIndex - index;
          final isToday = index == todayIndex;

          final isActive = daysAgo >= 0 && daysAgo < currentStreak;
          final isMissed = daysAgo >= currentStreak;

          Widget dayIcon;
          if (isActive) {
            dayIcon = Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color.fromARGB(255, 241, 113, 28),
              ),
              child: const Center(
                child: SVG(
                  'assets/icons/check.svg',
                  color: Colors.white,
                  width: 20,
                  height: 20,
                ),
              ),
            );
          } else if (isMissed) {
            dayIcon = Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color.fromARGB(255, 241, 76, 68),
              ),
              child: const Center(
                child: SVG(
                  'assets/icons/cancel.svg',
                  color: Colors.white,
                  width: 20,
                  height: 20,
                ),
              ),
            );
          } else {
            dayIcon = Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondaryForeground,
              ),
            );
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                days[index],
                style: AppTextStyles.label.copyWith(
                  fontSize: 12,
                  fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                  color: isToday
                      ? CupertinoColors.activeOrange
                      : AppColors.mutedForeground,
                ),
              ),
              const SizedBox(height: 8),
              dayIcon,
            ],
          );
        }),
      ),
    );
  }
}
