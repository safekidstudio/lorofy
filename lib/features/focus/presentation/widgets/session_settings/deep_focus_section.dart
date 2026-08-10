import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lorofy/components/ui/svg_asset.dart';
import 'package:smooth_sheets/smooth_sheets.dart';
import 'package:lorofy/components/ui/app_switch.dart';
import 'package:lorofy/core/theme/app_theme.dart';
import 'package:lorofy/features/focus/presentation/providers/pomodoro_settings.dart';
import 'edit_breaks_and_rounds_sheet.dart';

class DeepFocusSection extends ConsumerWidget {
  const DeepFocusSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(pomodoroSettingsProvider);
    final isPomodoroMode = !settings.isDeepFocusMode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Pomodoro Mode',
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
              ),
            ),
            AppSwitch(
              value: isPomodoroMode,
              onChanged: (val) {
                ref
                    .read(pomodoroSettingsProvider.notifier)
                    .updateSettings(settings.copyWith(isDeepFocusMode: !val));
              },
            ),
          ],
        ),
        if (isPomodoroMode) ...[
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Break: ${settings.breakMinutes}m  ·  Target: ${settings.targetRounds}r',
                style: const TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
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
                        child: EditBreaksAndRoundsSheet(),
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE4E4E6),
                    shape: BoxShape.circle,
                  ),
                  child: const SVG(
                    "assets/icons/setting.svg",
                    width: 12,
                    height: 12,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
