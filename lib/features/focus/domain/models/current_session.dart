import 'package:lorofy/features/focus/domain/models/focus_session.dart';

class CurrentSession {
  final bool hasActiveSession;
  final FocusSession? session;
  final int elapsedSeconds;
  final int remainingSeconds;
  final bool isOverdue;

  CurrentSession({
    required this.hasActiveSession,
    this.session,
    this.elapsedSeconds = 0,
    this.remainingSeconds = 0,
    this.isOverdue = false,
  });
}
