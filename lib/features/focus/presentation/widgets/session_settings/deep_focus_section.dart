import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lorofy/core/theme/app_theme.dart';
import 'package:lorofy/features/focus/presentation/providers/pomodoro_settings.dart';

class DeepFocusSection extends ConsumerWidget {
  const DeepFocusSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(pomodoroSettingsProvider);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Deep Focus',
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF232321),
          ),
        ),
        CupertinoSwitch(
          value: settings.isDeepFocusMode,
          activeTrackColor: const Color(0xFF071B12),
          onChanged: (val) {
            ref.read(pomodoroSettingsProvider.notifier).updateSettings(
                  settings.copyWith(isDeepFocusMode: val),
                );
          },
        ),
      ],
    );
  }
}
