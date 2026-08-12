import 'package:lorofy/features/focus/domain/models/spotify_playlist.dart';

abstract class SoundRepository {
  Future<List<SpotifyPlaylist>> getPlaylists();
}
