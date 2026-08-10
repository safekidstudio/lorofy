import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smooth_sheets/smooth_sheets.dart';
import 'package:lorofy/components/ui/svg_asset.dart';
import 'package:lorofy/components/layout/app_header.dart';
import 'package:lorofy/core/theme/app_theme.dart';
import 'package:lorofy/features/focus/domain/enums/block_mode.dart';
import 'package:lorofy/features/focus/presentation/providers/pomodoro_settings.dart';
import 'select_allowed_apps_sheet.dart';

class BlockModeSelectionSheet extends ConsumerWidget {
  const BlockModeSelectionSheet({super.key});

  void _openSelectAllowedApps(BuildContext context) {
    Navigator.push(
      context,
      CupertinoModalSheetRoute(
        builder: (context) => const Sheet(
          decoration: MaterialSheetDecoration(
            size: SheetSize.fit,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            color: Color(0xFFF6F6F6),
          ),
          child: SelectAllowedAppsSheet(),
        ),
      ),
    );
  }

  Widget _buildMediumModeCard({
    required BuildContext context,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF071B12) : CupertinoColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF071B12)
                : const Color(0xFFE5E5EA),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Medium Mode',
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected ? CupertinoColors.white : AppColors.primary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'In focus, only whitelisted apps can be opened',
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 12,
                color: isSelected
                    ? CupertinoColors.white.withValues(alpha: 0.8)
                    : AppColors.secondary,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(height: 12),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => _openSelectAllowedApps(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: CupertinoColors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Select allowed apps',
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF071B12),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStrictModeCard({
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF071B12)
                  : CupertinoColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF071B12)
                    : const Color(0xFFE5E5EA),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Strict Mode',
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? CupertinoColors.white
                        : AppColors.primary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'In focus, opening other apps kill the plant',
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 12,
                    color: isSelected
                        ? CupertinoColors.white.withValues(alpha: 0.8)
                        : AppColors.secondary,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: -1,
            right: -1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? CupertinoColors.white
                    : CupertinoColors.white,
                borderRadius: BorderRadius.circular(12),
                border: isSelected
                    ? null
                    : Border.all(color: const Color(0xFFE5E5EA), width: 1.5),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'x1.5',
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? const Color(0xFF071B12)
                          : AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const SVG(
                    'assets/icons/point.svg',
                    width: 10,
                    height: 10,
                    color: CupertinoColors.systemRed,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(pomodoroSettingsProvider);
    final isMedium = settings.blockMode == BlockMode.MEDIUM;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF6F6F6),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppHeader(
              leftActions: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => Navigator.pop(context),
                child: const SVG(
                  'assets/icons/cancel.svg',
                  width: 20,
                  height: 20,
                ),
              ),
              title: 'Focus Mode',
            ),
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: AppPadding.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Medium Mode Card
                    _buildMediumModeCard(
                      context: context,
                      isSelected: isMedium,
                      onTap: () {
                        ref
                            .read(pomodoroSettingsProvider.notifier)
                            .updateSettings(
                              settings.copyWith(blockMode: BlockMode.MEDIUM),
                            );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Strict Mode Card
                    _buildStrictModeCard(
                      isSelected: !isMedium,
                      onTap: () {
                        ref
                            .read(pomodoroSettingsProvider.notifier)
                            .updateSettings(
                              settings.copyWith(blockMode: BlockMode.STRICT),
                            );
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
