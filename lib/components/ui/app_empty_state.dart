import 'package:flutter/cupertino.dart';
import 'package:lorofy/components/ui/button.dart';
import 'package:lorofy/components/ui/safe_rive_animation.dart';
import 'package:lorofy/components/ui/svg_asset.dart';
import 'package:lorofy/core/theme/app_theme.dart';

/// Reusable empty state and error state component for Lorofy application.
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

  /// Dedicated error state variant for network failures or application errors.
  /// Tapping anywhere on the error view automatically reloads/refetches data!
  factory AppEmptyState.error({
    Key? key,
    required String title,
    String? description,
    VoidCallback? onRetry,
    double padding = AppPadding.xl,
  }) {
    return AppEmptyState(
      key: key,
      title: title,
      description:
          description ?? 'Something went wrong. Tap anywhere to reload.',
      rivePath: null,
      iconWidget: Container(
        width: 68,
        height: 68,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: const Icon(
          CupertinoIcons.exclamationmark_triangle_fill,
          color: AppColors.primary,
          size: 32,
        ),
      ),
      actionText: null, // No button rendered, tap anywhere to reload
      onActionPressed: onRetry,
      padding: padding,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Center(
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
                fontWeight: FontWeight.w600,
                color: AppColors.foreground,
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

    // If onActionPressed is provided without actionText, tap anywhere reloads
    if (onActionPressed != null && actionText == null) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onActionPressed,
        child: content,
      );
    }

    return content;
  }
}
