import 'package:lorofy/features/focus/data/models/focus_session_model.dart';
import 'package:lorofy/features/focus/domain/models/current_session.dart';

class CurrentSessionModel extends CurrentSession {
  CurrentSessionModel({
    required super.hasActiveSession,
    super.session,
    super.elapsedSeconds,
    super.remainingSeconds,
    super.isOverdue,
  });

  factory CurrentSessionModel.fromJson(Map<String, dynamic> json) {
    return CurrentSessionModel(
      hasActiveSession: json['hasActiveSession'] as bool? ?? false,
      session: json['session'] != null
          ? FocusSessionModel.fromJson(json['session'] as Map<String, dynamic>)
          : null,
      elapsedSeconds: (json['elapsedSeconds'] as num?)?.toInt() ?? 0,
      remainingSeconds: (json['remainingSeconds'] as num?)?.toInt() ?? 0,
      isOverdue: json['isOverdue'] as bool? ?? false,
    );
  }
}
