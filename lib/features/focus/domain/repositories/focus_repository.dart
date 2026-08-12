import 'package:lorofy/features/focus/domain/enums/block_mode.dart';
import 'package:lorofy/features/focus/domain/models/focus_category.dart';
import 'package:lorofy/features/focus/domain/models/focus_session.dart';

abstract class FocusRepository {
  Future<FocusSession> startSession({
    String? categoryId,
    required BlockMode blockMode,
    required int plannedMinutes,
  });

  Future<FocusSession> pauseSession(String sessionId);

  Future<FocusSession> completeSession(
    String sessionId,
    int actualMinutes,
  );

  Future<FocusSession> failSession({
    required String sessionId,
    required int actualMinutes,
    String? failureReason,
  });

  Future<List<FocusCategory>> getCategories();
}
