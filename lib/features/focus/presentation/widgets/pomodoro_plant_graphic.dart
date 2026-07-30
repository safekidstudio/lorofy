import 'package:flutter/cupertino.dart';
import 'package:lorofy/features/focus/domain/models/pomodoro_state.dart';
import 'package:lorofy/components/ui/svg_asset.dart';
import 'package:rive/rive.dart' hide LinearGradient, Image;

/// Renders the central graphic of the Pomodoro page.
///
/// Manages its own Rive [StateMachineController] and [SMINumber] input,
/// and cross-fades between three states:
///   - Rive grow-plant animation (idle / focus / break)
///   - Success checkmark SVG (completed)
///   - Dead plant SVG (giveup)
class PomodoroPlantGraphic extends StatefulWidget {
  final PomodoroState pomodoroState;

  /// [0.0, 1.0] — how much the plant has grown. Mapped to the Rive input.
  final double growthRatio;

  /// PageController to handle smooth parallax scroll.
  final PageController pageController;

  const PomodoroPlantGraphic({
    super.key,
    required this.pomodoroState,
    required this.growthRatio,
    required this.pageController,
  });

  @override
  State<PomodoroPlantGraphic> createState() => _PomodoroPlantGraphicState();
}

class _PomodoroPlantGraphicState extends State<PomodoroPlantGraphic> {
  SMINumber? _growthInput;
  bool _isRiveInitialized = false;

  void _onRiveInit(Artboard artboard) {
    final controller = StateMachineController.fromArtboard(
      artboard,
      'State Machine 1',
    );
    if (controller != null) {
      artboard.addController(controller);
      for (final input in controller.inputs) {
        if (input is SMINumber && input.name == 'input') {
          _growthInput = input;
        }
      }
      _applyGrowth(widget.growthRatio);
      setState(() => _isRiveInitialized = true);
    }
  }

  void _applyGrowth(double ratio) {
    if (_growthInput == null) return;
    final phase = widget.pomodoroState;
    if (phase == PomodoroState.breakTime || phase == PomodoroState.completed) {
      _growthInput!.value = 100.0;
    } else if (phase == PomodoroState.focus) {
      _growthInput!.value = 20.0 + ratio * 80.0;
    } else {
      _growthInput!.value = 20.0;
    }
  }

  @override
  void didUpdateWidget(PomodoroPlantGraphic oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pomodoroState != widget.pomodoroState) {
      _applyGrowth(widget.growthRatio);
    }
  }

  @override
  Widget build(BuildContext context) {
    final phase = widget.pomodoroState;
    final showRive = _isRiveInitialized &&
        phase != PomodoroState.completed &&
        phase != PomodoroState.giveup;

    return AnimatedBuilder(
      animation: widget.pageController,
      builder: (context, child) {
        final double offset = widget.pageController.hasClients
            ? widget.pageController.offset
            : 0.0;
        return Transform.translate(
          offset: Offset(0, -offset * 0.35),
          child: child,
        );
      },
      child: SizedBox(
        width: 220,
        height: 220,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // A. Rive grow-plant
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: widget.growthRatio, end: widget.growthRatio),
              duration: const Duration(seconds: 1),
              curve: Curves.linear,
              builder: (context, animatedRatio, child) {
                _applyGrowth(animatedRatio);
                return child!;
              },
              child: AnimatedOpacity(
                opacity: showRive ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
                child: RiveAnimation.asset(
                  'assets/river/grow-plant.riv',
                  stateMachines: const ['State Machine 1'],
                  onInit: _onRiveInit,
                ),
              ),
            ),
            // B. Success checkmark
            AnimatedOpacity(
              opacity: phase == PomodoroState.completed ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              child: const SVG(
                'assets/illustrations/success_checkmark.svg',
                width: 220,
                height: 220,
              ),
            ),
            // C. Dead plant
            AnimatedOpacity(
              opacity: phase == PomodoroState.giveup ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              child: const SVG(
                'assets/illustrations/dead_plant.svg',
                width: 220,
                height: 220,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
