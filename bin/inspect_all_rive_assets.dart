import 'dart:io';
import 'dart:convert';

void inspectFile(String path) {
  final bytes = File(path).readAsBytesSync();
  final asciiStrings = <String>[];
  final buffer = <int>[];

  for (final byte in bytes) {
    if (byte >= 32 && byte <= 126) {
      buffer.add(byte);
    } else {
      if (buffer.length >= 3) {
        final str = utf8.decode(buffer, allowMalformed: true);
        if (!asciiStrings.contains(str)) {
          asciiStrings.add(str);
        }
      }
      buffer.clear();
    }
  }

  print('\n================ $path ================');
  for (final str in asciiStrings) {
    if (str.length > 2 &&
        !str.startsWith('http') &&
        !str.contains('/') &&
        (str.contains('State') ||
            str.contains('Streak') ||
            str.contains('Flame') ||
            str.contains('confetti') ||
            str.contains('Trigger') ||
            str.contains('boo') ||
            str.contains('num') ||
            str.contains('VM') ||
            str.contains('Idle') ||
            str.contains('Circle') ||
            str.contains('Click') ||
            str.contains('Anim'))) {
      print('  - "$str"');
    }
  }
}

void main() {
  inspectFile('assets/river/fire-streak.riv');
  inspectFile('assets/river/confetti.riv');
  inspectFile('assets/river/spiro-streak.riv');
}
