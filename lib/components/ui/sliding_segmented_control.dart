import 'package:flutter/cupertino.dart';
import 'package:lorofy/components/ui/sound_clickable.dart';
import 'package:lorofy/core/theme/app_theme.dart';

class SlidingSegmentedControl extends StatelessWidget {
  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;
  final double? width;
  final double? height;
  final Color backgroundColor;
  final Color activeColor;
  final Color activeTextColor;
  final Color inactiveTextColor;

  const SlidingSegmentedControl({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabChanged,
    this.width,
    this.height,
    this.backgroundColor = const Color(0xFFEDEEEF),
    this.activeColor = const Color(0xFF072013),
    this.activeTextColor = CupertinoColors.white,
    this.inactiveTextColor = AppColors.secondary,
  });

  @override
  Widget build(BuildContext context) {
    Widget control = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      padding: const EdgeInsets.all(2),
      child: IntrinsicHeight(
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
                heightFactor: 1.0,
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
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                tabs.length,
                (index) => Expanded(
                  child: CardActionArea(
                    onTap: () => onTabChanged(index),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 12,
                      ),
                      child: Center(
                        child: Text(
                          tabs[index],
                          style: TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: selectedIndex == index
                                ? activeTextColor
                                : inactiveTextColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (width == null) {
      control = IntrinsicWidth(child: control);
    }

    return control;
  }
}
