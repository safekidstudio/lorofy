import 'package:flutter/cupertino.dart';
import 'package:lorofy/core/theme/app_theme.dart';

class ExploreRecordSection extends StatefulWidget {
  const ExploreRecordSection({super.key});

  @override
  State<ExploreRecordSection> createState() => _ExploreRecordSectionState();
}

class _ExploreRecordSectionState extends State<ExploreRecordSection> {
  bool _isDayToggle = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Focus Record Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Focus Record',
              style: TextStyle(
                fontFamily: AppTextStyles.titleFontFamily,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF232321),
              ),
            ),
            _buildRecordToggle(),
          ],
        ),
        const SizedBox(height: 16),
        _buildFocusRecordList(),
      ],
    );
  }

  Widget _buildRecordToggle() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F7),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => setState(() => _isDayToggle = true),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _isDayToggle
                    ? const Color(0xFF232321)
                    : CupertinoColors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Day',
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: _isDayToggle
                      ? CupertinoColors.white
                      : const Color(0xFF8E8E93),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _isDayToggle = false),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: !_isDayToggle
                    ? const Color(0xFF232321)
                    : CupertinoColors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Month',
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: !_isDayToggle
                      ? CupertinoColors.white
                      : const Color(0xFF8E8E93),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFocusRecordList() {
    final List<Map<String, dynamic>> records = [
      {'time': '06:30 PM', 'flowers': 6, 'duration': '60 mins'},
      {'time': '05:00 PM', 'flowers': 3, 'duration': '30 mins'},
      {'time': '04:30 PM', 'flowers': 3, 'duration': '25 mins'},
      {'time': '02:30 PM', 'flowers': 2, 'duration': '15 mins'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E5EA), width: 1.5),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: records.asMap().entries.map((entry) {
          final index = entry.key;
          final record = entry.value;
          final int flowerCount = record['flowers'] as int;

          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    record['time'].toString(),
                    style: const TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      color: Color(0xFF232321),
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: List.generate(
                      flowerCount,
                      (i) => const Text('🌷 ', style: TextStyle(fontSize: 14)),
                    ),
                  ),
                  Text(
                    record['duration'].toString(),
                    style: const TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      color: Color(0xFF8E8E93),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              if (index < records.length - 1)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Container(height: 1, color: const Color(0xFFE5E5EA)),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
