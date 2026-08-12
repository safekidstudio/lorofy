import 'package:dio/dio.dart';
import 'package:lorofy/core/network/response/api_response.dart';
import 'package:lorofy/core/network/dio_client.dart';
import 'package:lorofy/features/focus/data/models/focus_category_model.dart';
import 'package:lorofy/features/focus/data/models/focus_session_model.dart';
import 'package:lorofy/features/focus/domain/enums/block_mode.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'focus_remote_data_source.g.dart';

class FocusRemoteDataSource {
  final Dio _dio;

  FocusRemoteDataSource(this._dio);

  // START SESSION
  Future<FocusSessionModel> startSession({
    String? categoryId,
    required BlockMode blockMode,
    required int plannedMinutes,
  }) async {
    final response = await _dio.post(
      '/focus/start',
      data: {
        'categoryId': categoryId,
        'blockMode': blockMode.value,
        'plannedMinutes': plannedMinutes,
      },
      options: ApiOptions.protected,
    );
    return response.unwrap(
      (json) => FocusSessionModel.fromJson(json as Map<String, dynamic>),
    );
  }

  // PAUSE SESSION
  Future<FocusSessionModel> pauseSession(String sessionId) async {
    final response = await _dio.post(
      '/focus/$sessionId/pause',
      options: ApiOptions.protected,
    );
    return response.unwrap(
      (json) => FocusSessionModel.fromJson(json as Map<String, dynamic>),
    );
  }

  // COMPLETE SESSION
  Future<FocusSessionModel> completeSession(
    String sessionId,
    int actualMinutes,
  ) async {
    final response = await _dio.post(
      '/focus/$sessionId/complete',
      data: {
        'actualMinutes': actualMinutes,
      },
      options: ApiOptions.protected,
    );
    return response.unwrap(
      (json) => FocusSessionModel.fromJson(json as Map<String, dynamic>),
    );
  }

  // FAIL SESSION
  Future<FocusSessionModel> failSession({
    required String sessionId,
    required int actualMinutes,
    String? failureReason,
  }) async {
    final response = await _dio.post(
      '/focus/$sessionId/fail',
      data: {
        'actualMinutes': actualMinutes,
        'failureReason': failureReason ?? 'User exited session',
      },
      options: ApiOptions.protected,
    );
    return response.unwrap(
      (json) => FocusSessionModel.fromJson(json as Map<String, dynamic>),
    );
  }

  // GET CATEGORIES
  Future<List<FocusCategoryModel>> getCategories() async {
    final response = await _dio.get(
      '/categories',
      options: ApiOptions.protected,
    );
    return response.unwrap(
      (json) => (json as List<dynamic>)
          .map((item) => FocusCategoryModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

@Riverpod(keepAlive: true)
FocusRemoteDataSource focusRemoteDataSource(Ref ref) {
  final dio = ref.read(dioProvider);
  return FocusRemoteDataSource(dio);
}
