import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lorofy/components/ui/svg_asset.dart';
import 'package:lorofy/core/services/feedback/feedback_provider.dart';

/// A reusable wrapper widget that adds tap feedback:
/// - Smooth visual scale micro-animation (0.96x on press)
/// - Subtile opacity dimming
/// - Tactile Haptic Feedback
/// - Zero-latency click audio sound
class SoundClickable extends ConsumerStatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final bool playSound;
  final bool playHaptic;
  final double pressedOpacity;
  final double pressedScale;
  final bool enableScaleAnimation;

  const SoundClickable({
    super.key,
    required this.child,
    this.onTap,
    this.playSound = true,
    this.playHaptic = true,
    this.pressedOpacity = 0.85,
    this.pressedScale = 0.96,
    this.enableScaleAnimation = true,
  });

  @override
  ConsumerState<SoundClickable> createState() => _SoundClickableState();
}

class _SoundClickableState extends ConsumerState<SoundClickable> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bool isClickable = widget.onTap != null;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: isClickable
          ? (_) {
              setState(() => _isPressed = true);
              ref.read(feedbackServiceProvider).playClick(
                    sound: widget.playSound,
                    haptic: widget.playHaptic,
                  );
            }
          : null,
      onTapUp: isClickable ? (_) => setState(() => _isPressed = false) : null,
      onTapCancel: isClickable ? () => setState(() => _isPressed = false) : null,
      onTap: isClickable
          ? () {
              widget.onTap?.call();
            }
          : null,
      child: AnimatedScale(
        scale: (isClickable && _isPressed && widget.enableScaleAnimation)
            ? widget.pressedScale
            : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOutQuad,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 100),
          opacity: (isClickable && _isPressed) ? widget.pressedOpacity : 1.0,
          child: widget.child,
        ),
      ),
    );
  }
}

/// A standard, styled Back Button for Lorofy pages that plays a click sound.
class AppBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color backgroundColor;

  const AppBackButton({
    super.key,
    this.onPressed,
    this.backgroundColor = const Color(0xFFE4E4E6),
  });

  @override
  Widget build(BuildContext context) {
    return SoundClickable(
      onTap: onPressed ?? () {
        if (context.canPop()) {
          context.pop();
        }
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
        child: const SVG(
          'assets/icons/chevron-left.svg',
          width: 24,
          height: 24,
        ),
      ),
    );
  }
}

/// A Cupertino-friendly action area wrapper for cards and list items.
/// Dims the child subtly when pressed (pressedOpacity defaults to 0.8)
/// and triggers the click sound effect.
class CardActionArea extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final bool playSound;
  final double pressedOpacity;

  const CardActionArea({
    super.key,
    required this.child,
    this.onTap,
    this.playSound = true,
    this.pressedOpacity = 0.8, // Subtle dimming is better for large card items
  });

  @override
  Widget build(BuildContext context) {
    return SoundClickable(
      onTap: onTap,
      playSound: playSound,
      pressedOpacity: pressedOpacity,
      child: child,
    );
  }
}
