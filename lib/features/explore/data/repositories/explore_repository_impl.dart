import 'dart:convert';
import 'package:lorofy/core/config/app_config.dart';
import 'package:lorofy/core/errors/exceptions.dart';
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
    try {
      return await _remoteDataSource.getFocusStats();
    } catch (e) {
      throw e.toFailure();
    }
  }

  @override
  Future<List<FocusSession>> getTodayActivities() async {
    try {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);

      final pageResponse = await _remoteDataSource.getActivities(
        startDate: todayStart.toUtc().toIso8601String(),
        endDate: todayEnd.toUtc().toIso8601String(),
      );
      return pageResponse.content;
    } catch (e) {
      throw e.toFailure();
    }
  }

  @override
  Future<List<FocusSession>> getFilteredActivities({
    String? status,
    String? startDate,
    String? endDate,
    int? page,
    int? size,
  }) async {
    try {
      final pageResponse = await _remoteDataSource.getActivities(
        status: status,
        startDate: startDate,
        endDate: endDate,
        page: page,
        size: size,
      );
      return pageResponse.content;
    } catch (e) {
      throw e.toFailure();
    }
  }

  @override
  Future<List<FocusSession>> getMonthActivities() async {
    try {
      final now = DateTime.now();
      final startDate = now.subtract(const Duration(days: 30));
      final monthStart = DateTime(startDate.year, startDate.month, startDate.day);
      final monthEnd = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);

      final pageResponse = await _remoteDataSource.getActivities(
        startDate: monthStart.toUtc().toIso8601String(),
        endDate: monthEnd.toUtc().toIso8601String(),
        size: 200,
      );
      return pageResponse.content;
    } catch (e) {
      throw e.toFailure();
    }
  }

  @override
  Future<Leaderboard> getLeaderboard({
    required String timeframe,
    String? countryCode,
    int page = 0,
    int size = 20,
  }) async {
    try {
      return await _remoteDataSource.getLeaderboard(
        timeframe: timeframe,
        countryCode: countryCode,
        page: page,
        size: size,
      );
    } catch (e) {
      throw e.toFailure();
    }
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
