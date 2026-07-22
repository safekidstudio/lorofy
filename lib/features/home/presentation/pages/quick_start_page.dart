import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lorofy/components/ui/button.dart';
import 'package:lorofy/components/ui/svg_asset.dart';
import 'package:lorofy/components/ui/toast.dart';
import 'package:lorofy/core/theme/app_theme.dart';
import 'package:rive/rive.dart' hide LinearGradient, Image;

class QuickStartPage extends ConsumerStatefulWidget {
  final double pageOffset;
  final double pageValue;
  final VoidCallback onSettingsPressed;
  final ValueChanged<bool> onFocusStateChanged;

  const QuickStartPage({
    super.key,
    required this.pageOffset,
    required this.pageValue,
    required this.onSettingsPressed,
    required this.onFocusStateChanged,
  });

  @override
  ConsumerState<QuickStartPage> createState() => _QuickStartPageState();
}

class _QuickStartPageState extends ConsumerState<QuickStartPage> {
  // Focus Session State
  bool _isFocusActive = false;
  int _growthStage = 0; // 0: Sprout, 1: Small Plant, 2: Medium Plant, 3: Mature Tree/Bloom
  int _countdownSeconds = 1500; // 25 minutes
  Timer? _focusTimer;

  // Rive Controller State
  SMINumber? _growthInput;
  SMIBool? _isGrowingInput;

  @override
  void dispose() {
    _focusTimer?.cancel();
    super.dispose();
  }

  void _startFocusSession() {
    setState(() {
      _isFocusActive = true;
      _growthStage = 0; // Starts at sprout
      _countdownSeconds = 1500; // 25 mins
      _updateRiveInputs();
    });
    widget.onFocusStateChanged(true);

    _focusTimer?.cancel();
    _focusTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdownSeconds > 0) {
        setState(() {
          _countdownSeconds--;
          // Map stages over 1500 seconds:
          // 0-500s: Sprout (0)
          // 500-1000s: Small (1)
          // 1000-1499s: Medium (2)
          // 1500s: Mature/Bloom (3)
          if (_countdownSeconds <= 0) {
            _growthStage = 3;
          } else if (_countdownSeconds <= 500) {
            _growthStage = 2;
          } else if (_countdownSeconds <= 1000) {
            _growthStage = 1;
          } else {
            _growthStage = 0;
          }
          _updateRiveInputs();
        });
      } else {
        _completeFocusSession();
      }
    });

    AppToast.show(
      context,
      message: 'Focus session started! Time to grow your plant! 🌿',
      type: ToastType.success,
    );
  }

  void _cancelFocusSession() {
    _focusTimer?.cancel();
    setState(() {
      _isFocusActive = false;
      _growthStage = 0;
      _updateRiveInputs();
    });
    widget.onFocusStateChanged(false);
    AppToast.show(
      context,
      message: 'Focus session cancelled. The plant withered... 🥀',
      type: ToastType.error,
    );
  }

  void _completeFocusSession() {
    _focusTimer?.cancel();
    setState(() {
      _isFocusActive = false;
      _growthStage = 3; // Fully mature
      _updateRiveInputs();
    });
    widget.onFocusStateChanged(false);
    AppToast.show(
      context,
      message: 'Congratulations! You successfully grew a mature plant! 🌳🎉',
      type: ToastType.success,
    );
  }

  void _onRiveInit(Artboard artboard) {
    final controller = StateMachineController.fromArtboard(artboard, 'State Machine 1');
    if (controller != null) {
      artboard.addController(controller);

      for (final input in controller.inputs) {
        if (input is SMINumber && (input.name.toLowerCase().contains('grow') || input.name.toLowerCase().contains('level') || input.name.toLowerCase().contains('state') || input.name.toLowerCase().contains('stage'))) {
          _growthInput = input;
        } else if (input is SMIBool && input.name.toLowerCase().contains('grow')) {
          _isGrowingInput = input;
        }
      }

      // Fallback binding
      _growthInput ??= controller.inputs.whereType<SMINumber>().firstOrNull;
      _isGrowingInput ??= controller.inputs.whereType<SMIBool>().firstOrNull;

      _updateRiveInputs();
    }
  }

  void _updateRiveInputs() {
    if (_growthInput != null) {
      if (_growthInput!.name.toLowerCase().contains('level') || _growthInput!.name.toLowerCase().contains('stage')) {
        _growthInput!.value = _growthStage.toDouble();
      } else {
        _growthInput!.value = (_growthStage * 33.3).clamp(0.0, 100.0);
      }
    }
    if (_isGrowingInput != null) {
      _isGrowingInput!.value = _isFocusActive;
    }
  }

  String _formatDuration(int seconds) {
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  String _getStageName(int stage) {
    switch (stage) {
      case 0:
        return 'Sprout (Mầm) 🌿';
      case 1:
        return 'Small Plant (Cây nhỏ) 🪴';
      case 2:
        return 'Medium Plant (Cây vừa) 🌳';
      case 3:
        return 'Mature Tree (Cây to) 🌸';
      default:
        return 'Sprout (Mầm) 🌿';
    }
  }

  @override
  Widget build(BuildContext context) {
    final double opacity = (1.0 - widget.pageValue * 2.5).clamp(0.0, 1.0);

    return Opacity(
      opacity: opacity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Custom Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'lorofy.',
                  style: TextStyle(
                    fontFamily: AppTextStyles.titleFontFamily,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF232321),
                    letterSpacing: -0.5,
                  ),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: widget.onSettingsPressed,
                  child: const SVG(
                    'assets/icons/settings_drawing.svg',
                    width: 32,
                    height: 32,
                  ),
                ),
              ],
            ),
            const Spacer(),
            // Potted Plant (Parallax translate)
            Transform.translate(
              offset: Offset(0, -widget.pageOffset * 0.35),
              child: Center(
                child: Column(
                  children: [
                    // Plant Rive Animation with growing scaling effect
                    AnimatedScale(
                      scale: _isFocusActive ? 1.0 + (_growthStage * 0.1) : 0.8 + (_growthStage * 0.1),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.elasticOut,
                      child: SizedBox(
                        width: 220,
                        height: 220,
                        child: RiveAnimation.asset(
                          'assets/river/plant.riv',
                          stateMachines: const ['State Machine 1'],
                          onInit: _onRiveInit,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Current growth phase label
                    Text(
                      _getStageName(_growthStage),
                      style: const TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF232321),
                      ),
                    ),
                    const SizedBox(height: 32),
                    if (_isFocusActive) ...[
                      // Focus Mode View
                      Text(
                        _formatDuration(_countdownSeconds),
                        style: const TextStyle(
                          fontFamily: AppTextStyles.titleFontFamily,
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF232321),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 130,
                            child: Button.primary(
                              text: 'Complete',
                              onPressed: _completeFocusSession,
                            ),
                          ),
                          const SizedBox(width: 12),
                          CupertinoButton(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            color: CupertinoColors.systemRed,
                            borderRadius: BorderRadius.circular(16),
                            onPressed: _cancelFocusSession,
                            child: const Text(
                              'Give Up',
                              style: TextStyle(
                                fontFamily: AppTextStyles.fontFamily,
                                color: CupertinoColors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      // Start Button
                      SizedBox(
                        width: 180,
                        child: Button.primary(
                          text: 'Start',
                          onPressed: _startFocusSession,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
