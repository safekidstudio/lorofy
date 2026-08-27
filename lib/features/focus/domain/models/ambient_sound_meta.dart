import 'package:lorofy/features/focus/domain/models/ambient_sound.dart';
import 'package:lorofy/features/focus/domain/models/spotify_playlist.dart';

/// Central source-of-truth for all AmbientSound metadata.
/// Use this instead of duplicating switch/map expressions across files.
class AmbientSoundMeta {
  final AmbientSound sound;
  final String label;
  final String iconPath;   // SVG asset path (no 'assets/' prefix)
  final String audioPath;  // MP3 asset path (no 'assets/' prefix)

  const AmbientSoundMeta._({
    required this.sound,
    required this.label,
    required this.iconPath,
    required this.audioPath,
  });

  static const Map<AmbientSound, AmbientSoundMeta> _map = {
    AmbientSound.none: AmbientSoundMeta._(
      sound: AmbientSound.none,
      label: 'None',
      iconPath: 'assets/icons/sounds/none.svg',
      audioPath: '',
    ),
    AmbientSound.wind: AmbientSoundMeta._(
      sound: AmbientSound.wind,
      label: 'Wind',
      iconPath: 'assets/icons/sounds/wind.svg',
      audioPath: 'sounds/wind.mp3',
    ),
    AmbientSound.beach: AmbientSoundMeta._(
      sound: AmbientSound.beach,
      label: 'Beach',
      iconPath: 'assets/icons/sounds/beach.svg',
      audioPath: 'sounds/beach.mp3',
    ),
    AmbientSound.nature: AmbientSoundMeta._(
      sound: AmbientSound.nature,
      label: 'Nature',
      iconPath: 'assets/icons/sounds/nature.svg',
      audioPath: 'sounds/forest.mp3',
    ),
    AmbientSound.books: AmbientSoundMeta._(
      sound: AmbientSound.books,
      label: 'Library',
      iconPath: 'assets/icons/sounds/library.svg',
      audioPath: 'sounds/library.mp3',
    ),
    AmbientSound.fire: AmbientSoundMeta._(
      sound: AmbientSound.fire,
      label: 'Fire',
      iconPath: 'assets/icons/sounds/fire.svg',
      audioPath: 'sounds/fire.mp3',
    ),
    AmbientSound.rain: AmbientSoundMeta._(
      sound: AmbientSound.rain,
      label: 'Rain',
      iconPath: 'assets/icons/sounds/rain.svg',
      audioPath: 'sounds/rain.mp3',
    ),
    AmbientSound.cafe: AmbientSoundMeta._(
      sound: AmbientSound.cafe,
      label: 'Coffee',
      iconPath: 'assets/icons/sounds/coffee.svg',
      audioPath: 'sounds/coffee-shop.mp3',
    ),
  };

  /// Get metadata for a given [AmbientSound].
  static AmbientSoundMeta of(AmbientSound sound) => _map[sound]!;

  /// Convert an [AmbientSound] into a [SpotifySong] ready for the music player.
  static SpotifySong toSong(AmbientSound sound) {
    final meta = of(sound);
    return SpotifySong(
      title: meta.label,
      artist: 'Ambient Sound',
      imageUrl: meta.iconPath,
      duration: '--.--',
      isAmbient: true,
    );
  }
}

/// Extension for convenience directly on the enum.
extension AmbientSoundX on AmbientSound {
  AmbientSoundMeta get meta => AmbientSoundMeta.of(this);
  String get label => meta.label;
  String get iconPath => meta.iconPath;
  String get audioPath => meta.audioPath;
  SpotifySong toSong() => AmbientSoundMeta.toSong(this);
}
