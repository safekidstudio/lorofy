import 'package:lorofy/features/focus/domain/enums/block_mode.dart';

class FocusSession {
  final String id;
  final String profileId;
  final String? categoryId;
  final String categoryName;
  final BlockMode blockMode;
  final int plannedMinutes;
  final int actualMinutes;
  final String status;
  final int pauseCount;
  final String? failureReason;
  final String startedAt;
  final String? endedAt;
  final String? friendSessionId;
  final int earnedPoints;
  final int earnedCoins;

  FocusSession({
    required this.id,
    required this.profileId,
    this.categoryId,
    required this.categoryName,
    required this.blockMode,
    required this.plannedMinutes,
    required this.actualMinutes,
    required this.status,
    required this.pauseCount,
    this.failureReason,
    required this.startedAt,
    this.endedAt,
    this.friendSessionId,
    required this.earnedPoints,
    required this.earnedCoins,
  });
}
