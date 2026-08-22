import 'package:flutter/cupertino.dart';
import 'package:lorofy/components/ui/svg_asset.dart';
import 'package:lorofy/core/theme/app_theme.dart';
import 'package:lorofy/features/focus/domain/models/focus_session.dart';

class PastDaySummary {
  final DateTime date;
  final List<FocusSession> sessions;
  PastDaySummary(this.date, this.sessions);
}

// Helpers to format date and time
String _formatTime(DateTime dt) {
  final hour = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
  final minute = dt.minute.toString().padLeft(2, '0');
  return '${hour.toString().padLeft(2, '0')}:$minute';
}

String _formatAmPm(DateTime dt) {
  return dt.hour >= 12 ? 'PM' : 'AM';
}

String _formatDay(DateTime dt) {
  return dt.day.toString();
}

String _formatMonth(DateTime dt) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return months[dt.month - 1];
}

Widget _buildFlowerRow(int healthyCount, int failedCount) {
  return Wrap(
    spacing: 6,
    runSpacing: 4,
    children: [
      ...List.generate(
        healthyCount,
        (_) =>
            const SVG('assets/illustrations/flower.svg', width: 14, height: 30),
      ),
      ...List.generate(
        failedCount,
        (_) => const SVG(
          'assets/illustrations/flower.svg',
          width: 14,
          height: 30,
          color: Color(0xFF8D583F), // Tint wilted flowers brown
        ),
      ),
    ],
  );
}

class TodayActivityItem extends StatelessWidget {
  final FocusSession session;

  const TodayActivityItem({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final localTime = DateTime.parse(session.startedAt).toLocal();
    final isFailed = session.status == 'FAILED';

    final int healthy;
    final int failed;
    if (isFailed) {
      healthy = session.actualMinutes ~/ 10;
      failed = 1;
    } else {
      healthy = (session.plannedMinutes / 10).round().clamp(1, 12);
      failed = 0;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFECECED), width: 1)),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                _formatTime(localTime),
                style: TextStyle(
                  fontFamily: AppTextStyles.titleFontFamily,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary.withValues(alpha: 0.5),
                  letterSpacing: -0.5,
                  height: 1.0,
                ),
              ),
              Text(
                _formatAmPm(localTime).toUpperCase(),
                style: const TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.secondary,
                  letterSpacing: -0.5,
                  height: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(width: 24),

          // Flower list in the center
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: _buildFlowerRow(healthy, failed),
            ),
          ),

          // Duration / Status badge on the right
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (isFailed) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD1D1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Failed',
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF3B30),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
              ],
              Text(
                '${session.actualMinutes} mins',
                style: const TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF8E8E93),
                ),
              ),
              if (session.earnedPoints > 0) ...[
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SVG(
                      'assets/icons/point.svg',
                      width: 12,
                      height: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '+${session.earnedPoints} pts',
                      style: const TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF2E2E),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class PastDayActivityItem extends StatelessWidget {
  final PastDaySummary summary;

  const PastDayActivityItem({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    int totalHealthy = 0;
    int totalFailed = 0;
    for (final session in summary.sessions) {
      final isFailed = session.status == 'FAILED';
      final int healthy;
      final int failed;
      if (isFailed) {
        healthy = session.actualMinutes ~/ 10;
        failed = 1;
      } else {
        healthy = (session.plannedMinutes / 10).round().clamp(1, 12);
        failed = 0;
      }
      totalHealthy += healthy;
      totalFailed += failed;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFECECED), width: 1)),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                _formatDay(summary.date),
                style: TextStyle(
                  fontFamily: AppTextStyles.titleFontFamily,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary.withValues(alpha: 0.5),
                  letterSpacing: 0,
                  height: 0.85,
                ),
              ),
              Text(
                _formatMonth(summary.date),
                style: const TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.secondary,
                  letterSpacing: -0.5,
                  height: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(width: 24),

          // Flower list in the center (healthy and failed flowers for past summaries)
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: _buildFlowerRow(totalHealthy, totalFailed),
            ),
          ),
        ],
      ),
    );
  }
}
