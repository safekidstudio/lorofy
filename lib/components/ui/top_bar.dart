import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

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
          child: SvgPicture.asset(
            'assets/icons/chevron-left.svg',
            width: 24,
            height: 24,
          ),
        ),
      ),
    );
  }
}
