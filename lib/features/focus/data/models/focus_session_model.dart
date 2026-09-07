import 'package:lorofy/features/focus/domain/enums/block_mode.dart';
import 'package:lorofy/features/focus/domain/models/focus_session.dart';

class FocusSessionModel extends FocusSession {
  FocusSessionModel({
    required super.id,
    required super.profileId,
    super.categoryId,
    required super.categoryName,
    required super.blockMode,
    required super.plannedMinutes,
    required super.actualMinutes,
    required super.status,
    required super.pauseCount,
    super.failureReason,
    required super.startedAt,
    super.endedAt,
    super.friendSessionId,
    required super.earnedPoints,
    required super.earnedCoins,
  });

  factory FocusSessionModel.fromJson(Map<String, dynamic> json) {
    // Parse BlockMode
    final blockModeStr = json['blockMode'] as String? ?? 'MEDIUM';
    final blockMode = BlockMode.values.firstWhere(
      (e) => e.value == blockModeStr || e.name == blockModeStr.toLowerCase(),
      orElse: () => BlockMode.medium,
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'profileId': profileId,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'blockMode': blockMode.name,
      'plannedMinutes': plannedMinutes,
      'actualMinutes': actualMinutes,
      'status': status,
      'pauseCount': pauseCount,
      'failureReason': failureReason,
      'startedAt': startedAt,
      'endedAt': endedAt,
      'friendSessionId': friendSessionId,
      'earnedPoints': earnedPoints,
      'earnedCoins': earnedCoins,
    };
  }
}
