import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:lorofy/core/theme/app_theme.dart';

class OtpInput extends StatelessWidget {
  final int length;
  final Function(String) onCodeCompleted;
  final Function(String)? onChanged;
  final bool hasError;

  const OtpInput({
    super.key,
    this.length = 6,
    required this.onCodeCompleted,
    this.onChanged,
    this.hasError = false,
  });

  @override
  Widget build(BuildContext context) {
    // Cấu hình Default Pin Theme chuẩn thiết kế Shadcn/Lorofy
    final defaultPinTheme = PinTheme(
      width: 52,
      height: 56,
      textStyle: AppTextStyles.body.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: AppColors.primary,
      ),
      decoration: BoxDecoration(
        color: AppColors.inputBg,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: AppColors.border,
          width: 1.5,
        ),
      ),
    );

    // Trạng thái Focus (Active)
    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(
          color: AppColors.primary,
          width: 2,
        ),
      ),
    );

    // Trạng thái Error (Sai mã)
    final errorPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(
          color: CupertinoColors.systemRed,
          width: 2,
        ),
      ),
    );

    return Material(
      type: MaterialType.transparency,
      child: Pinput(
        length: length,
        defaultPinTheme: defaultPinTheme,
        focusedPinTheme: focusedPinTheme,
        errorPinTheme: errorPinTheme,
        forceErrorState: hasError,
        onCompleted: onCodeCompleted,
        onChanged: onChanged,
        showCursor: true,
        hapticFeedbackType: HapticFeedbackType.lightImpact,
      ),
    );
  }
}
