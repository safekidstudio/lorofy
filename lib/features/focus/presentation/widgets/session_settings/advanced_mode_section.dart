import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smooth_sheets/smooth_sheets.dart';
import 'package:lorofy/components/ui/svg_asset.dart';
import 'package:lorofy/core/theme/app_theme.dart';
import 'package:lorofy/features/focus/domain/enums/block_mode.dart';
import 'package:lorofy/features/focus/presentation/providers/pomodoro_settings.dart';
import 'block_mode_selection_sheet.dart';
import 'select_allowed_apps_sheet.dart';

class AdvancedModeSection extends ConsumerWidget {
  const AdvancedModeSection({super.key});

  void _openBlockModeSelection(BuildContext context) {
    Navigator.push(
      context,
      CupertinoModalSheetRoute(
        builder: (context) => const Sheet(
          decoration: MaterialSheetDecoration(
            size: SheetSize.stretch,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            color: Color(0xFFF6F6F6),
          ),
          child: BlockModeSelectionSheet(),
        ),
      ),
    );
  }

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(pomodoroSettingsProvider);
    final isStrict = settings.blockMode == BlockMode.STRICT;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Block Mode',
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
              ),
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => _openBlockModeSelection(context),
              child: Container(
                width: 32,
                height: 32,
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFFE5E5EA),
                  shape: BoxShape.circle,
                ),
                child: const SVG(
                  'assets/icons/setting.svg',
                  width: 16,
                  height: 16,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Active Mode Card
        GestureDetector(
          onTap: () => _openBlockModeSelection(context),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF071B12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isStrict ? 'Strict Mode' : 'Medium Mode',
                      style: const TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isStrict
                          ? 'In focus, opening other apps kill the plant'
                          : 'In focus, only whitelisted apps can be opened',
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 12,
                        color: CupertinoColors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    if (!isStrict) ...[
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
                if (isStrict)
                  Positioned(
                    top: -1,
                    right: -1,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: CupertinoColors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'x1.5',
                            style: TextStyle(
                              fontFamily: AppTextStyles.fontFamily,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF071B12),
                            ),
                          ),
                          SizedBox(width: 4),
                          SVG(
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
          ),
        ),
      ],
    );
  }
}
