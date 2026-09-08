import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lorofy/components/ui/svg_asset.dart';
import 'package:lorofy/core/theme/app_theme.dart';
import 'package:lorofy/features/focus/domain/models/ambient_sound.dart';
import 'package:lorofy/features/focus/domain/models/pomodoro_settings.dart';
import 'package:lorofy/features/focus/presentation/providers/pomodoro_settings.dart';
import 'package:lorofy/features/focus/presentation/providers/music_player_provider.dart';
import 'package:lorofy/features/focus/domain/models/ambient_sound_meta.dart';
import 'package:lorofy/features/focus/presentation/providers/pomodoro_notifier.dart';
import 'package:lorofy/features/focus/domain/models/pomodoro_state.dart';
// import 'package:lorofy/components/ui/pro_upgrade_sheet.dart';
import 'package:lorofy/components/ui/bottom_player_bar.dart';
// import 'package:lorofy/components/ui/button.dart';

class SettingsSoundTab extends ConsumerStatefulWidget {
  const SettingsSoundTab({super.key});

  @override
  ConsumerState<SettingsSoundTab> createState() => _SettingsSoundTabState();
}

class _SettingsSoundTabState extends ConsumerState<SettingsSoundTab> {

  @override
  void initState() {
    super.initState();
    // Settings screen is preview-only; do NOT auto-play on enter.
    // Sound will start when user explicitly taps a sound icon.
  }

  @override
  void deactivate() {
    // Only pause preview when there is no active focus/break session.
    // If session is running, let the sound keep playing after user backs out.
    final phase = ref.read(pomodoroTimerProvider).phase;
    if (phase != PomodoroState.focus && phase != PomodoroState.breakTime) {
      ref.read(musicPlayerProvider.notifier).pause();
    }
    super.deactivate();
  }

  void _onAmbientSoundTap(AmbientSound sound, PomodoroSettings settings) {
    ref
        .read(pomodoroSettingsProvider.notifier)
        .updateSettings(settings.copyWith(ambientSound: sound));

    if (sound == AmbientSound.none) {
      ref.read(musicPlayerProvider.notifier).stop();
    } else {
      ref.read(musicPlayerProvider.notifier).play(sound.toSong());
    }
  }

  /*
  void _handleConnectSpotify() {
    ProUpgradeSheet.show(context);
  }
  */

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(pomodoroSettingsProvider);
    final playerState = ref.watch(musicPlayerProvider);

    return Stack(
      children: [
        Positioned.fill(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.only(
              left: AppPadding.lg,
              right: AppPadding.lg,
              top: AppPadding.lg,
              bottom: playerState.currentlyPlaying != null
                  ? 100.0
                  : AppPadding.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 2. Centered Sound Grid (using Wrap for compact centering)
                Center(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 16,
                    runSpacing: 16,
                    children: List.generate(AmbientSound.values.length, (index) {
                      final sound = AmbientSound.values[index];
                      final isSelected = settings.ambientSound == sound;
                      final iconPath = sound.iconPath;

                      return GestureDetector(
                        onTap: () => _onAmbientSoundTap(sound, settings),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? AppColors.primary
                                : const Color(0xFFE4E4E6),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : const Color(0xFFE5E5EA),
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: SVG(
                              iconPath,
                              width: 24,
                              height: 24,
                              color: isSelected
                                  ? CupertinoColors.white
                                  : AppColors.primary,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 32),

                // 3. Spotify Section (Temporarily commented out)
                /*
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Connect your Spotify',
                        style: TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: 160,
                        child: Button.primary(
                          text: 'Connect',
                          prefix: const Icon(
                            CupertinoIcons.music_note,
                            color: CupertinoColors.white,
                            size: 18,
                          ),
                          onPressed: _handleConnectSpotify,
                        ),
                      ),
                    ],
                  ),
                ),
                */
              ],
            ),
          ),
        ),

        // 4. Sound Player at the bottom
        if (playerState.currentlyPlaying != null)
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: BottomPlayerBar(),
          ),
      ],
    );
  }
}
