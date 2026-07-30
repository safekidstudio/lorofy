import 'package:flutter/cupertino.dart';

class DrawingClipper extends CustomClipper<Path> {
  final double borderWidth;
  final double radius;

  DrawingClipper({required this.borderWidth, this.radius = 14.0});

  static Path getScaledPath(Size size, double borderWidth, double radius) {
    final path = Path();
    path.moveTo(39.3604, 2.82534);
    path.cubicTo(20.3881, 3.49093, 14.2496, 8.54224, 9.75342, 11.0667);
    path.cubicTo(-0.738024, 16.9571, -3.6035, 49.4582, 5.30929, 64.0871);
    path.cubicTo(11.3042, 71.4502, 17.7991, 70.4684, 26.2448, 70.4684);
    path.lineTo(303.038, 70.4684);
    path.cubicTo(329.538, 68.0141, 329.163, 64.0871, 331.036, 56.724);
    path.cubicTo(334.159, 44.4522, 332.535, 26.7809, 331.036, 17.4543);
    path.cubicTo(329.538, 8.12775, 325.041, 4.95184, 303.038, 3.76631);
    path.cubicTo(220.475, -0.682035, 160.753, -1.43335, 39.3604, 2.82534);
    path.close();

    final Matrix4 matrix = Matrix4.identity();
    matrix.setEntry(0, 0, size.width / 333.0);
    matrix.setEntry(1, 1, size.height / 71.0);
    return path.transform(matrix.storage);
  }

  @override
  Path getClip(Size size) {
    return getScaledPath(size, borderWidth, radius);
  }

  @override
  bool shouldReclip(covariant DrawingClipper oldClipper) {
    return oldClipper.borderWidth != borderWidth || oldClipper.radius != radius;
  }
}

class DrawingPainter extends CustomPainter {
  final Color? fillColor;
  final Color borderColor;
  final double borderWidth;
  final double radius;

  DrawingPainter({
    this.fillColor,
    required this.borderColor,
    required this.borderWidth,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final scaledPath = DrawingClipper.getScaledPath(size, borderWidth, radius);

    // Fill Path
    if (fillColor != null && fillColor != CupertinoColors.transparent) {
      final fillPaint = Paint()
        ..color = fillColor!
        ..style = PaintingStyle.fill;
      canvas.drawPath(scaledPath, fillPaint);
    }

    // Border Path
    if (borderColor != CupertinoColors.transparent && borderWidth > 0) {
      final borderPaint = Paint()
        ..color = borderColor
        ..strokeWidth = borderWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(scaledPath, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant DrawingPainter oldDelegate) {
    return oldDelegate.fillColor != fillColor ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.borderWidth != borderWidth ||
        oldDelegate.radius != radius;
  }
}

class DrawingContainer extends StatelessWidget {
  final Widget child;
  final Color? fillColor;
  final Color? borderColor;
  final double borderWidth;
  final double radius;
  final double? height;
  final double? width;
  final AlignmentGeometry? alignment;
  final EdgeInsetsGeometry? padding;

  const DrawingContainer({
    super.key,
    required this.child,
    this.fillColor,
    this.borderColor,
    this.borderWidth = 2.0,
    this.radius = 14.0,
    this.height,
    this.width,
    this.alignment,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: DrawingPainter(
        fillColor: fillColor,
        borderColor: borderColor ?? CupertinoColors.transparent,
        borderWidth: borderWidth,
        radius: radius,
      ),
      child: ClipPath(
        clipper: DrawingClipper(borderWidth: borderWidth, radius: radius),
        child: Container(
          height: height,
          width: width,
          alignment: alignment,
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
