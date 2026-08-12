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
