import 'package:lorofy/core/network/response/page_response.dart';
import 'package:lorofy/features/explore/domain/models/leaderboard.dart';

class LeaderboardModel extends Leaderboard {
  LeaderboardModel({
    required super.leaderboard,
    super.currentUserRank,
  });

  factory LeaderboardModel.fromJson(Map<String, dynamic> json) {
    final rawLeaderboard = json['leaderboard'] as Map<String, dynamic>;
    return LeaderboardModel(
      leaderboard: PageResponse<LeaderboardItem>.fromJson(
        rawLeaderboard,
        (itemJson) => LeaderboardItemModel.fromJson(itemJson as Map<String, dynamic>),
      ),
      currentUserRank: json['currentUserRank'] != null
          ? LeaderboardItemModel.fromJson(json['currentUserRank'] as Map<String, dynamic>)
          : null,
    );
  }
}

class LeaderboardItemModel extends LeaderboardItem {
  LeaderboardItemModel({
    required super.rank,
    required super.profileId,
    required super.username,
    required super.displayName,
    super.avatarUrl,
    required super.points,
  });

  factory LeaderboardItemModel.fromJson(Map<String, dynamic> json) {
    return LeaderboardItemModel(
      rank: json['rank'] as int? ?? 0,
      profileId: json['profileId'] as String? ?? '',
      username: json['username'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String?,
      points: json['points'] as int? ?? 0,
    );
  }
}
