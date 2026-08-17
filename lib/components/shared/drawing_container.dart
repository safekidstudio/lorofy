import 'package:flutter/cupertino.dart';

enum DrawingShape {
  rectangular,
  blob,
}

class DrawingClipper extends CustomClipper<Path> {
  final double borderWidth;
  final double radius;
  final DrawingShape shape;

  DrawingClipper({
    required this.borderWidth,
    this.radius = 14.0,
    this.shape = DrawingShape.rectangular,
  });

  static Path getScaledPath(Size size, double borderWidth, double radius, DrawingShape shape) {
    final path = Path();
    if (shape == DrawingShape.rectangular) {
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
    } else {
      path.moveTo(53.1285, 2.58257);
      path.cubicTo(8.6957, 7.34084, 0.744564, 28.969, 2.14771, 50.1649);
      path.cubicTo(3.55085, 71.3608, 10.5666, 95.1518, 53.1285, 101.208);
      path.cubicTo(95.6905, 107.264, 98.0291, 77.4167, 101.303, 50.1649);
      path.cubicTo(104.577, 22.9132, 97.5614, -2.17571, 53.1285, 2.58257);
      path.close();

      final Matrix4 matrix = Matrix4.identity();
      matrix.setEntry(0, 0, size.width / 104.0);
      matrix.setEntry(1, 1, size.height / 104.0);
      return path.transform(matrix.storage);
    }
  }

  @override
  Path getClip(Size size) {
    return getScaledPath(size, borderWidth, radius, shape);
  }

  @override
  bool shouldReclip(covariant DrawingClipper oldClipper) {
    return oldClipper.borderWidth != borderWidth ||
        oldClipper.radius != radius ||
        oldClipper.shape != shape;
  }
}

class DrawingPainter extends CustomPainter {
  final Color? fillColor;
  final Color borderColor;
  final double borderWidth;
  final double radius;
  final DrawingShape shape;

  DrawingPainter({
    this.fillColor,
    required this.borderColor,
    required this.borderWidth,
    required this.radius,
    this.shape = DrawingShape.rectangular,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final scaledPath = DrawingClipper.getScaledPath(size, borderWidth, radius, shape);

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
        oldDelegate.radius != radius ||
        oldDelegate.shape != shape;
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
  final DrawingShape shape;

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
    this.shape = DrawingShape.rectangular,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedFillColor = fillColor != null
        ? CupertinoDynamicColor.resolve(fillColor!, context)
        : null;
    final resolvedBorderColor = borderColor != null
        ? CupertinoDynamicColor.resolve(borderColor!, context)
        : null;

    return CustomPaint(
      painter: resolvedFillColor != null && resolvedFillColor != CupertinoColors.transparent
          ? DrawingPainter(
              fillColor: resolvedFillColor,
              borderColor: CupertinoColors.transparent,
              borderWidth: 0.0,
              radius: radius,
              shape: shape,
            )
          : null,
      foregroundPainter: (resolvedBorderColor != null && resolvedBorderColor != CupertinoColors.transparent && borderWidth > 0)
          ? DrawingPainter(
              fillColor: CupertinoColors.transparent,
              borderColor: resolvedBorderColor,
              borderWidth: borderWidth,
              radius: radius,
              shape: shape,
            )
          : null,
      child: ClipPath(
        clipper: DrawingClipper(
          borderWidth: borderWidth,
          radius: radius,
          shape: shape,
        ),
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
