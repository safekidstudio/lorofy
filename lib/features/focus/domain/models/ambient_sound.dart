enum AmbientSound { none, wind, beach, nature, books, fire, rain, cafe }

extension AmbientSoundX on AmbientSound {
  String get displayName {
    switch (this) {
      case AmbientSound.none:
        return 'None';
      case AmbientSound.wind:
        return 'Wind Breeze';
      case AmbientSound.beach:
        return 'Ocean Waves';
      case AmbientSound.nature:
        return 'Forest Nature';
      case AmbientSound.books:
        return 'Library Ambience';
      case AmbientSound.fire:
        return 'Cozy Fireplace';
      case AmbientSound.rain:
        return 'Soft Rain';
      case AmbientSound.cafe:
        return 'Warm Café';
    }
  }
}
