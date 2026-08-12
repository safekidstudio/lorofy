import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:lorofy/core/theme/app_theme.dart';
import 'package:lorofy/components/ui/svg_asset.dart';
import 'package:lorofy/components/shared/drawing_container.dart';

class SoundButton extends StatefulWidget {
  const SoundButton({super.key});

  @override
  State<SoundButton> createState() => _SoundButtonState();
}

class _SoundButtonState extends State<SoundButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  Timer? _periodicTimer;
  Timer? _hideTimer;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.1, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    // Show tooltip after 2 seconds
    _showTooltipAfterDelay(2);

    // Setup periodic check every 45 seconds to show tooltip
    _periodicTimer = Timer.periodic(const Duration(seconds: 45), (timer) {
      _showTooltip();
    });
  }

  void _showTooltipAfterDelay(int seconds) {
    Future.delayed(Duration(seconds: seconds), () {
      _showTooltip();
    });
  }

  void _showTooltip() {
    if (!mounted) return;
    setState(() {
      _isVisible = true;
    });
    _controller.forward();
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 4), () {
      _hideTooltip();
    });
  }

  void _hideTooltip() {
    if (!mounted) return;
    _controller.reverse().then((_) {
      if (mounted) {
        setState(() {
          _isVisible = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _periodicTimer?.cancel();
    _hideTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_isVisible)
          FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Stack(
                alignment: Alignment.centerRight,
                clipBehavior: Clip.none,
                children: [
                  DrawingContainer(
                    fillColor: const Color(0xFFEBEBEB),
                    padding: const EdgeInsets.only(
                      left: 12,
                      right: 18,
                      top: 8,
                      bottom: 8,
                    ),
                    child: Text(
                      'Click to change music',
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        color: const Color(0xFF7E7E7E),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                  Positioned(
                    right: -5,
                    child: CustomPaint(
                      size: const Size(6, 10),
                      painter: _TrianglePainter(
                        color: const Color(0xFFEBEBEB),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(width: 8),
        CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            _hideTooltip();
            _hideTimer?.cancel();
            context.push('/sound-settings');
          },
          child: const SVG(
            'assets/icons/sounds_drawing.svg',
            width: 24,
            height: 24,
          ),
        ),
      ],
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;

  _TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, size.height / 2)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TrianglePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
