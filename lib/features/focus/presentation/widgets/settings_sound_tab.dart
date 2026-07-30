import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lorofy/core/theme/app_theme.dart';
import 'package:lorofy/features/focus/presentation/providers/pomodoro_settings.dart';

class SettingsSoundTab extends ConsumerWidget {
  const SettingsSoundTab({super.key});

  IconData _getIconForSound(AmbientSound sound) {
    return switch (sound) {
      AmbientSound.none => CupertinoIcons.volume_off,
      AmbientSound.wind => CupertinoIcons.wind,
      AmbientSound.beach => CupertinoIcons.waveform,
      AmbientSound.nature => CupertinoIcons.leaf_arrow_circlepath,
      AmbientSound.books => CupertinoIcons.book,
      AmbientSound.fire => CupertinoIcons.flame,
      AmbientSound.rain => CupertinoIcons.cloud_rain,
      AmbientSound.cafe => CupertinoIcons.bell,
    };
  }

  String _getLabelForSound(AmbientSound sound) {
    return switch (sound) {
      AmbientSound.none => 'None',
      AmbientSound.wind => 'Wind',
      AmbientSound.beach => 'Beach',
      AmbientSound.nature => 'Nature',
      AmbientSound.books => 'Books',
      AmbientSound.fire => 'Fire',
      AmbientSound.rain => 'Rain',
      AmbientSound.cafe => 'Cafe',
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(pomodoroSettingsProvider);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: AppPadding.allMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Ambient Sound',
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.primary.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 12),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.8,
            ),
            itemCount: AmbientSound.values.length,
            itemBuilder: (context, index) {
              final sound = AmbientSound.values[index];
              final isSelected = settings.ambientSound == sound;
              final label = _getLabelForSound(sound);
              final icon = _getIconForSound(sound);

              return GestureDetector(
                onTap: () {
                  ref.read(pomodoroSettingsProvider.notifier).updateSettings(
                        settings.copyWith(ambientSound: sound),
                      );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF232321) : CupertinoColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF232321) : const Color(0xFFE5E5EA),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        icon,
                        size: 18,
                        color: isSelected ? CupertinoColors.white : const Color(0xFF232321),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          label,
                          style: TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                            color: isSelected ? CupertinoColors.white : const Color(0xFF232321),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isSelected)
                        const Icon(
                          CupertinoIcons.checkmark,
                          size: 16,
                          color: CupertinoColors.white,
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
