import 'package:flutter/cupertino.dart';
import 'package:lorofy/components/ui/button.dart';
import 'package:lorofy/components/ui/svg_asset.dart';
import 'package:lorofy/core/theme/app_theme.dart';

/// Reusable empty state component for Lorofy application.
class AppEmptyState extends StatelessWidget {
  final String title;
  final String? description;
  final String? iconPath;
  final Widget? iconWidget;
  final String? actionText;
  final VoidCallback? onActionPressed;
  final double padding;

  const AppEmptyState({
    super.key,
    required this.title,
    this.description,
    this.iconPath,
    this.iconWidget,
    this.actionText,
    this.onActionPressed,
    this.padding = AppPadding.xl,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: padding, vertical: AppPadding.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon / Illustration
            if (iconWidget != null)
              iconWidget!
            else if (iconPath != null)
              Container(
                width: 80,
                height: 80,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.card,
                  border: Border.all(color: AppColors.border, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: CupertinoColors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: SVG(
                  iconPath!,
                  width: 44,
                  height: 44,
                  color: AppColors.primary,
                ),
              )
            else
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.card,
                  border: Border.all(color: AppColors.border, width: 1.5),
                ),
                child: const Icon(
                  CupertinoIcons.square_grid_2x2,
                  size: 36,
                  color: AppColors.mutedForeground,
                ),
              ),

            const SizedBox(height: AppPadding.lg),

            // Title
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 18,
                fontWeight: FontWeight.bold,
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
                  fontSize: 13,
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
