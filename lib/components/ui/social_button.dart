import 'package:flutter/cupertino.dart';
import 'package:lorofy/components/ui/svg_asset.dart';

class SocialIconButton extends StatelessWidget {
  final String svgPath;
  final VoidCallback onPressed;

  const SocialIconButton({
    super.key,
    required this.svgPath,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      child: Container(
        width: 52,
        height: 52,
        decoration: const BoxDecoration(
          color: Color(0xFF00160A), // Dark forest color from the mockup
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: SVG(svgPath, width: 40, height: 40),
      ),
    );
  }
}
