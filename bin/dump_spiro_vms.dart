import 'dart:io';

void main() {
  final bytes = File('assets/rive/spiro-streak.riv').readAsBytesSync();
  final asciiStrings = <String>[];
  final buffer = <int>[];

  for (final byte in bytes) {
    if (byte >= 32 && byte <= 126) {
      buffer.add(byte);
    } else {
      if (buffer.length >= 2) {
        final str = String.fromCharCodes(buffer);
        if (!asciiStrings.contains(str)) {
          asciiStrings.add(str);
        }
      }
      buffer.clear();
    }
  }

  print('================ SPIRO STREAK ALL STRINGS ================');
  for (final str in asciiStrings) {
    if (str.length >= 3 &&
        !str.startsWith('http') &&
        !str.contains('.png') &&
        !str.contains('.ttf') &&
        !str.contains('Copyright') &&
        (str.contains('VM') ||
            str.contains('Streak') ||
            str.contains('Sphere') ||
            str.contains('trig') ||
            str.contains('boo') ||
            str.contains('num') ||
            str.contains('State') ||
            str.contains('/') ||
            str.contains('Press') ||
            str.contains('Click') ||
            str.contains('Button') ||
            str.contains('Item') ||
            str.contains('count') ||
            str.contains('Count') ||
            str.contains('Flame'))) {
      print('  "$str"');
    }
  }
}
