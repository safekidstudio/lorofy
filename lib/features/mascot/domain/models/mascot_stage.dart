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
            return 'Trứng Gà';
          case MascotStage.level2:
            return 'Gà Con';
          case MascotStage.level3:
            return 'Gà Trưởng Thành';
        }
      case MascotType.tree:
        switch (this) {
          case MascotStage.level1:
            return 'Hạt Giống';
          case MascotStage.level2:
            return 'Mầm Cây';
          case MascotStage.level3:
            return 'Cây Trưởng Thành';
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
