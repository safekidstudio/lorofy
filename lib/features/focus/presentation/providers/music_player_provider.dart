import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:lorofy/features/focus/domain/models/ambient_sound_meta.dart';
import 'package:lorofy/features/focus/presentation/providers/pomodoro_settings.dart';

class SpotifySong {
  final String title;
  final String artist;
  final String imageUrl;
  final String duration;
  final bool isAmbient;

  const SpotifySong({
    required this.title,
    required this.artist,
    required this.imageUrl,
    required this.duration,
    this.isAmbient = false,
  });
}

class SpotifyPlaylist {
  final String title;
  final String songCount;
  final String imageUrl;
  final List<SpotifySong> songs;

  const SpotifyPlaylist({
    required this.title,
    required this.songCount,
    required this.imageUrl,
    required this.songs,
  });
}

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

    state = state.copyWith(
      currentlyPlaying: song,
      isPlaying: true,
      position: Duration.zero,
      duration: Duration.zero,
    );

    try {
      // Pause current active player if switching tracks
      await _activePlayer?.pause();

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

        await player.resume();
      }
    } catch (e) {
      // Silently catch audio failures in web/desktop testing environments
    }
  }

  Future<void> togglePlay() async {
    if (state.currentlyPlaying == null || _activePlayer == null) return;

    try {
      if (state.isPlaying) {
        await _activePlayer!.pause();
        state = state.copyWith(isPlaying: false);
      } else {
        await _activePlayer!.resume();
        state = state.copyWith(isPlaying: true);
      }
    } catch (e) {
      // Catch exceptions
    }
  }

  /// Pauses audio but keeps [currentlyPlaying] intact (preview state is preserved).
  /// Use this when navigating away from settings so the user's selection is remembered.
  Future<void> pause() async {
    if (_activePlayer == null) return;
    try {
      await _activePlayer!.pause();
      state = state.copyWith(isPlaying: false);
    } catch (e) {
      // Catch exceptions
    }
  }

  void toggleFavorite() {
    state = state.copyWith(isFavorited: !state.isFavorited);
  }

  Future<void> stop() async {
    try {
      await _activePlayer?.pause();
      await _positionSubscription?.cancel();
      await _durationSubscription?.cancel();
      _positionSubscription = null;
      _durationSubscription = null;
      _activePlayer = null;
    } catch (e) {
      // Catch exceptions
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
