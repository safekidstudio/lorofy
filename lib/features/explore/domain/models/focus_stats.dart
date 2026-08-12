class FocusStats {
  final int totalCompletedSessions;
  final int totalFailedSessions;
  final int totalFocusMinutes;
  final int currentStreak;
  final int longestStreak;
  final List<CategoryStat> categoryBreakdown;
  final List<DailyProgress> weeklyProgress;

  FocusStats({
    required this.totalCompletedSessions,
    required this.totalFailedSessions,
    required this.totalFocusMinutes,
    required this.currentStreak,
    required this.longestStreak,
    required this.categoryBreakdown,
    required this.weeklyProgress,
  });
}

class CategoryStat {
  final String categoryName;
  final String colorHex;
  final int totalMinutes;
  final int sessionCount;

  CategoryStat({
    required this.categoryName,
    required this.colorHex,
    required this.totalMinutes,
    required this.sessionCount,
  });
}

class DailyProgress {
  final String date;
  final int minutes;

  DailyProgress({
    required this.date,
    required this.minutes,
  });
}
