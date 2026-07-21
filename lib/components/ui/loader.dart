import 'package:flutter/cupertino.dart';
import 'package:lorofy/components/ui/svg_asset.dart';

class Loader extends StatefulWidget {
  final double size;
  final Color color;

  const Loader({
    super.key,
    this.size = 24.0,
    this.color = const Color(0xFF232321),
  });

  @override
  State<Loader> createState() => _LoaderState();
}

class _LoaderState extends State<Loader> with SingleTickerProviderStateMixin {
  late final AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _rotationController,
      child: SVG(
        'assets/icons/loader.svg',
        width: widget.size,
        height: widget.size,
        color: widget.color,
      ),
    );
  }
}
