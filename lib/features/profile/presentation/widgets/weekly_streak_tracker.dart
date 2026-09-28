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

    // Duolingo Anchor Streak calculation:
    // If user has a current streak of N, the active streak anchor started (N-1) days ago.
    final int streakAnchorIndex = currentStreak > 0
        ? (todayIndex - (currentStreak - 1))
        : todayIndex + 1;

    return DrawingContainer(
      fillColor: Colors.black.withValues(alpha: 0.45),
      borderColor: Colors.white.withValues(alpha: 0.15),
      borderWidth: 2.0,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(7, (index) {
          final isToday = index == todayIndex;
          final isActive = currentStreak > 0 &&
              index >= streakAnchorIndex &&
              index <= todayIndex;
          final isTodayPending = isToday && !isActive;

          Widget dayIcon;
          if (isActive) {
            // 1. Completed streak day: Glowing Orange Checkmark
            dayIcon = Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFF1711C),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x66F1711C),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
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
          } else if (isTodayPending) {
            // 2. Today pending (uncompleted): Duolingo pulsing orange outline encouraging action
            dayIcon = Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.transparent,
                border: Border.all(
                  color: const Color(0xFFF1711C),
                  width: 2.5,
                ),
              ),
              child: Center(
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFF1711C),
                  ),
                ),
              ),
            );
          } else {
            // 3. Neutral days: Past days before streak anchor OR future days
            dayIcon = Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.12),
              ),
              child: Center(
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
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
                      ? const Color(0xFFF1711C)
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
