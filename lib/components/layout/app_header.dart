import 'package:flutter/cupertino.dart';
import 'package:lorofy/components/ui/logo.dart';
import 'package:lorofy/core/theme/app_theme.dart';

class AppHeader extends StatelessWidget {
  final Widget? leftActions;
  final String? title;
  final Widget? rightActions;

  const AppHeader({super.key, this.leftActions, this.title, this.rightActions});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          // Left: Logo by default, or custom leftActions
          leftActions ?? const Logo(),

          // Center title expands to fill remaining space
          Expanded(
            child: title != null
                ? Text(
                    title!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: AppTextStyles.titleFontFamily,
                      fontSize: 20,
                      color: Color(0xFF232321),
                    ),
                  )
                : const SizedBox.shrink(),
          ),

          // Right: placeholder to balance left side when no rightActions
          if (rightActions != null)
            rightActions!
          else
            const SizedBox(width: 40),
        ],
      ),
    );
  }
}
