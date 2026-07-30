import 'package:flutter/cupertino.dart';

class Carousel extends StatelessWidget {
  final List<Widget> children;
  final PageController controller;
  final ValueChanged<int>? onPageChanged;
  final ScrollPhysics? physics;

  const Carousel({
    super.key,
    required this.children,
    required this.controller,
    this.onPageChanged,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: controller,
      onPageChanged: onPageChanged,
      physics: physics ?? const BouncingScrollPhysics(),
      children: children,
    );
  }
}

/// CarouselIndicator độc lập có thể đặt ở bất kỳ đâu và tùy biến vị trí thoải mái
class CarouselIndicator extends StatelessWidget {
  final int count;
  final int currentIndex;
  final Color activeColor;
  final Color inactiveColor;
  final double dotSize;
  final double activeWidth;

  const CarouselIndicator({
    super.key,
    required this.count,
    required this.currentIndex,
    this.activeColor = CupertinoColors.white,
    this.inactiveColor = const Color(0x66FFFFFF),
    this.dotSize = 4.0,
    this.activeWidth = 20.0,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isSelected = index == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: isSelected ? activeWidth : dotSize,
          height: dotSize,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: isSelected ? activeColor : inactiveColor,
            borderRadius: BorderRadius.circular(dotSize / 2),
          ),
        );
      }),
    );
  }
}
