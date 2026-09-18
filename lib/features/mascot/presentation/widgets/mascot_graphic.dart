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

  void _onRiveInit(Artboard artboard) {
    final stateMachineName = widget.mascot.type.stateMachineName;
    final sm = artboard.stateMachine(stateMachineName) ?? artboard.defaultStateMachine();
    if (sm != null) {
      _riveStateMachine = sm;
      _applyInputs();
      setState(() => _isRiveInitialized = true);
    }
  }

  void _applyInputs() {
    if (_riveStateMachine == null) return;

    final mascot = widget.mascot;
    final stage = mascot.currentStage;
    final progress = widget.isFocusing ? widget.focusProgressRatio : mascot.stageProgressRatio;

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

    // 5. Map progress value
    if (mascot.type == MascotType.tree) {
      // Special mapping for Lorofy's grow-plant.riv:
      // - Stage Egg (Seed): 0% to 20%
      // - Stage Baby (Sprout): 20% to 80%
      // - Stage Adult (Mature Tree): 80% to 100%
      double targetRiveValue = 20.0;
      switch (stage) {
        case MascotStage.level1:
          targetRiveValue = progress * 20.0;
          break;
        case MascotStage.level2:
          targetRiveValue = 20.0 + progress * 60.0;
          break;
        case MascotStage.level3:
          targetRiveValue = 80.0 + progress * 20.0;
          break;
      }
      _riveStateMachine?.number('input')?.value = targetRiveValue;
      _riveStateMachine?.number('progress')?.value = targetRiveValue;
    } else {
      // Default mapping: [0.0, 1.0] maps to [0, 100]
      _riveStateMachine?.number('input')?.value = progress * 100.0;
      _riveStateMachine?.number('progress')?.value = progress * 100.0;
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

    return SizedBox(
      width: renderWidth,
      height: renderHeight,
      child: Stack(
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
              onInit: _onRiveInit,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}
