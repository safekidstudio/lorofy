import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

/// Clean Rive Animation Wrapper for Rive 0.14+ Native Renderer.
class SafeRiveAnimation extends StatefulWidget {
  final String assetPath;
  final String? artboard;
  final List<String> stateMachines;
  final ValueChanged<RiveWidgetController>? onInitController;
  final ValueChanged<Artboard>? onInit;
  final ValueChanged<File>? onInitFile;
  final BoxFit fit;
  final Alignment alignment;

  const SafeRiveAnimation.asset(
    this.assetPath, {
    super.key,
    this.artboard,
    this.stateMachines = const [],
    List<String> animations = const [],
    this.onInitController,
    this.onInit,
    this.onInitFile,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
  });

  @override
  State<SafeRiveAnimation> createState() => _SafeRiveAnimationState();
}

class _SafeRiveAnimationState extends State<SafeRiveAnimation> {
  late FileLoader _fileLoader;

  @override
  void initState() {
    super.initState();
    _fileLoader = FileLoader.fromAsset(widget.assetPath, riveFactory: Factory.rive);
    _fileLoader.file().then((file) {
      if (mounted) {
        widget.onInitFile?.call(file);
      }
    });
  }

  @override
  void didUpdateWidget(SafeRiveAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.assetPath != widget.assetPath) {
      _fileLoader.dispose();
      _fileLoader = FileLoader.fromAsset(widget.assetPath, riveFactory: Factory.rive);
    }
  }

  @override
  void dispose() {
    _fileLoader.dispose();
    super.dispose();
  }

  Fit _mapBoxFitToFit(BoxFit boxFit) {
    switch (boxFit) {
      case BoxFit.cover:
        return Fit.cover;
      case BoxFit.fill:
        return Fit.fill;
      case BoxFit.fitWidth:
        return Fit.fitWidth;
      case BoxFit.fitHeight:
        return Fit.fitHeight;
      case BoxFit.none:
        return Fit.none;
      case BoxFit.scaleDown:
        return Fit.scaleDown;
      case BoxFit.contain:
        return Fit.contain;
    }
  }

  @override
  Widget build(BuildContext context) {
    final abSelector = widget.artboard != null
        ? ArtboardSelector.byName(widget.artboard!)
        : const ArtboardDefault();

    final smSelector = widget.stateMachines.isNotEmpty
        ? StateMachineSelector.byName(widget.stateMachines.first)
        : const StateMachineDefault();

    return RiveWidgetBuilder(
      fileLoader: _fileLoader,
      artboardSelector: abSelector,
      stateMachineSelector: smSelector,
      onLoaded: (state) async {
        widget.onInitController?.call(state.controller);
        widget.onInit?.call(state.controller.artboard);
        try {
          final file = await _fileLoader.file();
          widget.onInitFile?.call(file);
        } catch (e) {
          debugPrint('SafeRiveAnimation onLoaded file error: $e');
        }
      },
      onFailed: (error, stackTrace) {
        debugPrint(
          'SafeRiveAnimation failed loading asset [${widget.assetPath}]: $error',
        );
      },
      builder: (context, state) {
        if (state is RiveLoaded) {
          return RiveWidget(
            controller: state.controller,
            fit: _mapBoxFitToFit(widget.fit),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
