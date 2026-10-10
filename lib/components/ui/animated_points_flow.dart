import 'package:flutter/cupertino.dart';
import 'package:lorofy/components/ui/number_flow.dart';
import 'package:lorofy/components/ui/svg_asset.dart';
import 'package:lorofy/core/theme/app_theme.dart';

/// Animated Points Flow Widget built on top of NumberFlow
class AnimatedPointsFlow extends StatelessWidget {
  final int value;
  final TextStyle? style;
  final String suffix;
  final bool showFlowerIcon;
  final double iconSize;
  final bool animateOnMount;
  final Color? textColor;

  const AnimatedPointsFlow({
    super.key,
    required this.value,
    this.style,
    this.suffix = 'pts',
    this.showFlowerIcon = true,
    this.iconSize = 13.0,
    this.animateOnMount = true,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveStyle = style ??
        TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          fontSize: 12,
          color: textColor ?? AppColors.mutedForeground,
          fontWeight: FontWeight.w500,
        );

    return NumberFlow(
      value: value,
      suffix: ' $suffix',
      style: effectiveStyle,
      animateOnMount: animateOnMount,
      prefixWidget: showFlowerIcon
          ? SVG(
              'assets/illustrations/flower.svg',
              width: iconSize,
              height: iconSize,
            )
          : null,
      spacing: 3.0,
    );
  }
}
