import 'package:flutter/cupertino.dart';
import 'package:lorofy/core/theme/app_theme.dart';

class Logo extends StatelessWidget {
  final double fontSize;
  final Color color;

  const Logo({
    super.key,
    this.fontSize = 28.0,
    this.color = const Color(0xFF232321),
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      'lorofy.',
      style: TextStyle(
        fontFamily: AppTextStyles.titleFontFamily,
        fontSize: fontSize,
        fontWeight: FontWeight.w900,
        color: color,
        letterSpacing: -1.0,
      ),
    );
  }
}
