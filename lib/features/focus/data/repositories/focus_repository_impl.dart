import 'package:lorofy/core/errors/exceptions.dart';
import 'package:lorofy/features/focus/data/datasources/focus_remote_data_source.dart';
import 'package:lorofy/features/focus/domain/enums/block_mode.dart';
import 'package:lorofy/features/focus/domain/models/focus_category.dart';
import 'package:lorofy/features/focus/domain/models/focus_session.dart';
import 'package:lorofy/features/focus/domain/repositories/focus_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'focus_repository_impl.g.dart';

class FocusRepositoryImpl implements FocusRepository {
  final FocusRemoteDataSource _remoteDataSource;

  FocusRepositoryImpl(this._remoteDataSource);

  @override
  Future<FocusSession> startSession({
    String? categoryId,
    required BlockMode blockMode,
    required int plannedMinutes,
  }) async {
    try {
      return await _remoteDataSource.startSession(
        categoryId: categoryId,
        blockMode: blockMode,
        plannedMinutes: plannedMinutes,
      );
    } catch (e) {
      throw e.toFailure();
    }
  }

  @override
  Future<FocusSession> pauseSession(String sessionId) async {
    try {
      return await _remoteDataSource.pauseSession(sessionId);
    } catch (e) {
      throw e.toFailure();
    }
  }

  @override
  Future<FocusSession> completeSession(
    String sessionId,
    int actualMinutes,
  ) async {
    try {
      return await _remoteDataSource.completeSession(sessionId, actualMinutes);
    } catch (e) {
      throw e.toFailure();
    }
  }

  @override
  Future<FocusSession> failSession({
    required String sessionId,
    required int actualMinutes,
    String? failureReason,
  }) async {
    try {
      return await _remoteDataSource.failSession(
        sessionId: sessionId,
        actualMinutes: actualMinutes,
        failureReason: failureReason,
      );
    } catch (e) {
      throw e.toFailure();
    }
  }

  @override
  Future<List<FocusCategory>> getCategories() async {
    try {
      return await _remoteDataSource.getCategories();
    } catch (e) {
      throw e.toFailure();
    }
  }
}

@Riverpod(keepAlive: true)
FocusRepository focusRepository(Ref ref) {
  final remoteDataSource = ref.read(focusRemoteDataSourceProvider);
  return FocusRepositoryImpl(remoteDataSource);
}
