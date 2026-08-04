import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lorofy/core/theme/app_theme.dart';
import 'package:lorofy/features/focus/presentation/providers/pomodoro_settings.dart';

class TimeDurationSection extends ConsumerWidget {
  const TimeDurationSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(pomodoroSettingsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        RichText(
          text: TextSpan(
            style: const TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Color(0xFF8E8E93),
            ),
            children: [
              const TextSpan(text: 'Time durations: '),
              TextSpan(
                text: '${settings.focusMinutes} mins',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF232321),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 32,
          child: SliderTheme(
            data: SliderThemeData(
              trackHeight: 2,
              activeTrackColor: const Color(0xFF232321),
              inactiveTrackColor: const Color(0xFFE5E5EA),
              thumbColor: const Color(0xFF232321),
              overlayColor: const Color(0xFF232321).withValues(alpha: 0.1),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
            ),
            child: Slider(
              value: settings.focusMinutes.toDouble().clamp(5.0, 180.0),
              min: 5.0,
              max: 180.0,
              onChanged: (val) {
                ref.read(pomodoroSettingsProvider.notifier).updateSettings(
                      settings.copyWith(focusMinutes: val.round()),
                    );
              },
            ),
          ),
        ),
      ],
    );
  }
}
