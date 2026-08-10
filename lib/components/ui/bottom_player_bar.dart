import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lorofy/core/theme/app_theme.dart';
import 'package:lorofy/features/focus/presentation/providers/music_player_provider.dart';
import 'package:lorofy/features/focus/presentation/providers/pomodoro_notifier.dart';
import 'package:lorofy/features/focus/domain/models/pomodoro_state.dart';
import 'package:lorofy/components/ui/svg_asset.dart';

class BottomPlayerBar extends ConsumerWidget {
  const BottomPlayerBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(musicPlayerProvider);
    if (playerState.currentlyPlaying == null) return const SizedBox.shrink();

    final phase = ref.watch(pomodoroTimerProvider).phase;
    final isSessionActive = phase == PomodoroState.focus;

    final song = playerState.currentlyPlaying!;

    double progress = 0.0;
    if (playerState.duration.inMilliseconds > 0) {
      progress =
          playerState.position.inMilliseconds /
          playerState.duration.inMilliseconds;
    }
    progress = progress.clamp(0.0, 1.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Dynamic Progress Bar
        Container(
          height: 3,
          width: double.infinity,
          color: const Color(0xFFE4E4E6),
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: progress,
            child: Container(color: AppColors.primary),
          ),
        ),
        // Main player bar content
        Container(
          color: CupertinoColors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: song.isAmbient
                    ? Container(
                        width: 44,
                        height: 44,
                        color: const Color(0xFFE4E4E6),
                        padding: const EdgeInsets.all(10),
                        child: SVG(
                          song.imageUrl,
                          width: 24,
                          height: 24,
                          color: AppColors.primary,
                        ),
                      )
                    : Image.network(
                        song.imageUrl,
                        width: 44,
                        height: 44,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 44,
                          height: 44,
                          color: const Color(0xFFE4E4E6),
                          child: const Icon(
                            CupertinoIcons.music_note,
                            size: 20,
                          ),
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      song.title,
                      style: const TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      song.artist,
                      style: const TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 12,
                        color: AppColors.secondary,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      ref.read(musicPlayerProvider.notifier).togglePlay();
                    },
                    child: Icon(
                      playerState.isPlaying
                          ? CupertinoIcons.pause_fill
                          : CupertinoIcons.play_fill,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: () {
                      ref.read(musicPlayerProvider.notifier).toggleFavorite();
                    },
                    child: Icon(
                      playerState.isFavorited
                          ? CupertinoIcons.heart_fill
                          : CupertinoIcons.heart,
                      color: playerState.isFavorited
                          ? CupertinoColors.systemRed
                          : AppColors.secondary,
                      size: 22,
                    ),
                  ),
                  // Show check button only in preview/settings mode (not during active session)
                  if (!isSessionActive) ...[  
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () => ref.read(musicPlayerProvider.notifier).stop(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Color(0xFF232321),
                          shape: BoxShape.circle,
                        ),
                        child: const SVG(
                          'icons/check.svg',
                          width: 16,
                          height: 16,
                          color: CupertinoColors.white,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
