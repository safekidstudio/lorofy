import 'package:lorofy/features/explore/domain/models/focus_stats.dart';

class FocusStatsModel extends FocusStats {
  FocusStatsModel({
    required super.totalCompletedSessions,
    required super.totalFailedSessions,
    required super.totalFocusMinutes,
    required super.currentStreak,
    required super.longestStreak,
    required super.categoryBreakdown,
    required super.weeklyProgress,
  });

  factory FocusStatsModel.fromJson(Map<String, dynamic> json) {
    return FocusStatsModel(
      totalCompletedSessions: json['totalCompletedSessions'] as int? ?? 0,
      totalFailedSessions: json['totalFailedSessions'] as int? ?? 0,
      totalFocusMinutes: json['totalFocusMinutes'] as int? ?? 0,
      currentStreak: json['currentStreak'] as int? ?? 0,
      longestStreak: json['longestStreak'] as int? ?? 0,
      categoryBreakdown: (json['categoryBreakdown'] as List<dynamic>?)
              ?.map((e) => CategoryStatModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      weeklyProgress: (json['weeklyProgress'] as List<dynamic>?)
              ?.map((e) => DailyProgressModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class CategoryStatModel extends CategoryStat {
  CategoryStatModel({
    required super.categoryName,
    required super.colorHex,
    required super.totalMinutes,
    required super.sessionCount,
  });

  factory CategoryStatModel.fromJson(Map<String, dynamic> json) {
    return CategoryStatModel(
      categoryName: json['categoryName'] as String? ?? 'Others',
      colorHex: json['colorHex'] as String? ?? '#9E9E9E',
      totalMinutes: json['totalMinutes'] as int? ?? 0,
      sessionCount: json['sessionCount'] as int? ?? 0,
    );
  }
}

class DailyProgressModel extends DailyProgress {
  DailyProgressModel({
    required super.date,
    required super.minutes,
  });

  factory DailyProgressModel.fromJson(Map<String, dynamic> json) {
    return DailyProgressModel(
      date: json['date'] as String? ?? '',
      minutes: json['minutes'] as int? ?? 0,
    );
  }
}
