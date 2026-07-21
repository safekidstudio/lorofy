import 'package:flutter/cupertino.dart';
import 'package:lorofy/components/ui/drawing_container.dart';
import 'package:lorofy/core/theme/app_theme.dart';

class Input extends StatefulWidget {
  final String? label;
  final String placeholder;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final String? errorMessage;
  final bool disabled;
  final Widget? prefix;
  final Widget? suffix;
  final ValueChanged<String>? onChanged;
  final FocusNode? focusNode;

  const Input({
    super.key,
    this.label,
    required this.placeholder,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.errorMessage,
    this.disabled = false,
    this.prefix,
    this.suffix,
    this.onChanged,
    this.focusNode,
  });

  @override
  State<Input> createState() => _InputState();
}

class _InputState extends State<Input> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  void dispose() {
    // Nếu focusNode truyền từ ngoài vào thì không tự dispose ở đây
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasError =
        widget.errorMessage != null && widget.errorMessage!.isNotEmpty;

    // --- Cấu hình Màu sắc Border & Ring vẽ tay ---
    Color borderColor;
    double borderWidth;

    if (widget.disabled) {
      borderColor = CupertinoColors.transparent;
      borderWidth = 0.0;
    } else if (hasError) {
      borderColor = CupertinoColors.systemRed;
      borderWidth = 2.0;
    } else if (_isFocused) {
      borderColor = const Color(0xFF232321);
      borderWidth = 2.0;
    } else {
      borderColor = CupertinoColors.transparent;
      borderWidth = 0.0;
    }

    final fillColor = widget.disabled
        ? const Color(0xFFCDCDD0) // solid medium grey for disabled state
        : const Color(0xFFE4E4E6);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. Label (Ẩn hoàn toàn nếu không truyền vào)
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: AppTextStyles.label.copyWith(
              color: widget.disabled
                  ? AppColors.primary.withValues(alpha: 0.5)
                  : (hasError ? CupertinoColors.systemRed : null),
            ),
          ),
          const SizedBox(height: 6),
        ],

        // 2. Ô Input chính với hiệu ứng Opacity khi Disabled
        Opacity(
          opacity: widget.disabled ? 0.6 : 1.0,
          child: DrawingContainer(
            fillColor: fillColor,
            borderColor: borderColor,
            borderWidth: borderWidth,
            child: CupertinoTextField(
              focusNode: _focusNode,
              controller: widget.controller,
              placeholder: widget.placeholder,
              obscureText: widget.obscureText,
              keyboardType: widget.keyboardType,
              enabled: !widget.disabled,
              onChanged: widget.onChanged,

              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
              placeholderStyle: AppTextStyles.placeholder.copyWith(
                fontSize: 16,
                color: CupertinoColors.placeholderText,
              ),
              style: AppTextStyles.body.copyWith(fontSize: 16),
              decoration: null, // Clear standard border/decorations

              // 3. Tích hợp Prefix & Suffix lọt lòng vào trong ô Input
              prefix: widget.prefix != null
                  ? Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: widget.prefix,
                    )
                  : null,
              suffix: widget.suffix != null
                  ? Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: widget.suffix,
                    )
                  : null,
            ),
          ),
        ),

        // 4. Error Message hiển thị phía dưới ô Input
        if (hasError) ...[
          const SizedBox(height: 6),
          Text(
            widget.errorMessage!,
            style: AppTextStyles.body.copyWith(
              color: CupertinoColors.systemRed,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ],
    );
  }
}
