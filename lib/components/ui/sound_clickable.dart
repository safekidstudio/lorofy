import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lorofy/components/ui/svg_asset.dart';

/// A reusable wrapper widget that adds a tap handler, Cupertino fade effect,
/// and plays a click sound effect.
class SoundClickable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final bool playSound;
  final double pressedOpacity;

  const SoundClickable({
    super.key,
    required this.child,
    this.onTap,
    this.playSound = true,
    this.pressedOpacity = 0.4,
  });

  @override
  State<SoundClickable> createState() => _SoundClickableState();
}

class _SoundClickableState extends State<SoundClickable> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bool isClickable = widget.onTap != null;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: isClickable ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: isClickable ? (_) => setState(() => _isPressed = false) : null,
      onTapCancel: isClickable ? () => setState(() => _isPressed = false) : null,
      onTap: isClickable
          ? () {
              if (widget.playSound) {
                print('SOUND_CLICKABLE: Playing SystemSoundType.click');
                SystemSound.play(SystemSoundType.click);
              }
              widget.onTap?.call();
            }
          : null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 50),
        opacity: _isPressed ? widget.pressedOpacity : 1.0,
        child: widget.child,
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
