import 'package:flutter/cupertino.dart';
import 'package:lorofy/features/mascot/domain/models/mascot.dart';
import 'package:lorofy/features/mascot/domain/models/mascot_stage.dart';
import 'package:lorofy/features/mascot/domain/models/mascot_type.dart';
import 'package:rive/rive.dart' hide LinearGradient, Image;
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
  SMINumber? _riveNumberInput;
  SMINumber? _riveStageInput;
  SMIBool? _riveIsFocusingInput;
  SMITrigger? _riveEvolveTrigger;
  SMITrigger? _riveSuccessTrigger;
  SMITrigger? _riveFailTrigger;
  bool _isRiveInitialized = false;
  MascotStage? _lastSeenStage;

  @override
  void initState() {
    super.initState();
    _lastSeenStage = widget.mascot.currentStage;
  }

  void fireSuccess() {
    _riveSuccessTrigger?.fire();
  }

  void fireFailed() {
    _riveFailTrigger?.fire();
  }

  void _onRiveInit(Artboard artboard) {
    final stateMachineName = widget.mascot.type.stateMachineName;
    final controller = StateMachineController.fromArtboard(
      artboard,
      stateMachineName,
    );
    if (controller != null) {
      artboard.addController(controller);
      
      for (final input in controller.inputs) {
        if (input is SMINumber) {
          if (input.name == 'input' || input.name == 'progress') {
            _riveNumberInput = input;
          } else if (input.name == 'stage') {
            _riveStageInput = input;
          }
        } else if (input is SMIBool) {
          if (input.name == 'isFocusing' || input.name == 'is_focusing' || input.name == 'focusing') {
            _riveIsFocusingInput = input;
          }
        } else if (input is SMITrigger) {
          if (input.name == 'evolve') {
            _riveEvolveTrigger = input;
          } else if (input.name == 'isSuccess' || input.name == 'success') {
            _riveSuccessTrigger = input;
          } else if (input.name == 'isFailed' || input.name == 'fail' || input.name == 'failed') {
            _riveFailTrigger = input;
          }
        }
      }
      
      _applyInputs();
      setState(() => _isRiveInitialized = true);
    }
  }

  void _applyInputs() {
    final mascot = widget.mascot;
    final stage = mascot.currentStage;
    final progress = widget.isFocusing ? widget.focusProgressRatio : mascot.stageProgressRatio;

    // 1. Apply stage value
    if (_riveStageInput != null) {
      _riveStageInput!.value = stage.levelValue.toDouble();
    }

    // 2. Apply isFocusing boolean state
    if (_riveIsFocusingInput != null) {
      _riveIsFocusingInput!.value = widget.isFocusing;
    }

    // 3. Fire trigger if stage changes (evolution animation)
    if (_lastSeenStage != null && _lastSeenStage != stage) {
      _riveEvolveTrigger?.fire();
      _lastSeenStage = stage;
    }

    // 4. Fire triggers on success/failure state transitions
    if (widget.isSuccess) {
      _riveSuccessTrigger?.fire();
    }
    if (widget.isFailed) {
      _riveFailTrigger?.fire();
    }

    // 5. Map progress value
    if (_riveNumberInput != null) {
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
        _riveNumberInput!.value = targetRiveValue;
      } else {
        // Default mapping: [0.0, 1.0] maps to [0, 100]
        _riveNumberInput!.value = progress * 100.0;
      }
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
      _riveSuccessTrigger?.fire();
    }
    if (widget.isFailed && !oldWidget.isFailed) {
      _riveFailTrigger?.fire();
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
            child: RiveAnimation.asset(
              widget.mascot.type.assetPath,
              stateMachines: [widget.mascot.type.stateMachineName],
              onInit: _onRiveInit,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}
