import 'package:flutter/material.dart';
import 'package:lorofy/components/ui/svg_asset.dart';
import 'package:lorofy/core/theme/app_theme.dart';

class SwipeToExploreNudge extends StatefulWidget {
  final VoidCallback? onTap;

  const SwipeToExploreNudge({super.key, this.onTap});

  @override
  State<SwipeToExploreNudge> createState() => _SwipeToExploreNudgeState();
}

class _SwipeToExploreNudgeState extends State<SwipeToExploreNudge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bounceController;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 1600),
      vsync: this,
    )..repeat(reverse: true);

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.0, -0.15),
    ).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      child: SlideTransition(
        position: _slideAnimation,
        child: const RepaintBoundary(
          child: Padding(
            padding: EdgeInsets.only(top: 12, bottom: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SVG(
                  'assets/icons/arrows-up.svg',
                  width: 20,
                  height: 20,
                  color: AppColors.mutedForeground,
                ),
                SizedBox(width: 6),
                Text(
                  'swipe to explore',
                  style: TextStyle(
                    fontFamily: AppTextStyles.titleFontFamily,
                    fontSize: 16,
                    color: AppColors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
