import 'package:flutter/material.dart';

/// A continuous physical wheel NumberFlow animation widget.
/// Rolls changing digits (e.g. 1 -> 2) continuously like a real iOS / Vercel wheel strip,
/// while keeping unchanged digits (e.g. tens digit 0) completely static.
class NumberFlowText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Duration duration;
  final Curve curve;

  const NumberFlowText({
    super.key,
    required this.text,
    required this.style,
    this.duration = const Duration(milliseconds: 500),
    this.curve = Curves.easeOutCubic,
  });

  @override
  Widget build(BuildContext context) {
    final characters = text.split('');

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: List.generate(characters.length, (index) {
        final char = characters[index];
        final digit = int.tryParse(char);

        if (digit == null) {
          return Text(char, style: style);
        }

        return _OdometerDigitColumn(
          digit: digit,
          style: style,
          duration: duration,
          curve: curve,
        );
      }),
    );
  }
}

class _OdometerDigitColumn extends StatelessWidget {
  final int digit;
  final TextStyle style;
  final Duration duration;
  final Curve curve;

  const _OdometerDigitColumn({
    required this.digit,
    required this.style,
    required this.duration,
    required this.curve,
  });

  @override
  Widget build(BuildContext context) {
    final fontSize = style.fontSize ?? 116.0;
    // Add 12px vertical headroom for the solid drop shadow (offset Y=8)
    final itemHeight = (fontSize * (style.height ?? 1.0)) + 12.0;

    // Find maximum width across all digits 0-9 for this style
    double maxDigitWidth = 0.0;
    for (int i = 0; i <= 9; i++) {
      final tp = TextPainter(
        text: TextSpan(text: '$i', style: style),
        textDirection: TextDirection.ltr,
      )..layout();
      if (tp.width > maxDigitWidth) {
        maxDigitWidth = tp.width;
      }
    }
    // Add 6px horizontal padding so side-bearings are safe without making digits too wide apart
    final digitWidth = maxDigitWidth + 6.0;

    return SizedBox(
      width: digitWidth,
      height: itemHeight,
      child: ClipRect(
        clipBehavior: Clip.hardEdge,
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(end: digit.toDouble()),
          duration: duration,
          curve: curve,
          builder: (context, value, child) {
            return Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  top: -value * itemHeight,
                  left: 0,
                  right: 0,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(10, (i) {
                      return SizedBox(
                        width: digitWidth,
                        height: itemHeight,
                        child: Center(child: Text('$i', style: style)),
                      );
                    }),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
