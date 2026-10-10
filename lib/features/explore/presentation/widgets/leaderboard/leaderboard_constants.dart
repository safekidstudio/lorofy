import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';

/// Animation timings, curves, and layout dimensions for Leaderboard components
class LeaderboardConstants {
  const LeaderboardConstants._();

  static const Curve springCurve = Cubic(0.34, 1.25, 0.64, 1.0);
  static const Duration positionDuration = Duration(milliseconds: 400);
  static const Duration slideDownDuration = Duration(milliseconds: 400);
  static const Duration jumpPeriodicity = Duration(milliseconds: 8000);

  static const double podiumHeight = 228.0;
  static const double podiumAvatarColumnHeight = 145.0;
  static const double cardSlotHeight = 60.0;
  static const double cardHeight = 52.0;
}
