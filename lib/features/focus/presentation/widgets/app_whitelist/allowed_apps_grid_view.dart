import 'package:flutter/cupertino.dart';
import 'package:lorofy/components/layout/app_header.dart';
import 'package:lorofy/components/ui/button.dart';
import 'package:lorofy/components/ui/svg_asset.dart';
import 'package:lorofy/core/services/installed_apps_service.dart';
import 'package:lorofy/core/theme/app_theme.dart';
import 'allowed_app_card.dart';

class AllowedAppsGridView extends StatelessWidget {
  final List<AppInfoItem> allowedApps;
  final Set<String> workingSelectedPackages;
  final ValueChanged<String> onTogglePackage;
  final bool isLoading;
  final bool hasChanges;
  final bool isClearAllDisabled;
  final VoidCallback onAddApps;
  final VoidCallback onSave;
  final VoidCallback onClearAll;
  final VoidCallback onClose;

  const AllowedAppsGridView({
    super.key,
    required this.allowedApps,
    required this.workingSelectedPackages,
    required this.onTogglePackage,
    required this.isLoading,
    required this.hasChanges,
    required this.isClearAllDisabled,
    required this.onAddApps,
    required this.onSave,
    required this.onClearAll,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppHeader(
          leftActions: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: onClose,
            child: const SVG(
              'assets/icons/cancel.svg',
              width: 20,
              height: 20,
            ),
          ),
          title: 'Set whitelist apps',
        ),
        const SizedBox(height: AppPadding.sm),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppPadding.xl),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Allowed apps',
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.foreground,
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: onAddApps,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: AppColors.secondary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    CupertinoIcons.add,
                    size: 20,
                    color: AppColors.foreground,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppPadding.lg),
        Expanded(
          child: isLoading
              ? const Center(child: CupertinoActivityIndicator())
              : allowedApps.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            CupertinoIcons.square_grid_2x2,
                            size: 48,
                            color: AppColors.mutedForeground,
                          ),
                          SizedBox(height: AppPadding.md),
                          Text(
                            'No allowed apps selected yet',
                            style: TextStyle(
                              fontFamily: AppTextStyles.fontFamily,
                              fontSize: 14,
                              color: AppColors.mutedForeground,
                            ),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppPadding.xl,
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.95,
                      ),
                      itemCount: allowedApps.length,
                      itemBuilder: (context, index) {
                        final app = allowedApps[index];
                        final isSelected =
                            workingSelectedPackages.contains(app.packageName);
                        return AllowedAppCard(
                          app: app,
                          isSelected: isSelected,
                          onTap: () => onTogglePackage(app.packageName),
                        );
                      },
                    ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppPadding.xl,
            vertical: AppPadding.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Button.primary(
                text: 'Save change',
                disabled: !hasChanges,
                onPressed: onSave,
              ),
              const SizedBox(height: AppPadding.sm),
              Button.secondary(
                text: 'Clear all',
                disabled: isClearAllDisabled,
                onPressed: onClearAll,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
