import 'package:dio/dio.dart';
import 'package:lorofy/core/network/response/api_response.dart';
import 'package:lorofy/core/network/response/page_response.dart';
import 'package:lorofy/core/network/dio_client.dart';
import 'package:lorofy/features/explore/data/models/focus_stats_model.dart';
import 'package:lorofy/features/focus/data/models/focus_session_model.dart';
import 'package:lorofy/features/explore/data/models/leaderboard_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'explore_remote_data_source.g.dart';

class ExploreRemoteDataSource {
  final Dio _dio;

  ExploreRemoteDataSource(this._dio);

  Future<FocusStatsModel> getFocusStats() async {
    final response = await _dio.get(
      '/profiles/focus-stats',
      options: ApiOptions.protected,
    );
    return response.unwrap(
      (json) => FocusStatsModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<PageResponse<FocusSessionModel>> getActivities({
    String? status,
    String? startDate,
    String? endDate,
  }) async {
    final Map<String, dynamic> queryParameters = {};
    if (status != null) queryParameters['status'] = status;
    if (startDate != null) queryParameters['startDate'] = startDate;
    if (endDate != null) queryParameters['endDate'] = endDate;

    final response = await _dio.get(
      '/profiles/activities',
      queryParameters: queryParameters,
      options: ApiOptions.protected,
    );
    return response.unwrapPage(
      (json) => FocusSessionModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<LeaderboardModel> getLeaderboard({
    required String timeframe,
    String? countryCode,
    int page = 0,
    int size = 20,
  }) async {
    final Map<String, dynamic> queryParameters = {
      'timeframe': timeframe,
      'page': page,
      'size': size,
    };
    if (countryCode != null) queryParameters['countryCode'] = countryCode;

    final response = await _dio.get(
      '/leaderboards',
      queryParameters: queryParameters,
      options: ApiOptions.public,
    );
    return response.unwrap(
      (json) => LeaderboardModel.fromJson(json as Map<String, dynamic>),
    );
  }
}

@Riverpod(keepAlive: true)
ExploreRemoteDataSource exploreRemoteDataSource(Ref ref) {
  final dio = ref.read(dioProvider);
  return ExploreRemoteDataSource(dio);
}
