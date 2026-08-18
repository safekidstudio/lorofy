import 'package:lorofy/features/explore/domain/models/focus_stats.dart';
import 'package:lorofy/features/explore/domain/models/leaderboard.dart';
import 'package:lorofy/features/focus/domain/models/focus_session.dart';

abstract class ExploreRepository {
  Future<FocusStats> getFocusStats();
  Future<List<FocusSession>> getTodayActivities();
  Future<List<FocusSession>> getMonthActivities();
  Future<List<FocusSession>> getFilteredActivities({
    String? status,
    String? startDate,
    String? endDate,
    int? page,
    int? size,
  });
  Future<Leaderboard> getLeaderboard({
    required String timeframe,
    String? countryCode,
    int page = 0,
    int size = 20,
  });
  Stream<FomoEvent> getLeaderboardUpdateStream();
}
