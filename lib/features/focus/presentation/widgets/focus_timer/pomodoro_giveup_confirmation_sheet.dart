import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lorofy/components/ui/button.dart';
import 'package:lorofy/components/ui/svg_asset.dart';
import 'package:lorofy/core/theme/app_theme.dart';
import 'package:lorofy/features/focus/domain/enums/block_mode.dart';
import 'package:lorofy/features/focus/presentation/providers/pomodoro_notifier.dart';
import 'package:lorofy/features/focus/presentation/providers/pomodoro_settings.dart';
import 'package:lorofy/features/settings/presentation/providers/system_settings_provider.dart';


class PomodoroGiveupConfirmationSheet extends ConsumerWidget {
  const PomodoroGiveupConfirmationSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(pomodoroSettingsProvider);
    final systemSettings = ref.watch(systemSettingsProvider);
    final isStrict = settings.isDeepFocusMode && settings.blockMode == BlockMode.strict;
    final penaltyPoints = isStrict
        ? systemSettings.penaltyPointsStrict
        : systemSettings.penaltyPointsMedium;

    final timerState = ref.watch(pomodoroTimerProvider);
    final elapsedSeconds = timerState.totalSessionSeconds - timerState.countdownSeconds;
    final isGracePeriod = elapsedSeconds < 60;


    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min, // Dynamically wrap height around content
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle at the top
            Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E5EA),
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Mockup Title Text
            const Text(
              'Do you want to give up\nthis session?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTextStyles.titleFontFamily,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF232321),
                height: 1.2,
              ),
            ),
            const SizedBox(height: 20),

            // Cat knocking over coffee SVG illustration
            Center(
              child: const SVG(
                'assets/illustrations/overview.svg',
                width: 160,
                height: 160,
              ),
            ),
            const SizedBox(height: 20),

            // Consequence info box
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('🥀 ', style: TextStyle(fontSize: 14)),
                      Text(
                        'Your tree will wither',
                        style: TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.destructive,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  if (isGracePeriod)
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('🛡️ ', style: TextStyle(fontSize: 14)),
                        Text(
                          'Grace period (< 60s): No point penalty',
                          style: TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF00B894),
                          ),
                        ),
                      ],
                    )
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('🪙 ', style: TextStyle(fontSize: 14)),
                        Text(
                          'You will lose -$penaltyPoints Points (${isStrict ? "STRICT" : "MEDIUM"})',
                          style: const TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Actions
            Row(
              children: [
                Expanded(
                  child: Button.primary(
                    text: 'Give up',
                    onPressed: () => Navigator.pop(context, true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Button.secondary(
                    text: 'Cancel',
                    onPressed: () => Navigator.pop(context, false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
