import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lorofy/components/ui/svg_asset.dart';
import 'package:lorofy/core/theme/app_theme.dart';
import 'package:lorofy/features/focus/domain/enums/block_mode.dart';
import 'package:lorofy/features/focus/presentation/providers/pomodoro_settings.dart';
import 'blocked_categories_section.dart';

class AdvancedModeSection extends ConsumerStatefulWidget {
  const AdvancedModeSection({super.key});

  @override
  ConsumerState<AdvancedModeSection> createState() =>
      _AdvancedModeSectionState();
}

class _AdvancedModeSectionState extends ConsumerState<AdvancedModeSection> {
  Widget _buildAdvancedModeCard({
    required String title,
    String? badgeText,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : CupertinoColors.white,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? CupertinoColors.white
                            : AppColors.primary,
                      ),
                    ),
                  ),
                  if (isSelected)
                    const SVG(
                      'assets/icons/check.svg',
                      width: 16,
                      height: 16,
                      color: CupertinoColors.white,
                    ),
                ],
              ),
            ),
            if (badgeText != null)
              Positioned(
                top: -1,
                right: -1,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? CupertinoColors.white
                        : AppColors.primary,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(AppRadius.md),
                      bottomLeft: Radius.circular(AppRadius.md),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        badgeText,
                        style: TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: isSelected
                              ? AppColors.primary
                              : CupertinoColors.white,
                        ),
                      ),
                      const SizedBox(width: 2),
                      SVG('assets/icons/point.svg', width: 10, height: 10),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(pomodoroSettingsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Advanced mode',
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildAdvancedModeCard(
              title: 'Medium',
              isSelected: settings.blockMode == BlockMode.MEDIUM,
              onTap: () {
                ref
                    .read(pomodoroSettingsProvider.notifier)
                    .updateSettings(
                      settings.copyWith(blockMode: BlockMode.MEDIUM),
                    );
              },
            ),
            const SizedBox(width: 16),
            _buildAdvancedModeCard(
              title: 'Strict',
              badgeText: 'x1.5',
              isSelected: settings.blockMode == BlockMode.STRICT,
              onTap: () {
                ref
                    .read(pomodoroSettingsProvider.notifier)
                    .updateSettings(
                      settings.copyWith(blockMode: BlockMode.STRICT),
                    );
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SVG(
              'assets/icons/square-info.svg',
              width: 16,
              height: 16,
              color: AppColors.secondary,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                settings.blockMode == BlockMode.STRICT
                    ? 'Leaving Lorofy will instantly fail your session!'
                    : 'Block distraction apps, allow work/study apps.',
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 12,
                  color: AppColors.secondary,
                ),
              ),
            ),
          ],
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: settings.blockMode == BlockMode.MEDIUM
              ? Column(
                  key: const ValueKey('blocked_categories_section_container'),
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Container(height: 1, color: AppColors.border),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: SVG(
                            'assets/icons/chevron-down.svg',
                            color: AppColors.secondary,
                            width: 16,
                            height: 16,
                          ),
                        ),
                        Expanded(
                          child: Container(height: 1, color: AppColors.border),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const BlockedCategoriesSection(),
                  ],
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
