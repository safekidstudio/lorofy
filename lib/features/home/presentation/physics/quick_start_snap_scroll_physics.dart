import 'package:flutter/widgets.dart';

/// Custom [ScrollPhysics] that enforces snap snapping behavior between
/// [QuickStartPage] (0.0) and [ExplorePage] (viewport height), while allowing
/// normal continuous scrolling when within Explore content.
class QuickStartSnapScrollPhysics extends ScrollPhysics {
  /// The height of the QuickStart page item (viewport height).
  final double itemDimension;

  const QuickStartSnapScrollPhysics({
    required this.itemDimension,
    super.parent,
  });

  @override
  QuickStartSnapScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return QuickStartSnapScrollPhysics(
      itemDimension: itemDimension,
      parent: buildParent(ancestor),
    );
  }

  double _getTargetPixels(ScrollMetrics position, Tolerance tolerance, double velocity) {
    final double page = position.pixels / itemDimension;

    // If position is inside Explore (position > itemDimension - 5.0) and moving upwards,
    // NEVER target QuickStart (0.0). Hard clamp target is itemDimension!
    if (position.pixels > itemDimension - 5.0 && velocity <= 0) {
      return itemDimension;
    }

    // Fling velocity thresholds for snap transitions between QuickStart and Explore
    if (velocity < -300.0) {
      return 0.0;
    } else if (velocity > 300.0) {
      return itemDimension;
    } else {
      return page < 0.50 ? 0.0 : itemDimension;
    }
  }

  @override
  Simulation? createBallisticSimulation(ScrollMetrics position, double velocity) {
    // 1. When inside Explore inner content (position > itemDimension),
    // allow free inner scrolling BUT hard-clamp return target at itemDimension when flinging back up
    if (position.pixels > itemDimension + 1.0) {
      if (velocity < 0) {
        final Simulation? parentSim = parent?.createBallisticSimulation(position, velocity);
        if (parentSim != null) {
          final double finalPos = parentSim.x(double.infinity);
          // If fling momentum would carry screen past Explore top into QuickStart,
          // intercept and hard-clamp simulation to stop EXACTLY at itemDimension (Explore top)!
          if (finalPos < itemDimension) {
            return ScrollSpringSimulation(
              spring,
              position.pixels,
              itemDimension,
              velocity,
              tolerance: toleranceFor(position),
            );
          }
        }
        return parentSim;
      }
      return parent?.createBallisticSimulation(position, velocity);
    }

    // 2. For any position between 0 and itemDimension (QuickStart <-> Explore transition):
    final Tolerance tolerance = toleranceFor(position);
    final double target = _getTargetPixels(position, tolerance, velocity);

    if ((target - position.pixels).abs() > 0.1) {
      return ScrollSpringSimulation(
        spring,
        position.pixels,
        target,
        velocity,
        tolerance: tolerance,
      );
    }

    return null;
  }
}
