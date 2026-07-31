import 'package:flutter/cupertino.dart';
import 'package:lorofy/core/theme/app_theme.dart';
import 'package:lorofy/components/ui/svg_asset.dart';
import 'package:lorofy/components/ui/sliding_segmented_control.dart';

class ExploreRecordSection extends StatefulWidget {
  const ExploreRecordSection({super.key});

  @override
  State<ExploreRecordSection> createState() => _ExploreRecordSectionState();
}

class _ExploreRecordSectionState extends State<ExploreRecordSection> {
  bool _isDayToggle = true;

  final List<Map<String, dynamic>> dayRecords = const [
    {'time': '06:30', 'period': 'PM', 'flowers': 6, 'duration': '60 mins'},
    {'time': '05:00', 'period': 'PM', 'flowers': 3, 'duration': '30 mins'},
    {'time': '04:30', 'period': 'PM', 'flowers': 3, 'duration': '25 mins'},
    {'time': '02:30', 'period': 'PM', 'flowers': 2, 'duration': '15 mins'},
  ];

  final List<Map<String, dynamic>> monthRecords = const [
    {'day': '29', 'month': 'Today', 'flowers': 4},
    {'day': '28', 'month': 'Mar', 'flowers': 17},
    {'day': '27', 'month': 'Mar', 'flowers': 3},
    {'day': '26', 'month': 'Mar', 'flowers': 2},
    {'day': '25', 'month': 'Mar', 'flowers': 1},
  ];

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
          _buildFocusRecordList(),
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

  Widget _buildFocusRecordList() {
    final records = _isDayToggle ? dayRecords : monthRecords;

    return Column(
      spacing: 10,
      children: records.asMap().entries.map((entry) {
        final index = entry.key;
        final record = entry.value;
        final int flowerCount = record['flowers'] as int;

        final bool isHighlight = _isDayToggle
            ? (index == 0)
            : (record['month'] == 'Today' || index == 0);

        final Color numberColor = isHighlight
            ? AppColors.primary
            : AppColors.secondary;

        final Color labelColor = AppColors.secondary.withValues(alpha: 0.6);

        final Color durationColor = AppColors.secondary.withValues(alpha: 0.6);

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  // Left: Date or Time Column
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        _isDayToggle
                            ? record['time'].toString()
                            : record['day'].toString(),
                        style: TextStyle(
                          fontFamily: AppTextStyles.titleFontFamily,
                          fontSize: _isDayToggle ? 24 : 32,
                          color: numberColor,
                          height: 0.9,
                        ),
                      ),
                      Text(
                        _isDayToggle
                            ? record['period'].toString()
                            : record['month'].toString(),
                        style: TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 14,
                          color: labelColor,
                          fontWeight: FontWeight.w500,
                          height: 1.0,
                          leadingDistribution: TextLeadingDistribution.even,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 24),
                  // Middle: Flower streak row
                  Expanded(
                    child: Wrap(
                      spacing: _isDayToggle ? 6 : 16,
                      runSpacing: 4,
                      children: List.generate(
                        flowerCount,
                        (i) => SVG(
                          'illustrations/flower.svg',
                          width: _isDayToggle ? 30 : 44,
                          height: _isDayToggle ? 30 : 44,
                        ),
                      ),
                    ),
                  ),
                  // Right: Duration (only in Day view)
                  if (_isDayToggle) ...[
                    const SizedBox(width: 12),
                    Text(
                      record['duration'].toString(),
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 14,
                        color: durationColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Show divider between items only in Day view
            // if (_isDayToggle && index < records.length - 1)
            //   Container(height: 1, color: const Color(0xFFE2E2E2)),
          ],
        );
      }).toList(),
    );
  }
}
