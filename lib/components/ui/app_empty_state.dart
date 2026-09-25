import 'package:flutter/cupertino.dart';
import 'package:lorofy/components/ui/button.dart';
import 'package:lorofy/components/ui/safe_rive_animation.dart';
import 'package:lorofy/components/ui/svg_asset.dart';
import 'package:lorofy/core/theme/app_theme.dart';

/// Reusable empty state component for Lorofy application.
class AppEmptyState extends StatelessWidget {
  final String title;
  final String? description;
  final String? iconPath;
  final Widget? iconWidget;
  final String? rivePath;
  final double riveSize;
  final String? actionText;
  final VoidCallback? onActionPressed;
  final double padding;

  const AppEmptyState({
    super.key,
    required this.title,
    this.description,
    this.iconPath,
    this.iconWidget,
    this.rivePath = 'assets/rive/cat-not-track.riv',
    this.riveSize = 140.0,
    this.actionText,
    this.onActionPressed,
    this.padding = AppPadding.xl,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: padding,
          vertical: AppPadding.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon / Illustration / Rive
            if (iconWidget != null)
              iconWidget!
            else if (iconPath != null)
              SVG(
                iconPath!,
                width: riveSize,
                height: riveSize,
                color: AppColors.primary,
              )
            else if (rivePath != null && rivePath!.isNotEmpty)
              SizedBox(
                width: riveSize,
                height: riveSize,
                child: SafeRiveAnimation.asset(rivePath!, fit: BoxFit.contain),
              )
            else
              Icon(
                CupertinoIcons.square_grid_2x2,
                size: riveSize > 80 ? 64 : riveSize,
                color: AppColors.mutedForeground,
              ),

            const SizedBox(height: AppPadding.lg),

            // Title
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
              ),
            ),

            if (description != null && description!.isNotEmpty) ...[
              const SizedBox(height: AppPadding.xs),
              Text(
                description!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 14,
                  height: 1.4,
                  color: AppColors.mutedForeground,
                ),
              ),
            ],

            if (actionText != null && onActionPressed != null) ...[
              const SizedBox(height: AppPadding.lg),
              SizedBox(
                height: 44,
                child: Button.primary(
                  text: actionText!,
                  onPressed: onActionPressed,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
