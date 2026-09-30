import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:lorofy/core/utils/logger.dart';
import 'feedback_service.dart';

/// Infrastructure/Data implementation of [FeedbackService] using [AudioPool] and [HapticFeedback].
class UIFeedbackServiceImpl implements FeedbackService {
  AudioPool? _pool;
  Future<void>? _initFuture;
  bool _audioEnabled = true;
  bool _hapticsEnabled = true;

  double soundVolume = 0.3;

  @override
  Future<void> init() {
    if (_pool != null) return Future.value();
    _initFuture ??= _doInit();
    return _initFuture!;
  }

  Future<void> _doInit() async {
    try {
      _pool = await AudioPool.create(
        source: AssetSource('sounds/click.wav'),
        minPlayers: 2,
        maxPlayers: 4,
        audioContext: AudioContext(
          android: const AudioContextAndroid(
            audioFocus: AndroidAudioFocus.none,
            usageType: AndroidUsageType.media,
            contentType: AndroidContentType.music,
          ),
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.ambient,
            options: const {},
          ),
        ),
      );
      if (kDebugMode) {
        AppLogger.info('AudioPool initialized successfully', tag: 'UIFeedbackService');
      }
    } catch (e, stack) {
      if (kDebugMode) {
        AppLogger.error('Preload warning', error: e, stackTrace: stack, tag: 'UIFeedbackService');
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

  Future<void> _playClickSound() async {
    try {
      if (_pool != null) {
        await _pool!.start(volume: soundVolume);
      } else {
        init();
        await SystemSound.play(SystemSoundType.click);
      }
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('playClick error: $e', tag: 'UIFeedbackService');
      }
      try {
        await SystemSound.play(SystemSoundType.click);
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

  @override
  void setSoundVolume(double volume) {
    soundVolume = volume.clamp(0.0, 1.0);
  }

  void dispose() {
    _pool?.dispose();
    _pool = null;
    _initFuture = null;
  }
}
