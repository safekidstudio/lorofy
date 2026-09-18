import 'dart:io' as io;
import 'package:flutter_test/flutter_test.dart';
import 'package:rive/rive.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Inspect Spiro-Flame Marketplace State Machine and ViewModels', () async {
    await RiveNative.init();

    final fileLoader = FileLoader.fromAsset('assets/river/spiro-streak.riv', riveFactory: Factory.rive);
    final file = await fileLoader.file();
    if (file == null) {
      print('FAILED TO LOAD FILE');
      return;
    }

    final ab = file.artboard('Spiro-Flame Marketplace');
    if (ab == null) {
      print('Artboard Spiro-Flame Marketplace NOT FOUND');
      return;
    }

    print('\n==================== Spiro-Flame Marketplace ====================');
    final smCount = ab.stateMachineCount();
    print('State Machine Count: $smCount');
    for (int sm = 0; sm < smCount; sm++) {
      final machine = ab.stateMachineAt(sm);
      if (machine != null) {
        print('StateMachine [$sm]: "${machine.name}"');
      }
    }

    print('\nAnimations:');
    for (int a = 0; a < ab.animationCount(); a++) {
      final anim = ab.animationAt(a);
      print('  Animation [$a]: "${anim.name}"');
    }

    print('=================================================================\n');
  });
}
