import 'dart:io';
import 'dart:convert';

void main() {
  for (final path in ['assets/river/spiro-streak.riv', 'assets/river/fire-streak.riv']) {
    final bytes = File(path).readAsBytesSync();
    print('\n======================================================');
    print('FILE: $path (${bytes.length} bytes)');
    print('======================================================');

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

    final relevant = asciiStrings.where((s) =>
        s.startsWith('Spiro') ||
        s.contains('State') ||
        s.contains('Flame') ||
        s.contains('Streak') ||
        s.contains('VM') ||
        s.contains('boo') ||
        s.contains('trig') ||
        s.contains('num') ||
        s.contains('count') ||
        s.contains('Click') ||
        s.contains('Idle') ||
        s.contains('Motion')).toList();

    print('Extracted relevant tags:');
    for (final s in relevant) {
      print('  - "$s"');
    }
  }
}
