import 'package:flutter/cupertino.dart';
import 'package:lorofy/components/ui/input.dart';
import 'package:lorofy/components/ui/svg_asset.dart';
import 'package:lorofy/core/theme/app_theme.dart';

class OnboardUsernameStep extends StatelessWidget {
  final bool isDisabled;
  final bool isChecking;
  final bool? isAvailable;
  final String? errorMessage;

  const OnboardUsernameStep({
    super.key,
    required this.isDisabled,
    this.isChecking = false,
    this.isAvailable,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Choose your unique handle', style: AppTextStyles.titleLarge),
        const SizedBox(height: 8),
        Text(
          'Your @username must be unique and can contain letters, numbers, and underscores.',
          style: AppTextStyles.body.copyWith(
            color: AppColors.mutedForeground,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 36),
        Input(
          placeholder: 'username',
          formControlName: 'username',
          maxLength: 30,
          disabled: isDisabled,
          prefix: Container(
            padding: const EdgeInsets.all(4),
            child: const SVG(
              'assets/icons/at-symbol.svg',
              height: 24,
              width: 24,
              color: AppColors.mutedForeground,
            ),
          ),
          suffix: isChecking
              ? const Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: CupertinoActivityIndicator(radius: 8),
                )
              : (isAvailable == true
                    ? const Padding(
                        padding: EdgeInsets.only(right: 12),
                        child: SVG(
                          'assets/icons/check.svg',
                          color: CupertinoColors.activeGreen,
                          height: 24,
                          width: 24,
                        ),
                      )
                    : null),
        ),
        if (errorMessage != null && errorMessage!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            errorMessage!,
            style: AppTextStyles.body.copyWith(
              color: CupertinoColors.systemRed,
              fontSize: 12,
            ),
          ),
        ] else if (isAvailable == true) ...[
          const SizedBox(height: 8),
          Text(
            'Username is available!',
            style: AppTextStyles.body.copyWith(
              color: CupertinoColors.activeGreen,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}
