import 'package:lorofy/features/focus/domain/enums/block_mode.dart';

class FocusSessionModel {
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

  FocusSessionModel({
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

  factory FocusSessionModel.fromJson(Map<String, dynamic> json) {
    // Parse BlockMode
    final blockModeStr = json['blockMode'] as String? ?? 'LIGHT';
    final blockMode = BlockMode.values.firstWhere(
      (e) => e.name == blockModeStr,
      orElse: () => BlockMode.LIGHT,
    );

    return FocusSessionModel(
      id: json['id'] as String,
      profileId: json['profileId'] as String,
      categoryId: json['categoryId'] as String?,
      categoryName: json['categoryName'] as String? ?? 'Others',
      blockMode: blockMode,
      plannedMinutes: json['plannedMinutes'] as int? ?? 0,
      actualMinutes: json['actualMinutes'] as int? ?? 0,
      status: json['status'] as String? ?? 'RUNNING',
      pauseCount: json['pauseCount'] as int? ?? 0,
      failureReason: json['failureReason'] as String?,
      startedAt: json['startedAt'] as String,
      endedAt: json['endedAt'] as String?,
      friendSessionId: json['friendSessionId'] as String?,
      earnedPoints: json['earnedPoints'] as int? ?? 0,
      earnedCoins: json['earnedCoins'] as int? ?? 0,
    );
  }
}
