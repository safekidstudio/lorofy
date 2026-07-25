import 'package:flutter/cupertino.dart';
import 'package:lorofy/core/theme/app_theme.dart';

class AppHeader extends StatelessWidget {
  final Widget? leftActions;
  final String? title;
  final Widget? rightActions;

  const AppHeader({
    super.key,
    this.leftActions,
    this.title,
    this.rightActions,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Left Side: Shows Logo "lorofy." by default, or leftActions if provided
          Positioned(
            left: 0,
            child: leftActions ??
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
          ),

          // Center Title
          if (title != null)
            Text(
              title!,
              style: const TextStyle(
                fontFamily: AppTextStyles.titleFontFamily,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF232321),
              ),
            ),

          // Right Actions
          if (rightActions != null)
            Positioned(
              right: 0,
              child: rightActions!,
            ),
        ],
      ),
    );
  }
}
