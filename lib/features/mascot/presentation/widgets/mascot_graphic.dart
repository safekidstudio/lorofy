// ignore_for_file: deprecated_member_use

import 'package:flutter/cupertino.dart';
import 'package:lorofy/features/mascot/domain/models/mascot.dart';
import 'package:lorofy/features/mascot/domain/models/mascot_stage.dart';
import 'package:lorofy/features/mascot/domain/models/mascot_type.dart';
import 'package:lorofy/components/ui/safe_rive_animation.dart';
import 'package:rive/rive.dart' hide Animation;
import 'package:lorofy/components/ui/loader.dart';

/// A unified widget to render Mascot animations.
/// It automatically hooks up Mascot stage and progress updates
/// to Rive state machine inputs.
class MascotGraphic extends StatefulWidget {
  final Mascot mascot;
  final bool isFocusing;
  final double focusProgressRatio;
  final bool isSuccess;
  final bool isFailed;
  final double? width;
  final double? height;

  const MascotGraphic({
    super.key,
    required this.mascot,
    this.isFocusing = false,
    this.focusProgressRatio = 0.0,
    this.isSuccess = false,
    this.isFailed = false,
    this.width,
    this.height,
  });

  @override
  State<MascotGraphic> createState() => _MascotGraphicState();
}

class _MascotGraphicState extends State<MascotGraphic> {
  StateMachine? _riveStateMachine;
  bool _isRiveInitialized = false;
  MascotStage? _lastSeenStage;

  @override
  void initState() {
    super.initState();
    _lastSeenStage = widget.mascot.currentStage;
  }

  void fireSuccess() {
    _riveStateMachine?.trigger('isSuccess')?.fire();
    _riveStateMachine?.trigger('success')?.fire();
  }

  void fireFailed() {
    _riveStateMachine?.trigger('isFailed')?.fire();
    _riveStateMachine?.trigger('fail')?.fire();
    _riveStateMachine?.trigger('failed')?.fire();
  }

  void _onRiveControllerInit(RiveWidgetController controller) {
    _riveStateMachine = controller.stateMachine;
    if (_riveStateMachine != null) {
      _applyInputs();
      if (mounted && !_isRiveInitialized) {
        setState(() => _isRiveInitialized = true);
      }
    }
  }

  void _updateRiveInputValue(double value) {
    if (_riveStateMachine == null) return;
    _riveStateMachine?.number('input')?.value = value;
    _riveStateMachine?.number('progress')?.value = value;
  }

  void _applyInputs() {
    if (_riveStateMachine == null) return;

    final mascot = widget.mascot;
    final stage = mascot.currentStage;

    // 1. Apply stage value
    _riveStateMachine?.number('stage')?.value = stage.levelValue.toDouble();

    // 2. Apply isFocusing boolean state
    _riveStateMachine?.boolean('isFocusing')?.value = widget.isFocusing;
    _riveStateMachine?.boolean('is_focusing')?.value = widget.isFocusing;
    _riveStateMachine?.boolean('focusing')?.value = widget.isFocusing;

    // 3. Fire trigger if stage changes (evolution animation)
    if (_lastSeenStage != null && _lastSeenStage != stage) {
      _riveStateMachine?.trigger('evolve')?.fire();
      _lastSeenStage = stage;
    }

    // 4. Fire triggers on success/failure state transitions
    if (widget.isSuccess) {
      fireSuccess();
    }
    if (widget.isFailed) {
      fireFailed();
    }
  }

  @override
  void didUpdateWidget(MascotGraphic oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mascot.type != widget.mascot.type) {
      setState(() {
        _isRiveInitialized = false;
      });
    }
    if (widget.isSuccess && !oldWidget.isSuccess) {
      fireSuccess();
    }
    if (widget.isFailed && !oldWidget.isFailed) {
      fireFailed();
    }
    if (oldWidget.mascot.currentPoints != widget.mascot.currentPoints ||
        oldWidget.mascot.type != widget.mascot.type ||
        oldWidget.isFocusing != widget.isFocusing ||
        oldWidget.focusProgressRatio != widget.focusProgressRatio ||
        oldWidget.isSuccess != widget.isSuccess ||
        oldWidget.isFailed != widget.isFailed) {
      _applyInputs();
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double defaultSize = (screenWidth * 0.65).clamp(220.0, 350.0);
    final double renderWidth = widget.width ?? defaultSize;
    final double renderHeight = widget.height ?? defaultSize;

    final double targetProgress = widget.isFocusing
        ? (widget.focusProgressRatio * 100.0).clamp(0.0, 100.0)
        : (widget.mascot.type == MascotType.tree
            ? (widget.mascot.currentStage == MascotStage.level1
                ? widget.mascot.stageProgressRatio * 20.0
                : widget.mascot.currentStage == MascotStage.level2
                    ? 20.0 + widget.mascot.stageProgressRatio * 60.0
                    : 80.0 + widget.mascot.stageProgressRatio * 20.0)
            : widget.mascot.stageProgressRatio * 100.0);

    return SizedBox(
      width: renderWidth,
      height: renderHeight,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(end: targetProgress),
        duration: widget.isFocusing
            ? const Duration(milliseconds: 1000)
            : const Duration(milliseconds: 450),
        curve: widget.isFocusing ? Curves.linear : Curves.easeOutCubic,
        builder: (context, animatedValue, child) {
          _updateRiveInputValue(animatedValue);
          return Stack(
            alignment: Alignment.center,
            children: [
              // Loading spinner using our custom rotating Loader component
              if (!_isRiveInitialized)
                const Loader(
                  size: 32.0,
                  color: Color(0xFF232321),
                ),

              // Smooth fade-in transition when Rive is initialized and ready
              AnimatedOpacity(
                opacity: _isRiveInitialized ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
                child: SafeRiveAnimation.asset(
                  widget.mascot.type.assetPath,
                  onInitController: _onRiveControllerInit,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
