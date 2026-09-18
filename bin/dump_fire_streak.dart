import 'dart:io';

void main() {
  final bytes = File('assets/river/fire-streak.riv').readAsBytesSync();
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

  print('================ FIRE STREAK ALL STRINGS ================');
  for (final str in asciiStrings) {
    if (str.length >= 2 &&
        !str.startsWith('http') &&
        !str.contains('.png') &&
        !str.contains('.ttf') &&
        !str.contains('Copyright')) {
      print('  "$str"');
    }
  }
}
