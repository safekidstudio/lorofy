import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:lorofy/core/theme/app_theme.dart';

/// Highly customizable NumberFlow component (inspired by @number-flow/react)
/// Features real digit-spinning odometer animations, prefix/suffix support,
/// custom formatting, and pure text floating green (+)/red (-) delta popups.
class NumberFlow extends StatefulWidget {
  /// Target numerical value
  final num value;

  /// Optional initial starting value
  final num? initialValue;

  /// Primary text style for the number
  final TextStyle? style;

  /// Text prefix (e.g. "+", "$", "#")
  final String? prefix;

  /// Text suffix (e.g. " pts", "%", "m", " coins")
  final String? suffix;

  /// Custom widget rendered before the prefix/number
  final Widget? prefixWidget;

  /// Custom widget rendered after the number/suffix
  final Widget? suffixWidget;

  /// Spacing between prefixWidget, number, and suffixWidget
  final double spacing;

  /// Duration of the digit spinning animation
  final Duration duration;

  /// Curve of the digit spinning animation
  final Curve curve;

  /// Decimal places (0 for integers)
  final int fractionDigits;

  /// Whether to format with thousand separators (e.g. 1,250 vs 1250)
  final bool commaSeparator;

  /// Whether to animate on initial mount
  final bool animateOnMount;

  /// Whether to show the floating text popup (+x / -x)
  final bool enableFloatingDelta;

  /// Custom text style for the floating delta popup
  final TextStyle? floatStyle;

  const NumberFlow({
    super.key,
    required this.value,
    this.initialValue,
    this.style,
    this.prefix,
    this.suffix,
    this.prefixWidget,
    this.suffixWidget,
    this.spacing = 3.0,
    this.duration = const Duration(milliseconds: 700),
    this.curve = Curves.easeOutCubic,
    this.fractionDigits = 0,
    this.commaSeparator = true,
    this.animateOnMount = true,
    this.enableFloatingDelta = true,
    this.floatStyle,
  });

  @override
  State<NumberFlow> createState() => _NumberFlowState();
}

class _NumberFlowState extends State<NumberFlow>
    with TickerProviderStateMixin {
  late AnimationController _floatController;

  late Animation<double> _floatOffsetAnimation;
  late Animation<double> _floatOpacityAnimation;

  num _displayValue = 0;
  num _lastDelta = 0;
  bool _showFloatingText = false;
  late NumberFormat _formatter;

  @override
  void initState() {
    super.initState();
    _updateFormatter();

    _floatController = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    );

    _floatOffsetAnimation = Tween<double>(begin: 0.0, end: -36.0).animate(
      CurvedAnimation(
        parent: _floatController,
        curve: Curves.easeOutCubic,
      ),
    );

    _floatOpacityAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 15),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 45),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 40),
    ]).animate(_floatController);

    final num startValue = widget.initialValue ??
        (widget.animateOnMount && widget.value > 0
            ? (widget.value * 0.82)
            : widget.value);

    _displayValue = startValue;

    if (widget.animateOnMount && startValue != widget.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _displayValue = widget.value;
          });
        }
      });
    }
  }

  void _updateFormatter() {
    if (widget.commaSeparator) {
      if (widget.fractionDigits > 0) {
        _formatter = NumberFormat.currency(
          symbol: '',
          decimalDigits: widget.fractionDigits,
        );
      } else {
        _formatter = NumberFormat.decimalPattern();
      }
    } else {
      _formatter = NumberFormat();
      _formatter.minimumFractionDigits = widget.fractionDigits;
      _formatter.maximumFractionDigits = widget.fractionDigits;
    }
  }

  @override
  void didUpdateWidget(covariant NumberFlow oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.commaSeparator != widget.commaSeparator ||
        oldWidget.fractionDigits != widget.fractionDigits) {
      _updateFormatter();
    }

    if (widget.value != oldWidget.value) {
      final delta = widget.value - oldWidget.value;
      _lastDelta = delta;

      setState(() {
        _displayValue = widget.value;
      });

      if (widget.enableFloatingDelta && delta != 0) {
        _showFloatingText = true;
        _floatController.forward(from: 0.0).then((_) {
          if (mounted) {
            setState(() {
              _showFloatingText = false;
            });
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  String _formatNumber(num val) {
    if (widget.fractionDigits == 0) {
      return _formatter.format(val.round());
    }
    return _formatter.format(val);
  }

  @override
  Widget build(BuildContext context) {
    final defaultStyle = TextStyle(
      fontFamily: AppTextStyles.fontFamily,
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: AppColors.foreground,
    );

    final effectiveStyle = widget.style ?? defaultStyle;
    final formattedStr = _formatNumber(_displayValue);
    final prefixText = widget.prefix ?? '';
    final suffixText = widget.suffix ?? '';

    final isPositiveDelta = _lastDelta >= 0;
    final deltaSign = isPositiveDelta ? '+' : '';
    final formattedDelta = widget.fractionDigits == 0
        ? _lastDelta.round().toString()
        : _lastDelta.toStringAsFixed(widget.fractionDigits);

    final deltaColor = isPositiveDelta
        ? const Color(0xFF10B981) // Green for positive
        : const Color(0xFFEF4444); // Red for negative

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        // Main Digit Spinning Number Flow layout
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (widget.prefixWidget != null) ...[
              widget.prefixWidget!,
              SizedBox(width: widget.spacing),
            ],
            if (prefixText.isNotEmpty)
              Text(
                prefixText,
                style: effectiveStyle,
              ),
            // Digit Spinner Row
            Row(
              mainAxisSize: MainAxisSize.min,
              children: formattedStr.split('').map((char) {
                final intValue = int.tryParse(char);
                if (intValue != null) {
                  return _DigitSpinner(
                    digit: intValue,
                    style: effectiveStyle,
                    duration: widget.duration,
                    curve: widget.curve,
                  );
                } else {
                  return Text(
                    char,
                    style: effectiveStyle,
                  );
                }
              }).toList(),
            ),
            if (suffixText.isNotEmpty)
              Text(
                suffixText,
                style: effectiveStyle,
              ),
            if (widget.suffixWidget != null) ...[
              SizedBox(width: widget.spacing),
              widget.suffixWidget!,
            ],
          ],
        ),

        // Floating Text Delta (+x / -x) drifting upwards (No background badge)
        if (_showFloatingText)
          AnimatedBuilder(
            animation: _floatController,
            builder: (context, child) {
              return Positioned(
                top: _floatOffsetAnimation.value,
                child: Opacity(
                  opacity: _floatOpacityAnimation.value.clamp(0.0, 1.0),
                  child: Text(
                    '$deltaSign$formattedDelta$suffixText',
                    style: widget.floatStyle ??
                        TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: (effectiveStyle.fontSize ?? 13) * 0.9,
                          fontWeight: FontWeight.bold,
                          color: deltaColor,
                          shadows: const [
                            Shadow(
                              color: Color(0x33000000),
                              blurRadius: 4,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}

/// Single digit spinner widget that rolls numbers vertically like an odometer
class _DigitSpinner extends StatelessWidget {
  final int digit;
  final TextStyle style;
  final Duration duration;
  final Curve curve;

  const _DigitSpinner({
    required this.digit,
    required this.style,
    required this.duration,
    required this.curve,
  });

  @override
  Widget build(BuildContext context) {
    final fontSize = style.fontSize ?? 13.0;
    final lineHeight = (style.height ?? 1.2) * fontSize;

    return SizedBox(
      height: lineHeight,
      child: ClipRect(
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(end: digit.toDouble()),
          duration: duration,
          curve: curve,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, -value * lineHeight),
              child: SizedBox(
                height: lineHeight,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Non-positioned invisible digit to size the Stack width correctly
                    Opacity(
                      opacity: 0.0,
                      child: Text('0', style: style),
                    ),
                    ...List.generate(
                      10,
                      (i) => Positioned(
                        top: i * lineHeight,
                        left: 0,
                        right: 0,
                        height: lineHeight,
                        child: Center(
                          child: Text(
                            '$i',
                            style: style,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
