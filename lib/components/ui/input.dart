import 'package:flutter/cupertino.dart';
import 'package:lorofy/components/shared/drawing_container.dart';
import 'package:lorofy/components/ui/svg_asset.dart';
import 'package:lorofy/core/theme/app_theme.dart';
import 'package:reactive_forms/reactive_forms.dart';

class Input extends StatefulWidget {
  final String? label;
  final String placeholder;
  final TextEditingController? controller;
  final String? formControlName;
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
    this.controller,
    this.formControlName,
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
  late bool _obscureText;
  TextEditingController? _reactiveController;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
    _obscureText = widget.obscureText;
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    _reactiveController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.formControlName != null) {
      return ReactiveFormField<String, String>(
        formControlName: widget.formControlName,
        builder: (field) {
          if (_reactiveController == null) {
            _reactiveController = TextEditingController(text: field.value ?? '');
            _reactiveController!.addListener(() {
              if (field.value != _reactiveController!.text) {
                field.didChange(_reactiveController!.text);
              }
            });
          } else if (field.value != _reactiveController!.text) {
            final text = field.value ?? '';
            _reactiveController!.text = text;
            _reactiveController!.selection = TextSelection.collapsed(offset: text.length);
          }

          final controlDisabled = field.control.disabled;
          return _buildTextField(
            context,
            _reactiveController!,
            field.errorText,
            disabledOverride: controlDisabled,
          );
        },
      );
    } else {
      return _buildTextField(
        context,
        widget.controller ?? TextEditingController(),
        widget.errorMessage,
      );
    }
  }

  Widget _buildTextField(
    BuildContext context,
    TextEditingController controller,
    String? errorMsg, {
    bool disabledOverride = false,
  }) {
    final bool isDisabled = widget.disabled || disabledOverride;
    final hasError = errorMsg != null && errorMsg.isNotEmpty;

    // --- Cấu hình Màu sắc Border & Ring vẽ tay ---
    Color borderColor;
    double borderWidth;

    if (isDisabled) {
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

    // Resolve the input background color against context
    final resolvedBg = CupertinoDynamicColor.resolve(
      AppColors.inputBg,
      context,
    );
    final fillColor = resolvedBg;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. Label
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: AppTextStyles.label.copyWith(
              color: isDisabled
                  ? AppColors.primary.withValues(alpha: 0.5)
                  : (hasError ? CupertinoColors.systemRed : null),
            ),
          ),
          const SizedBox(height: 6),
        ],

        // 2. Ô Input chính
        Opacity(
          opacity: isDisabled ? 0.8 : 1.0,
          child: DrawingContainer(
            fillColor: fillColor,
            borderColor: borderColor,
            borderWidth: borderWidth,
            child: CupertinoTextField(
              focusNode: _focusNode,
              controller: controller,
              placeholder: widget.placeholder,
              obscureText: _obscureText,
              keyboardType: widget.keyboardType,
              enabled: !isDisabled,
              onChanged: widget.onChanged,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
              placeholderStyle: AppTextStyles.placeholder.copyWith(
                fontSize: 16,
                color: CupertinoColors.placeholderText,
              ),
              style: AppTextStyles.body.copyWith(
                fontSize: 16,
                color: isDisabled ? AppColors.secondary : AppColors.primary,
              ),
              decoration: const BoxDecoration(
                color: CupertinoColors.transparent,
              ),
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
                  : (widget.obscureText
                      ? GestureDetector(
                          onTap: () {
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: SVG(
                              _obscureText
                                  ? 'assets/icons/eye-close.svg'
                                  : 'assets/icons/eye.svg',
                              width: 20,
                              height: 20,
                              color: AppColors.secondary,
                            ),
                          ),
                        )
                      : null),
            ),
          ),
        ),

        // 4. Error Message
        if (hasError) ...[
          const SizedBox(height: 6),
          Text(
            errorMsg,
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
