import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lorofy/features/focus/data/datasources/focus_remote_data_source.dart';
import 'package:lorofy/features/focus/data/models/focus_category.dart';
import 'package:lorofy/features/focus/data/models/focus_session.dart';
import 'package:lorofy/features/focus/domain/enums/block_mode.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'focus_repository.g.dart';

class FocusRepository {
  final FocusRemoteDataSource _remoteDataSource;

  FocusRepository(this._remoteDataSource);

  Future<FocusSessionModel> startSession({
    String? categoryId,
    required BlockMode blockMode,
    required int plannedMinutes,
  }) async {
    return await _remoteDataSource.startSession(
      categoryId: categoryId,
      blockMode: blockMode,
      plannedMinutes: plannedMinutes,
    );
  }

  Future<FocusSessionModel> pauseSession(String sessionId) async {
    return await _remoteDataSource.pauseSession(sessionId);
  }

  Future<FocusSessionModel> completeSession(
    String sessionId,
    int actualMinutes,
  ) async {
    return await _remoteDataSource.completeSession(sessionId, actualMinutes);
  }

  Future<FocusSessionModel> failSession({
    required String sessionId,
    required int actualMinutes,
    String? failureReason,
  }) async {
    return await _remoteDataSource.failSession(
      sessionId: sessionId,
      actualMinutes: actualMinutes,
      failureReason: failureReason,
    );
  }

  Future<List<FocusCategory>> getCategories() async {
    return await _remoteDataSource.getCategories();
  }
}

@Riverpod(keepAlive: true)
FocusRepository focusRepository(Ref ref) {
  final remoteDataSource = ref.read(focusRemoteDataSourceProvider);
  return FocusRepository(remoteDataSource);
}
