enum BlockMode {
  LIGHT,
  MEDIUM,
  STRICT,
}

extension BlockModeExtension on BlockMode {
  String get value {
    switch (this) {
      case BlockMode.LIGHT:
        return 'LIGHT';
      case BlockMode.MEDIUM:
        return 'MEDIUM';
      case BlockMode.STRICT:
        return 'STRICT';
    }
  }
}
