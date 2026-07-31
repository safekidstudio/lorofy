import 'package:flutter/cupertino.dart';
import 'package:lorofy/core/theme/app_theme.dart';

class SlidingSegmentedControl extends StatelessWidget {
  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;
  final double width;
  final double height;
  final Color backgroundColor;
  final Color activeColor;

  const SlidingSegmentedControl({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabChanged,
    this.width = 110.0,
    this.height = 28.0,
    this.backgroundColor = const Color(
      0xFFEDEEEF,
    ), // Color(0xFFE5E5EA) with alpha 0.6
    this.activeColor = const Color(0xFF072013),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      padding: EdgeInsets.all(2),
      child: Stack(
        children: [
          // Smooth Animated sliding active background block
          AnimatedAlign(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            alignment: Alignment(
              tabs.length > 1
                  ? -1.0 + (selectedIndex / (tabs.length - 1)) * 2.0
                  : 0.0,
              0.0,
            ),
            child: FractionallySizedBox(
              widthFactor: 1.0 / tabs.length,
              child: Container(
                decoration: BoxDecoration(
                  color: activeColor,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
              ),
            ),
          ),
          // Interactive tab labels
          Row(
            children: List.generate(
              tabs.length,
              (index) => Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onTabChanged(index),
                  child: Center(
                    child: Text(
                      tabs[index],
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: selectedIndex == index
                            ? CupertinoColors.white
                            : AppColors.secondary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
