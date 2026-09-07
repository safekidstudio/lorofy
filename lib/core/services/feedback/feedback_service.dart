/// Abstract interface for UI Feedback operations (Sound & Haptics).
/// Adheres to Clean Architecture Domain layer abstractions.
abstract class FeedbackService {
  /// Preload audio assets and prepare feedback engine.
  Future<void> init();

  /// Trigger click feedback (audio and/or haptics).
  void playClick({bool sound = true, bool haptic = true});

  /// Enable or disable sound effects globally.
  void setAudioEnabled(bool enabled);

  /// Enable or disable haptic feedback globally.
  void setHapticsEnabled(bool enabled);
}
