enum MascotType {
  chicken,
  tree;

  String get displayName {
    switch (this) {
      case MascotType.chicken:
        return 'Gà Con';
      case MascotType.tree:
        return 'Cây Xanh';
    }
  }

  String get assetPath {
    switch (this) {
      case MascotType.chicken:
        // Note: Replace with actual chicken.riv path when the asset is added.
        // For now, we fallback to grow-plant.riv to avoid errors.
        return 'assets/river/grow-plant.riv';
      case MascotType.tree:
        return 'assets/river/grow-plant.riv';
    }
  }

  String get stateMachineName {
    switch (this) {
      case MascotType.chicken:
        return 'State Machine 1';
      case MascotType.tree:
        return 'State Machine 1';
    }
  }
}
