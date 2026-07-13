import 'package:flutter/cupertino.dart';
import 'package:lorofy/core/theme/app_theme.dart';

enum ButtonVariant { primary, secondary, outline, ghost, link, destructive }

class Button extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final Widget? prefix;
  final Widget? suffix;
  final bool isLoading;
  final bool disabled;

  const Button({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.prefix,
    this.suffix,
    this.isLoading = false,
    this.disabled = false,
  });

  // --- Factory Constructors cho việc gọi nhanh chuẩn Shadcn ---
  factory Button.primary({
    required String text,
    VoidCallback? onPressed,
    Widget? prefix,
    Widget? suffix,
    bool isLoading = false,
    bool disabled = false,
  }) => Button(
    text: text,
    onPressed: onPressed,
    variant: ButtonVariant.primary,
    prefix: prefix,
    suffix: suffix,
    isLoading: isLoading,
    disabled: disabled,
  );

  factory Button.secondary({
    required String text,
    VoidCallback? onPressed,
    Widget? prefix,
    Widget? suffix,
    bool isLoading = false,
    bool disabled = false,
  }) => Button(
    text: text,
    onPressed: onPressed,
    variant: ButtonVariant.secondary,
    prefix: prefix,
    suffix: suffix,
    isLoading: isLoading,
    disabled: disabled,
  );

  factory Button.outline({
    required String text,
    VoidCallback? onPressed,
    Widget? prefix,
    Widget? suffix,
    bool isLoading = false,
    bool disabled = false,
  }) => Button(
    text: text,
    onPressed: onPressed,
    variant: ButtonVariant.outline,
    prefix: prefix,
    suffix: suffix,
    isLoading: isLoading,
    disabled: disabled,
  );

  factory Button.destructive({
    required String text,
    VoidCallback? onPressed,
    Widget? prefix,
    Widget? suffix,
    bool isLoading = false,
    bool disabled = false,
  }) => Button(
    text: text,
    onPressed: onPressed,
    variant: ButtonVariant.destructive,
    prefix: prefix,
    suffix: suffix,
    isLoading: isLoading,
    disabled: disabled,
  );

  factory Button.ghost({
    required String text,
    VoidCallback? onPressed,
    Widget? prefix,
    Widget? suffix,
    bool isLoading = false,
    bool disabled = false,
  }) => Button(
    text: text,
    onPressed: onPressed,
    variant: ButtonVariant.ghost,
    prefix: prefix,
    suffix: suffix,
    isLoading: isLoading,
    disabled: disabled,
  );

  factory Button.link({
    required String text,
    VoidCallback? onPressed,
    Widget? prefix,
    Widget? suffix,
    bool isLoading = false,
    bool disabled = false,
  }) => Button(
    text: text,
    onPressed: onPressed,
    variant: ButtonVariant.link,
    prefix: prefix,
    suffix: suffix,
    isLoading: isLoading,
    disabled: disabled,
  );

  @override
  Widget build(BuildContext context) {
    // Kiểm tra trạng thái vô hiệu hóa (Khi đang load hoặc dev chủ động disable)
    final bool isButtonDisabled = disabled || isLoading || onPressed == null;

    // Định nghĩa màu sắc theo Style Shadcn
    Color backgroundColor = CupertinoColors.transparent;
    Color textColor = AppColors.primary;
    Border? border;

    switch (variant) {
      case ButtonVariant.primary:
        backgroundColor = AppColors.primary;
        textColor = AppColors.background;
        break;
      case ButtonVariant.secondary:
        backgroundColor = AppColors.card; // Hoặc AppColors.secondary tùy dự án
        textColor = AppColors.primary;
        break;
      case ButtonVariant.destructive:
        backgroundColor = CupertinoColors.systemRed; // Màu đỏ đặc trưng xóa/hủy
        textColor = CupertinoColors.white;
        break;
      case ButtonVariant.outline:
        backgroundColor = CupertinoColors.transparent;
        textColor = AppColors.primary;
        border = Border.all(color: AppColors.border, width: 1);
        break;
      case ButtonVariant.ghost:
        backgroundColor = CupertinoColors.transparent;
        textColor = AppColors.primary;
        break;
      case ButtonVariant.link:
        backgroundColor = CupertinoColors.transparent;
        textColor = AppColors.primary;
        break;
    }

    return Opacity(
      // Shadcn giảm độ mờ (0.5) khi button bị disabled
      opacity: isButtonDisabled ? 0.5 : 1.0,
      child: CupertinoButton(
        padding: EdgeInsets.zero, // Triệt tiêu padding mặc định của Cupertino
        onPressed: isButtonDisabled ? null : onPressed,
        minimumSize: Size(
          0,
          0,
        ), // Cho phép container quyết định độ cao tối thiểu
        focusNode: FocusNode(skipTraversal: true),
        child: Container(
          height: variant == ButtonVariant.link ? null : 56,
          padding: variant == ButtonVariant.link
              ? EdgeInsets.zero
              : const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          decoration: variant == ButtonVariant.link
              ? null
              : BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: border,
                ),
          child: isLoading
              ? CupertinoActivityIndicator(
                  color: textColor,
                ) // Hiện loading spinner
              : Row(
                  mainAxisSize: MainAxisSize
                      .min, // Giúp button co giãn theo nội dung nếu cần
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Prefix Icon
                    if (prefix != null) ...[prefix!, const SizedBox(width: 8)],
                    // Text chính
                    Text(
                      text,
                      style: AppTextStyles.buttonText.copyWith(
                        color: textColor,
                        decoration: variant == ButtonVariant.link
                            ? TextDecoration.underline
                            : TextDecoration.none,
                      ),
                    ),
                    // Suffix Icon
                    if (suffix != null) ...[const SizedBox(width: 8), suffix!],
                  ],
                ),
        ),
      ),
    );
  }
}
