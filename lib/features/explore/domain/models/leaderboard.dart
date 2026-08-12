import 'package:lorofy/core/network/response/page_response.dart';

class Leaderboard {
  final PageResponse<LeaderboardItem> leaderboard;
  final LeaderboardItem? currentUserRank;

  Leaderboard({
    required this.leaderboard,
    this.currentUserRank,
  });
}

class LeaderboardItem {
  final int rank;
  final String profileId;
  final String username;
  final String displayName;
  final String? avatarUrl;
  final int points;

  LeaderboardItem({
    required this.rank,
    required this.profileId,
    required this.username,
    required this.displayName,
    this.avatarUrl,
    required this.points,
  });
}

class FomoEvent {
  final String profileId;
  final String username;
  final String displayName;
  final String? avatarUrl;
  final int earnedPoints;

  FomoEvent({
    required this.profileId,
    required this.username,
    required this.displayName,
    this.avatarUrl,
    required this.earnedPoints,
  });

  factory FomoEvent.fromJson(Map<String, dynamic> json) {
    return FomoEvent(
      profileId: json['profileId'] as String? ?? '',
      username: json['username'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String?,
      earnedPoints: json['earnedPoints'] as int? ?? 0,
    );
  }
}
