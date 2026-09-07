enum BlockMode {
  medium,
  strict,
}

extension BlockModeExtension on BlockMode {
  String get value {
    switch (this) {
      case BlockMode.medium:
        return 'MEDIUM';
      case BlockMode.strict:
        return 'STRICT';
    }
  }
}
