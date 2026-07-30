import 'package:flutter/cupertino.dart';
import 'package:lorofy/core/theme/app_theme.dart';

class WavyDividerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE2E2E2)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final double h = size.height * 0.5;
    final double w = size.width;

    // A smooth wavy line
    path.moveTo(0, h);
    path.quadraticBezierTo(w * 0.25, h - 3, w * 0.5, h);
    path.quadraticBezierTo(w * 0.75, h + 3, w, h);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class WavyDivider extends StatelessWidget {
  final String text;

  const WavyDivider({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CustomPaint(
            size: const Size(double.infinity, 12),
            painter: WavyDividerPainter(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            text,
            style: const TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 14,
              color: Color(0xFF8E8E93),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: CustomPaint(
            size: const Size(double.infinity, 12),
            painter: WavyDividerPainter(),
          ),
        ),
      ],
    );
  }
}
