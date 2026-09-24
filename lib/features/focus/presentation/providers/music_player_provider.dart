import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audioplayers/audioplayers.dart' hide PlayerState;
import 'package:audioplayers/audioplayers.dart' as ap show PlayerState;
import 'package:lorofy/features/focus/domain/models/ambient_sound.dart';
import 'package:lorofy/features/focus/domain/models/ambient_sound_meta.dart';
import 'package:lorofy/features/focus/domain/models/spotify_playlist.dart';
import 'package:lorofy/core/utils/logger.dart';

class PlayerState {
  final SpotifySong? currentlyPlaying;
  final bool isPlaying;
  final bool isFavorited;
  final Duration position;
  final Duration duration;

  const PlayerState({
    this.currentlyPlaying,
    this.isPlaying = false,
    this.isFavorited = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
  });

  PlayerState copyWith({
    SpotifySong? currentlyPlaying,
    bool? isPlaying,
    bool? isFavorited,
    Duration? position,
    Duration? duration,
    bool clearPlaying = false,
  }) {
    return PlayerState(
      currentlyPlaying: clearPlaying
          ? null
          : (currentlyPlaying ?? this.currentlyPlaying),
      isPlaying: isPlaying ?? this.isPlaying,
      isFavorited: isFavorited ?? this.isFavorited,
      position: position ?? this.position,
      duration: duration ?? this.duration,
    );
  }
}

class MusicPlayerNotifier extends Notifier<PlayerState> {
  static const String _kPlayerId = 'lorofy_ambient_player';

  AudioPlayer? _player;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<Duration>? _durationSubscription;
  StreamSubscription<ap.PlayerState>? _stateSubscription;

  @override
  PlayerState build() {
    ref.onDispose(() {
      _positionSubscription?.cancel();
      _durationSubscription?.cancel();
      _stateSubscription?.cancel();
      _player?.stop().catchError((_) {});
      _player?.dispose().catchError((_) {});
      _player = null;
    });

    return const PlayerState();
  }

  Future<AudioPlayer> _ensurePlayer() async {
    if (_player != null) return _player!;

    final player = AudioPlayer(playerId: _kPlayerId);
    await player.setAudioContext(
      AudioContext(
        android: const AudioContextAndroid(
          stayAwake: true,
          contentType: AndroidContentType.music,
          usageType: AndroidUsageType.media,
          audioFocus: AndroidAudioFocus.none,
        ),
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playback,
          options: {AVAudioSessionOptions.mixWithOthers},
        ),
      ),
    );
    await player.setReleaseMode(ReleaseMode.loop);

    _positionSubscription = player.onPositionChanged.listen((pos) {
      state = state.copyWith(position: pos);
    });
    _durationSubscription = player.onDurationChanged.listen((dur) {
      state = state.copyWith(duration: dur);
    });
    _stateSubscription = player.onPlayerStateChanged.listen((pState) {
      final isPlaying = pState == ap.PlayerState.playing;
      if (state.isPlaying != isPlaying) {
        state = state.copyWith(isPlaying: isPlaying);
      }
    });

    _player = player;
    return player;
  }

  String? _getAssetPath(SpotifySong song) {
    if (song.isAmbient) {
      for (final sound in AmbientSound.values) {
        if (sound.label == song.title) {
          final path = sound.audioPath;
          return path.isEmpty ? null : path;
        }
      }
      return null;
    }
    return AmbientSound.books.audioPath;
  }

  Future<void> play(SpotifySong song) async {
    final assetPath = _getAssetPath(song);
    AppLogger.debug('play - song: "${song.title}" (isAmbient: ${song.isAmbient}), assetPath: "$assetPath"', tag: 'MusicPlayer');

    state = state.copyWith(
      currentlyPlaying: song,
      isPlaying: true,
      position: Duration.zero,
      duration: Duration.zero,
    );

    try {
      if (assetPath != null) {
        final player = await _ensurePlayer();
        await player.setSource(AssetSource(assetPath));
        await player.resume();
        AppLogger.debug('play - successfully playing: "${song.title}"', tag: 'MusicPlayer');
      } else {
        AppLogger.debug('play - assetPath is null, nothing to play.', tag: 'MusicPlayer');
      }
    } catch (e, stack) {
      AppLogger.error('Failed to play song "${song.title}"', error: e, stackTrace: stack, tag: 'MusicPlayer');
    }
  }

  Future<void> togglePlay() async {
    if (state.currentlyPlaying == null) {
      AppLogger.debug('togglePlay ignored - currentlyPlaying is null', tag: 'MusicPlayer');
      return;
    }

    try {
      final player = await _ensurePlayer();
      if (state.isPlaying) {
        AppLogger.debug('togglePlay - pausing player', tag: 'MusicPlayer');
        await player.pause();
        state = state.copyWith(isPlaying: false);
      } else {
        AppLogger.debug('togglePlay - resuming player', tag: 'MusicPlayer');
        if (player.source == null) {
          final assetPath = _getAssetPath(state.currentlyPlaying!);
          if (assetPath != null) {
            await player.setSource(AssetSource(assetPath));
          }
        }
        await player.resume();
        state = state.copyWith(isPlaying: true);
      }
    } catch (e, stack) {
      AppLogger.error('togglePlay failed', error: e, stackTrace: stack, tag: 'MusicPlayer');
    }
  }

  /// Pauses audio but keeps [currentlyPlaying] intact (preview state is preserved).
  Future<void> pause() async {
    if (_player == null) {
      AppLogger.debug('pause ignored - _player is null', tag: 'MusicPlayer');
      return;
    }
    try {
      AppLogger.debug('pause - pausing player', tag: 'MusicPlayer');
      await _player!.pause();
      state = state.copyWith(isPlaying: false);
    } catch (e, stack) {
      AppLogger.error('pause failed', error: e, stackTrace: stack, tag: 'MusicPlayer');
    }
  }

  void toggleFavorite() {
    state = state.copyWith(isFavorited: !state.isFavorited);
  }

  Future<void> stop() async {
    AppLogger.debug('stop - stopping playback', tag: 'MusicPlayer');
    try {
      await _player?.stop();
    } catch (e, stack) {
      AppLogger.error('stop failed', error: e, stackTrace: stack, tag: 'MusicPlayer');
    }
    state = state.copyWith(
      clearPlaying: true,
      isPlaying: false,
      position: Duration.zero,
      duration: Duration.zero,
    );
  }
}

final musicPlayerProvider = NotifierProvider<MusicPlayerNotifier, PlayerState>(
  () {
    return MusicPlayerNotifier();
  },
);
