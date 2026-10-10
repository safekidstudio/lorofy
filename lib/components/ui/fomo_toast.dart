import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:lorofy/core/theme/app_theme.dart';

class FomoToast {
  static void show(
    BuildContext context, {
    required String displayName,
    required String? avatarUrl,
    required int earnedPoints,
  }) {
    final overlayState = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _FomoToastWidget(
        displayName: displayName,
        avatarUrl: avatarUrl,
        earnedPoints: earnedPoints,
        onDismiss: () {
          overlayEntry.remove();
        },
      ),
    );

    overlayState.insert(overlayEntry);
  }
}

class _FomoToastWidget extends StatefulWidget {
  final String displayName;
  final String? avatarUrl;
  final int earnedPoints;
  final VoidCallback onDismiss;

  const _FomoToastWidget({
    required this.displayName,
    required this.avatarUrl,
    required this.earnedPoints,
    required this.onDismiss,
  });

  @override
  State<_FomoToastWidget> createState() => _FomoToastWidgetState();
}

class _FomoToastWidgetState extends State<_FomoToastWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _offsetAnimation;
  late final Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 450),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(1.2, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();

    // Dismiss overlay after 2.2 seconds
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (mounted) {
        _controller.reverse().then((_) {
          widget.onDismiss();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 32,
      right: 16,
      child: SafeArea(
        child: SlideTransition(
          position: _offsetAnimation,
          child: FadeTransition(
            opacity: _opacityAnimation,
            child: IgnorePointer(
              child: DefaultTextStyle(
                style: const TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  color: AppColors.primary,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: CupertinoColors.white.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Avatar
                          Container(
                            width: 24,
                            height: 24,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: widget.avatarUrl != null &&
                                    widget.avatarUrl!.isNotEmpty
                                ? Image.network(
                                    widget.avatarUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (c, e, s) => Container(
                                      color: const Color(0xFFE5E5EA),
                                      child: const Icon(
                                        CupertinoIcons.person_fill,
                                        size: 14,
                                        color: Color(0xFF8E8E93),
                                      ),
                                    ),
                                  )
                                : Container(
                                    color: const Color(0xFFE5E5EA),
                                    child: const Icon(
                                      CupertinoIcons.person_fill,
                                      size: 14,
                                      color: Color(0xFF8E8E93),
                                    ),
                                  ),
                          ),
                          const SizedBox(width: 8),
                          // Name
                          Text(
                            widget.displayName,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 6),
                          // Points
                          Text(
                            '+${widget.earnedPoints} pts',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 3),
                          const Text(
                            '🔥',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
