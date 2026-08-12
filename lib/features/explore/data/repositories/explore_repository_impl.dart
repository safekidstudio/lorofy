import 'dart:convert';
import 'package:lorofy/core/config/app_config.dart';
import 'package:lorofy/core/network/sse/sse_client.dart';
import 'package:lorofy/features/explore/data/datasources/explore_remote_data_source.dart';
import 'package:lorofy/features/explore/domain/models/focus_stats.dart';
import 'package:lorofy/features/explore/domain/models/leaderboard.dart';
import 'package:lorofy/features/explore/domain/repositories/explore_repository.dart';
import 'package:lorofy/features/focus/domain/models/focus_session.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'explore_repository_impl.g.dart';

class ExploreRepositoryImpl implements ExploreRepository {
  final ExploreRemoteDataSource _remoteDataSource;

  ExploreRepositoryImpl(this._remoteDataSource);

  @override
  Future<FocusStats> getFocusStats() async {
    return await _remoteDataSource.getFocusStats();
  }

  @override
  Future<List<FocusSession>> getTodayActivities() async {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);

    final pageResponse = await _remoteDataSource.getActivities(
      startDate: todayStart.toUtc().toIso8601String(),
      endDate: todayEnd.toUtc().toIso8601String(),
    );
    return pageResponse.content;
  }

  @override
  Future<Leaderboard> getLeaderboard({
    required String timeframe,
    String? countryCode,
    int page = 0,
    int size = 20,
  }) async {
    return await _remoteDataSource.getLeaderboard(
      timeframe: timeframe,
      countryCode: countryCode,
      page: page,
      size: size,
    );
  }

  @override
  Stream<FomoEvent> getLeaderboardUpdateStream() {
    final client = SseClient(
      '${AppConfig.apiBaseUrl}/leaderboards/stream',
      eventTypes: ['leaderboard-update'],
    );
    return client.stream.map((event) {
      final decoded = jsonDecode(event.data) as Map<String, dynamic>;
      return FomoEvent.fromJson(decoded);
    });
  }
}

@Riverpod(keepAlive: true)
ExploreRepository exploreRepository(Ref ref) {
  final dataSource = ref.read(exploreRemoteDataSourceProvider);
  return ExploreRepositoryImpl(dataSource);
}
