import 'package:lorofy/features/mascot/domain/models/mascot_type.dart';

enum MascotStage {
  level1,
  level2,
  level3;

  String getDisplayName(MascotType type) {
    switch (type) {
      case MascotType.chicken:
        switch (this) {
          case MascotStage.level1:
            return 'Egg';
          case MascotStage.level2:
            return 'Chick';
          case MascotStage.level3:
            return 'Adult Chick';
        }
      case MascotType.tree:
        switch (this) {
          case MascotStage.level1:
            return 'Seed';
          case MascotStage.level2:
            return 'Sprout';
          case MascotStage.level3:
            return 'Adult Tree';
        }
    }
  }

  int get levelValue {
    switch (this) {
      case MascotStage.level1:
        return 0;
      case MascotStage.level2:
        return 1;
      case MascotStage.level3:
        return 2;
    }
  }
}
