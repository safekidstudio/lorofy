import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:lorofy/components/ui/svg_asset.dart';

class TopBar extends StatelessWidget {
  final VoidCallback? onBackPressed;

  const TopBar({super.key, this.onBackPressed});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: onBackPressed ?? () => context.pop(),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: Color(0xFFE4E4E6),
            shape: BoxShape.circle,
          ),
          child: const SVG(
            'assets/icons/chevron-left.svg',
            width: 24,
            height: 24,
          ),
        ),
      ),
    );
  }
}
