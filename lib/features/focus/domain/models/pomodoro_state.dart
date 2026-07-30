/// Represents the current phase of a Pomodoro session.
enum PomodoroState {
  /// No active session — showing the Start button.
  idle,

  /// Focus timer is running.
  focus,

  /// Short or long break timer is running.
  breakTime,

  /// All target rounds completed — showing celebration screen.
  completed,

  /// User gave up mid-session — showing dead plant screen.
  giveup,
}
