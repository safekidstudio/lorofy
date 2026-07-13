import 'package:flutter/cupertino.dart';
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

    // --- Cấu hình Màu sắc Border & Ring chuẩn Shadcn UI ---
    BoxBorder borderDecoration;
    if (widget.disabled) {
      borderDecoration = Border.all(
        color: AppColors.border.withValues(alpha: 0.5),
      );
    } else if (hasError) {
      borderDecoration = Border.all(color: CupertinoColors.systemRed, width: 2);
    } else if (_isFocused) {
      // Shadcn sử dụng ring màu primary khi focus
      borderDecoration = Border.all(color: AppColors.primary, width: 2);
    } else {
      borderDecoration = Border.all(color: AppColors.border);
    }

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

            // Thay đổi màu border động dựa trên state
            decoration: BoxDecoration(
              color: widget.disabled
                  ? AppColors.inputBg.withValues(alpha: 0.5)
                  : AppColors.inputBg,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: borderDecoration,
              // Tạo bóng đổ mờ nhẹ khi focus đúng chuẩn Shadcn Ring
              boxShadow: _isFocused && !hasError
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),

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
