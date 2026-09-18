import 'package:flutter_test/flutter_test.dart';
import 'package:rive/rive.dart';
import 'dart:io' as io;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Inspect Spiro-Flame Motion v02 vs Marketplace', () async {
    await RiveNative.init();

    final loader = FileLoader.fromAsset('assets/river/spiro-streak.riv', riveFactory: Factory.rive);
    final file = await loader.file();
    if (file == null) {
      print('FAILED FILE');
      return;
    }

    final abMarket = file.artboard('Spiro-Flame Marketplace');
    final abMotion2 = file.artboard('Spiro-Flame Motion v02');
    final abMotion1 = file.artboard('Spiro-Flame Motion v01');

    void log(String msg) => io.stdout.writeln(msg);

    log('\n================ Spiro-Flame Marketplace ================');
    if (abMarket != null) {
      log('SM count: ${abMarket.stateMachineCount()}');
      for (int i = 0; i < abMarket.stateMachineCount(); i++) {
        final sm = abMarket.stateMachineAt(i);
        log('  SM [$i]: "${sm?.name}"');
      }
      log('Anim count: ${abMarket.animationCount()}');
      for (int i = 0; i < abMarket.animationCount(); i++) {
        final anim = abMarket.animationAt(i);
        log('  Anim [$i]: "${anim.name}"');
      }
    }

    log('\n================ Spiro-Flame Motion v02 ================');
    if (abMotion2 != null) {
      log('SM count: ${abMotion2.stateMachineCount()}');
      for (int i = 0; i < abMotion2.stateMachineCount(); i++) {
        final sm = abMotion2.stateMachineAt(i);
        log('  SM [$i]: "${sm?.name}"');
      }
      log('Anim count: ${abMotion2.animationCount()}');
      for (int i = 0; i < abMotion2.animationCount(); i++) {
        final anim = abMotion2.animationAt(i);
        log('  Anim [$i]: "${anim.name}"');
      }
    }

    log('\n================ Spiro-Flame Motion v01 ================');
    if (abMotion1 != null) {
      log('SM count: ${abMotion1.stateMachineCount()}');
      for (int i = 0; i < abMotion1.stateMachineCount(); i++) {
        final sm = abMotion1.stateMachineAt(i);
        log('  SM [$i]: "${sm?.name}"');
      }
      log('Anim count: ${abMotion1.animationCount()}');
      for (int i = 0; i < abMotion1.animationCount(); i++) {
        final anim = abMotion1.animationAt(i);
        log('  Anim [$i]: "${anim.name}"');
      }
    }
    log('========================================================\n');
  });
}
