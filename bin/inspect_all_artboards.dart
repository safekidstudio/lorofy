import 'dart:io';
import 'dart:convert';

void main() {
  final bytes = File('assets/river/grow-plant.riv').readAsBytesSync();
  print('\n======================================================');
  print('FILE: grow-plant.riv (${bytes.length} bytes)');
  print('======================================================');

  final asciiStrings = <String>[];
  final buffer = <int>[];

  for (final byte in bytes) {
    if (byte >= 32 && byte <= 126) {
      buffer.add(byte);
    } else {
      if (buffer.length >= 2) {
        final str = utf8.decode(buffer, allowMalformed: true);
        if (!asciiStrings.contains(str)) {
          asciiStrings.add(str);
        }
      }
      buffer.clear();
    }
  }

  print('Extracted strings:');
  for (final s in asciiStrings.where((s) => s.length >= 2)) {
    print('  - "$s"');
  }
}
