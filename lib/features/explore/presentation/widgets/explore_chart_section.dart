import 'package:flutter/cupertino.dart';
import 'package:lorofy/core/theme/app_theme.dart';

class ExploreChartSection extends StatelessWidget {
  const ExploreChartSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Recent Focus Section Header
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Focus',
              style: TextStyle(
                fontFamily: AppTextStyles.titleFontFamily,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF232321),
              ),
            ),
            Text(
              'Daily Average 12',
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                color: Color(0xFF8E8E93),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildRecentFocusChart(),
      ],
    );
  }

  Widget _buildRecentFocusChart() {
    final List<Map<String, dynamic>> chartData = [
      {'day': '10.6', 'value': 22.0, 'active': true},
      {'day': '10.7', 'value': 10.0, 'active': true},
      {'day': '10.8', 'value': 3.0, 'active': false},
      {'day': '10.9', 'value': 14.0, 'active': true},
      {'day': '10.10', 'value': 3.0, 'active': false},
      {'day': '10.11', 'value': 10.0, 'active': true},
      {'day': '10.12', 'value': 18.0, 'active': true, 'tooltip': '20'},
    ];

    return Container(
      height: 170,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E5EA), width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: chartData.map((data) {
          final double barHeight = data['value'] * 4.5;
          final bool isActive = data['active'] as bool;
          final bool hasTooltip = data.containsKey('tooltip');

          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (hasTooltip) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF232321),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    data['tooltip'].toString(),
                    style: const TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      color: CupertinoColors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
              ],
              Container(
                width: 24,
                height: barHeight,
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFF072013)
                      : const Color(0xFFE5E5EA),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                data['day'].toString(),
                style: const TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  color: Color(0xFF8E8E93),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
