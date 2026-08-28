import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:lorofy/features/focus/domain/models/ambient_sound.dart';
import 'package:lorofy/features/focus/domain/models/ambient_sound_meta.dart';
import 'package:lorofy/features/focus/domain/models/spotify_playlist.dart';


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
  // Cache: one AudioPlayer per asset path — never reload the same file twice
  final Map<String, AudioPlayer> _playerCache = {};
  AudioPlayer? _activePlayer;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<Duration>? _durationSubscription;

  @override
  PlayerState build() {
    // On hot restart, native audio from previous session is still running.
    // Stop all known ambient players by their fixed IDs to kill orphaned audio.
    _stopOrphanedAudio();

    ref.onDispose(() {
      _positionSubscription?.cancel();
      _durationSubscription?.cancel();
      for (final p in _playerCache.values) {
        p.dispose();
      }
      _playerCache.clear();
    });

    return const PlayerState();
  }

  /// Stops any native audio players that survived a hot restart by referencing
  /// them via the same fixed IDs we assign when creating cached players.
  void _stopOrphanedAudio() {
    for (final sound in AmbientSound.values) {
      if (sound.audioPath.isEmpty) continue;
      // Reference the native player by its deterministic ID and stop it.
      // If no such player exists natively, this is a no-op.
      final orphan = AudioPlayer(playerId: 'lorofy_${sound.audioPath}');
      orphan.stop().catchError((_) {});
    }
  }

  String? _getAssetPath(SpotifySong song) {
    if (song.isAmbient) {
      // Look up by label through AmbientSoundMeta — type-safe, no string fragility
      for (final sound in AmbientSound.values) {
        if (sound.label == song.title) {
          final path = sound.audioPath;
          return path.isEmpty ? null : path;
        }
      }
      return null;
    }
    // Fallback for Spotify demo songs: play library ambient
    return AmbientSound.books.audioPath;
  }

  Future<AudioPlayer> _getOrCreatePlayer(String assetPath) async {
    if (_playerCache.containsKey(assetPath)) {
      return _playerCache[assetPath]!;
    }
    // Use a fixed, deterministic playerId so hot restart can reference this
    // exact native player and stop it via _stopOrphanedAudio().
    final player = AudioPlayer(playerId: 'lorofy_$assetPath');
    await player.setReleaseMode(ReleaseMode.loop);
    await player.setSource(AssetSource(assetPath));
    _playerCache[assetPath] = player;
    return player;
  }

  Future<void> play(SpotifySong song) async {
    final assetPath = _getAssetPath(song);
    print('MUSIC_PLAYER: play - song: "${song.title}" (isAmbient: ${song.isAmbient}), assetPath: "$assetPath"');

    state = state.copyWith(
      currentlyPlaying: song,
      isPlaying: true,
      position: Duration.zero,
      duration: Duration.zero,
    );

    try {
      // Pause current active player if switching tracks
      if (_activePlayer != null) {
        print('MUSIC_PLAYER: play - pausing previous player');
        await _activePlayer?.pause();
      }

      // Cancel existing stream subs before switching player
      await _positionSubscription?.cancel();
      await _durationSubscription?.cancel();

      if (assetPath != null) {
        final player = await _getOrCreatePlayer(assetPath);
        _activePlayer = player;

        // Subscribe to position/duration on the new active player
        _positionSubscription = player.onPositionChanged.listen((pos) {
          state = state.copyWith(position: pos);
        });
        _durationSubscription = player.onDurationChanged.listen((dur) {
          state = state.copyWith(duration: dur);
        });

        print('MUSIC_PLAYER: play - resuming player for: $assetPath');
        await player.resume();
        print('MUSIC_PLAYER: play - successfully playing: "${song.title}"');
      } else {
        print('MUSIC_PLAYER: play - assetPath is null, nothing to play.');
      }
    } catch (e, stack) {
      print('MUSIC_PLAYER_ERROR: Failed to play song "${song.title}": $e\n$stack');
      // Silently catch audio failures in web/desktop testing environments
    }
  }

  Future<void> togglePlay() async {
    if (state.currentlyPlaying == null || _activePlayer == null) {
      print('MUSIC_PLAYER: togglePlay ignored - currentlyPlaying or _activePlayer is null');
      return;
    }

    try {
      if (state.isPlaying) {
        print('MUSIC_PLAYER: togglePlay - pausing player');
        await _activePlayer!.pause();
        state = state.copyWith(isPlaying: false);
      } else {
        print('MUSIC_PLAYER: togglePlay - resuming player');
        await _activePlayer!.resume();
        state = state.copyWith(isPlaying: true);
      }
    } catch (e, stack) {
      print('MUSIC_PLAYER_ERROR: togglePlay failed: $e\n$stack');
    }
  }

  /// Pauses audio but keeps [currentlyPlaying] intact (preview state is preserved).
  /// Use this when navigating away from settings so the user's selection is remembered.
  Future<void> pause() async {
    if (_activePlayer == null) {
      print('MUSIC_PLAYER: pause ignored - _activePlayer is null');
      return;
    }
    try {
      print('MUSIC_PLAYER: pause - pausing active player');
      await _activePlayer!.pause();
      state = state.copyWith(isPlaying: false);
    } catch (e, stack) {
      print('MUSIC_PLAYER_ERROR: pause failed: $e\n$stack');
    }
  }

  void toggleFavorite() {
    state = state.copyWith(isFavorited: !state.isFavorited);
  }

  Future<void> stop() async {
    print('MUSIC_PLAYER: stop - stopping playback');
    try {
      await _activePlayer?.pause();
      await _positionSubscription?.cancel();
      await _durationSubscription?.cancel();
      _positionSubscription = null;
      _durationSubscription = null;
      _activePlayer = null;
    } catch (e, stack) {
      print('MUSIC_PLAYER_ERROR: stop failed: $e\n$stack');
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
