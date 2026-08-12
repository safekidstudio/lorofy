import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lorofy/features/focus/domain/models/spotify_playlist.dart';
import 'package:lorofy/features/focus/domain/repositories/sound_repository.dart';

class SoundRepositoryImpl implements SoundRepository {
  @override
  Future<List<SpotifyPlaylist>> getPlaylists() async {
    // Simulate network latency representing dynamic fetch from the server
    await Future.delayed(const Duration(milliseconds: 600));
    return const [
      SpotifyPlaylist(
        title: 'Chill lofi study playlist',
        songCount: '22 songs',
        imageUrl: 'https://images.unsplash.com/photo-1463936575829-25148e1db1b8?w=300',
        songs: [
          SpotifySong(
            title: 'Shawty house',
            artist: 'Mewmow',
            imageUrl: 'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=150',
            duration: '12.30',
          ),
          SpotifySong(
            title: 'Dopamine gold',
            artist: 'Gwogwo',
            imageUrl: 'https://images.unsplash.com/photo-1583511655857-d19b40a7a54e?w=150',
            duration: '08.32',
          ),
          SpotifySong(
            title: 'Hustle catchy',
            artist: 'Chesches',
            imageUrl: 'https://images.unsplash.com/photo-1533738363-b7f9aef128ce?w=150',
            duration: '07.34',
          ),
        ],
      ),
      SpotifyPlaylist(
        title: 'Relax vibes listening',
        songCount: '15 songs',
        imageUrl: 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=300',
        songs: [
          SpotifySong(
            title: 'Autumn leaf',
            artist: 'Hoppy',
            imageUrl: 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=150',
            duration: '05.42',
          ),
          SpotifySong(
            title: 'Chill breeze',
            artist: 'Zephyr',
            imageUrl: 'https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?w=150',
            duration: '06.15',
          ),
        ],
      ),
      SpotifyPlaylist(
        title: 'The rolling downs',
        songCount: '35 songs',
        imageUrl: 'https://images.unsplash.com/photo-1518609878373-06d740f60d8b?w=300',
        songs: [
          SpotifySong(
            title: 'Forest walk',
            artist: 'Leaf',
            imageUrl: 'https://images.unsplash.com/photo-1448375240586-882707db888b?w=150',
            duration: '10.20',
          ),
          SpotifySong(
            title: 'Sunny valley',
            artist: 'Sky',
            imageUrl: 'https://images.unsplash.com/photo-1501854140801-50d01698950b?w=150',
            duration: '08.50',
          ),
        ],
      ),
    ];
  }
}

final soundRepositoryProvider = Provider<SoundRepository>((ref) {
  return SoundRepositoryImpl();
});

final soundPlaylistsProvider = FutureProvider<List<SpotifyPlaylist>>((ref) async {
  final repository = ref.watch(soundRepositoryProvider);
  return repository.getPlaylists();
});
