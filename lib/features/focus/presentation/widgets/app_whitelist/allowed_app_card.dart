import 'package:flutter/cupertino.dart';
import 'package:lorofy/components/ui/svg_asset.dart';
import 'package:lorofy/core/services/installed_apps_service.dart';
import 'package:lorofy/core/theme/app_theme.dart';

class AllowedAppCard extends StatelessWidget {
  final AppInfoItem app;
  final bool isSelected;
  final VoidCallback onTap;

  const AllowedAppCard({
    super.key,
    required this.app,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected ? AppColors.foreground : AppColors.border,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Opacity(
          opacity: isSelected ? 1.0 : 0.45,
          child: Stack(
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppPadding.sm),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: app.icon != null
                            ? Image.memory(
                                app.icon!,
                                fit: BoxFit.cover,
                              )
                            : const Icon(
                                CupertinoIcons.app_fill,
                                size: 32,
                                color: AppColors.secondaryForeground,
                              ),
                      ),
                      const SizedBox(height: AppPadding.sm),
                      Text(
                        app.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.cardForeground,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (isSelected)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    width: 18,
                    height: 18,
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: AppColors.foreground,
                      shape: BoxShape.circle,
                    ),
                    child: const SVG(
                      'assets/icons/check.svg',
                      width: 12,
                      height: 12,
                      color: AppColors.primaryForeground,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
