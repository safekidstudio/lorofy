import 'package:lorofy/features/mascot/domain/models/mascot_stage.dart';
import 'package:lorofy/features/mascot/domain/models/mascot_type.dart';

class Mascot {
  final String id;
  final String name;
  final MascotType type;
  final int currentPoints;
  final int pointsToLevel2;
  final int pointsToLevel3;
  final bool isUnlocked;
  final int unlockCostPoints;

  const Mascot({
    required this.id,
    required this.name,
    required this.type,
    this.currentPoints = 0,
    this.pointsToLevel2 = 100,
    this.pointsToLevel3 = 300,
    this.isUnlocked = false,
    required this.unlockCostPoints,
  });

  MascotStage get currentStage {
    if (currentPoints < pointsToLevel2) {
      return MascotStage.level1;
    } else if (currentPoints < pointsToLevel3) {
      return MascotStage.level2;
    } else {
      return MascotStage.level3;
    }
  }

  /// Calculates the progress ratio [0.0, 1.0] of growth within the current stage.
  double get stageProgressRatio {
    switch (currentStage) {
      case MascotStage.level1:
        if (pointsToLevel2 <= 0) return 1.0;
        return (currentPoints / pointsToLevel2).clamp(0.0, 1.0);
      case MascotStage.level2:
        final range = pointsToLevel3 - pointsToLevel2;
        if (range <= 0) return 1.0;
        final elapsed = currentPoints - pointsToLevel2;
        return (elapsed / range).clamp(0.0, 1.0);
      case MascotStage.level3:
        return 1.0;
    }
  }

  Mascot copyWith({
    String? id,
    String? name,
    MascotType? type,
    int? currentPoints,
    int? pointsToLevel2,
    int? pointsToLevel3,
    bool? isUnlocked,
    int? unlockCostPoints,
  }) {
    return Mascot(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      currentPoints: currentPoints ?? this.currentPoints,
      pointsToLevel2: pointsToLevel2 ?? this.pointsToLevel2,
      pointsToLevel3: pointsToLevel3 ?? this.pointsToLevel3,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockCostPoints: unlockCostPoints ?? this.unlockCostPoints,
    );
  }
}
