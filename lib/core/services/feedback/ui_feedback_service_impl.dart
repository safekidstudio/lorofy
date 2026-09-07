import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'feedback_service.dart';

/// Infrastructure/Data implementation of [FeedbackService] using [AudioPlayer] and [HapticFeedback].
class UIFeedbackServiceImpl implements FeedbackService {
  AudioPlayer? _clickPlayer;
  bool _isPreloaded = false;
  bool _audioEnabled = true;
  bool _hapticsEnabled = true;

  double soundVolume = 0.35;

  @override
  Future<void> init() async {
    if (_isPreloaded) return;
    try {
      _clickPlayer = AudioPlayer(playerId: 'lorofy_ui_click_player');
      await _clickPlayer!.setVolume(soundVolume);
      await _clickPlayer!.setReleaseMode(ReleaseMode.stop);
      await _clickPlayer!.setSource(AssetSource('sounds/click.wav'));
      _isPreloaded = true;
    } catch (e) {
      if (kDebugMode) {
        print('UIFeedbackServiceImpl: Preload non-fatal warning: $e');
      }
    }
  }

  @override
  void playClick({bool sound = true, bool haptic = true}) {
    if (haptic && _hapticsEnabled) {
      _triggerHaptic();
    }

    if (sound && _audioEnabled) {
      _playClickSound();
    }
  }

  void _triggerHaptic() {
    try {
      HapticFeedback.lightImpact();
    } catch (_) {}
  }

  void _playClickSound() {
    try {
      if (_clickPlayer != null && _isPreloaded) {
        _clickPlayer!.seek(Duration.zero);
        _clickPlayer!.resume();
      } else {
        SystemSound.play(SystemSoundType.click);
      }
    } catch (_) {
      try {
        SystemSound.play(SystemSoundType.click);
      } catch (_) {}
    }
  }

  @override
  void setAudioEnabled(bool enabled) {
    _audioEnabled = enabled;
  }

  @override
  void setHapticsEnabled(bool enabled) {
    _hapticsEnabled = enabled;
  }
}
