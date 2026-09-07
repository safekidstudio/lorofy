import 'package:lorofy/features/mascot/domain/models/mascot.dart';
import 'package:lorofy/features/mascot/domain/models/mascot_type.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'mascot_notifier.g.dart';

class MascotState {
  final String? activeMascotId;
  final List<Mascot> mascots;
  final int userPoints;

  const MascotState({
    this.activeMascotId,
    required this.mascots,
    required this.userPoints,
  });

  MascotState copyWith({
    String? activeMascotId,
    List<Mascot>? mascots,
    int? userPoints,
  }) {
    return MascotState(
      activeMascotId: activeMascotId ?? this.activeMascotId,
      mascots: mascots ?? this.mascots,
      userPoints: userPoints ?? this.userPoints,
    );
  }

  Mascot? get activeMascot {
    if (activeMascotId == null) return null;
    return mascots.firstWhere(
      (m) => m.id == activeMascotId,
      orElse: () => mascots.first,
    );
  }
}

@Riverpod(keepAlive: true)
class MascotNotifier extends _$MascotNotifier {
  @override
  MascotState build() {
    final defaultTree = Mascot(
      id: 'default_tree',
      name: 'Joyful Oak',
      type: MascotType.tree,
      currentPoints: 20,
      isUnlocked: true,
      unlockCostPoints: 0,
    );

    final chickenMascot = Mascot(
      id: 'golden_chicken',
      name: 'Golden Chick',
      type: MascotType.chicken,
      currentPoints: 0,
      isUnlocked: false,
      unlockCostPoints: 100,
    );

    return MascotState(
      activeMascotId: defaultTree.id,
      mascots: [defaultTree, chickenMascot],
      userPoints: 250, // Initial user points to allow testing unlock
    );
  }

  void unlockMascot(String mascotId) {
    final mascot = state.mascots.firstWhere((m) => m.id == mascotId);
    if (!mascot.isUnlocked && state.userPoints >= mascot.unlockCostPoints) {
      final updatedMascots = state.mascots.map((m) {
        if (m.id == mascotId) {
          return m.copyWith(isUnlocked: true);
        }
        return m;
      }).toList();

      state = state.copyWith(
        userPoints: state.userPoints - mascot.unlockCostPoints,
        mascots: updatedMascots,
      );
    }
  }

  void selectActiveMascot(String mascotId) {
    final mascot = state.mascots.firstWhere((m) => m.id == mascotId);
    if (mascot.isUnlocked) {
      state = state.copyWith(activeMascotId: mascotId);
    }
  }

  void addGrowthPoints(int points) {
    if (state.activeMascotId == null) return;
    
    final updatedMascots = state.mascots.map((m) {
      if (m.id == state.activeMascotId) {
        return m.copyWith(currentPoints: m.currentPoints + points);
      }
      return m;
    }).toList();

    state = state.copyWith(
      userPoints: state.userPoints + points,
      mascots: updatedMascots,
    );
  }
}
