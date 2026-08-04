enum BlockMode {
  MEDIUM,
  STRICT,
}

extension BlockModeExtension on BlockMode {
  String get value {
    switch (this) {
      case BlockMode.MEDIUM:
        return 'MEDIUM';
      case BlockMode.STRICT:
        return 'STRICT';
    }
  }
}
