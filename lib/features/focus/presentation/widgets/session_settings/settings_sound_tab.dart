import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lorofy/components/ui/svg_asset.dart';
import 'package:lorofy/core/theme/app_theme.dart';
import 'package:lorofy/features/focus/domain/models/ambient_sound.dart';
import 'package:lorofy/features/focus/domain/models/pomodoro_settings.dart';
import 'package:lorofy/features/focus/presentation/providers/pomodoro_settings.dart';
import 'package:lorofy/features/focus/presentation/providers/music_player_provider.dart';
import 'package:lorofy/features/focus/domain/models/spotify_playlist.dart';
import 'package:lorofy/features/focus/data/repositories/sound_repository_impl.dart';
import 'package:lorofy/features/focus/domain/models/ambient_sound_meta.dart';
import 'package:lorofy/features/focus/presentation/providers/pomodoro_notifier.dart';
import 'package:lorofy/features/focus/domain/models/pomodoro_state.dart';
import 'package:lorofy/components/ui/pro_upgrade_sheet.dart';
import 'package:lorofy/components/ui/bottom_player_bar.dart';
import 'package:lorofy/components/ui/button.dart';
import 'package:lorofy/components/ui/sound_clickable.dart';
import 'package:lorofy/features/focus/presentation/widgets/session_settings/playlist_detail_page.dart';

final List<SpotifySong> _recentlyPlayed = [
  const SpotifySong(
    title: 'Shawty house',
    artist: 'Mewmow',
    imageUrl:
        'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=150',
    duration: '12.30',
  ),
  const SpotifySong(
    title: 'Dopamine gold',
    artist: 'Gwogwo',
    imageUrl:
        'https://images.unsplash.com/photo-1583511655857-d19b40a7a54e?w=150',
    duration: '08.32',
  ),
];

class SettingsSoundTab extends ConsumerStatefulWidget {
  const SettingsSoundTab({super.key});

  @override
  ConsumerState<SettingsSoundTab> createState() => _SettingsSoundTabState();
}

class _SettingsSoundTabState extends ConsumerState<SettingsSoundTab> {
  bool _isPro = false;
  bool _isSpotifyConnected = false;


  @override
  void initState() {
    super.initState();
    // Settings screen is preview-only; do NOT auto-play on enter.
    // Sound will start when user explicitly taps a sound icon.
  }

  @override
  void deactivate() {
    // Only pause preview when there is no active focus session.
    // If session is running, let the sound keep playing after user backs out.
    final phase = ref.read(pomodoroTimerProvider).phase;
    if (phase != PomodoroState.focus) {
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

  void _handleConnectSpotify() {
    if (!_isPro) {
      ProUpgradeSheet.show(
        context,
        onUpgradeSuccess: () {
          setState(() {
            _isPro = true;
          });
        },
      );
    } else {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Spotify Integration'),
          content: const Text(
            'Spotify integration is currently under development. You will be able to stream music directly from your Spotify account in an upcoming update!',
          ),
          actions: [
            CupertinoDialogAction(
              child: const Text('Try Demo'),
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _isSpotifyConnected = true;
                  // Auto-play the first song as demo
                  ref
                      .read(musicPlayerProvider.notifier)
                      .play(_recentlyPlayed[0]);
                });
              },
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: const Text('Close'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    }
  }

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

                // 3. Spotify Section
                if (!_isSpotifyConnected) ...[
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
                ] else ...[
                  _buildPlaylistSection(),
                  const SizedBox(height: 24),
                  _buildRecentlySection(playerState),
                ],
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

  Widget _buildPlaylistSection() {
    final playlistsAsync = ref.watch(soundPlaylistsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Playlist',
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 12),
        playlistsAsync.when(
          loading: () => const SizedBox(
            height: 180,
            child: Center(
              child: CupertinoActivityIndicator(),
            ),
          ),
          error: (err, stack) => const SizedBox(
            height: 180,
            child: Center(
              child: Text(
                'Error loading playlist',
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  color: CupertinoColors.destructiveRed,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          data: (playlistsList) => SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: playlistsList.length,
              itemBuilder: (context, index) {
                final playlist = playlistsList[index];
                return CardActionArea(
                  onTap: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => PlaylistDetailPage(
                          playlistTitle: playlist.title,
                          songs: playlist.songs,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: 140,
                    margin: const EdgeInsets.only(right: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            playlist.imageUrl,
                            width: 140,
                            height: 120,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: 140,
                              height: 120,
                              color: const Color(0xFFE4E4E6),
                              child: const Icon(CupertinoIcons.music_note, color: AppColors.secondary),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          playlist.title,
                          style: const TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          playlist.songCount,
                          style: const TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 12,
                            color: AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentlySection(PlayerState playerState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recently',
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _recentlyPlayed.length,
          itemBuilder: (context, index) {
            final song = _recentlyPlayed[index];
            final isPlayingThis =
                playerState.currentlyPlaying?.title == song.title;

            return CardActionArea(
              onTap: () {
                ref.read(musicPlayerProvider.notifier).play(song);
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isPlayingThis
                      ? const Color(0xFFF2F4F7)
                      : const Color(0xFFF2F4F7).withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        song.imageUrl,
                        width: 44,
                        height: 44,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 44,
                          height: 44,
                          color: const Color(0xFFE4E4E6),
                          child: const Icon(
                            CupertinoIcons.music_note_2,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            song.title,
                            style: const TextStyle(
                              fontFamily: AppTextStyles.fontFamily,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            song.artist,
                            style: const TextStyle(
                              fontFamily: AppTextStyles.fontFamily,
                              fontSize: 12,
                              color: AppColors.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          CupertinoIcons.heart,
                          size: 16,
                          color: AppColors.secondary.withValues(alpha: 0.8),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          song.duration,
                          style: const TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 12,
                            color: AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
