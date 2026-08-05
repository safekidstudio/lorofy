import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  const PlayerState({
    this.currentlyPlaying,
    this.isPlaying = false,
    this.isFavorited = false,
  });

  PlayerState copyWith({
    SpotifySong? currentlyPlaying,
    bool? isPlaying,
    bool? isFavorited,
    bool clearPlaying = false,
  }) {
    return PlayerState(
      currentlyPlaying: clearPlaying ? null : (currentlyPlaying ?? this.currentlyPlaying),
      isPlaying: isPlaying ?? this.isPlaying,
      isFavorited: isFavorited ?? this.isFavorited,
    );
  }
}

class MusicPlayerNotifier extends Notifier<PlayerState> {
  @override
  PlayerState build() {
    return const PlayerState();
  }

  void play(SpotifySong song) {
    state = state.copyWith(currentlyPlaying: song, isPlaying: true);
  }

  void togglePlay() {
    state = state.copyWith(isPlaying: !state.isPlaying);
  }

  void toggleFavorite() {
    state = state.copyWith(isFavorited: !state.isFavorited);
  }

  void stop() {
    state = state.copyWith(clearPlaying: true, isPlaying: false);
  }
}

final musicPlayerProvider = NotifierProvider<MusicPlayerNotifier, PlayerState>(() {
  return MusicPlayerNotifier();
});
