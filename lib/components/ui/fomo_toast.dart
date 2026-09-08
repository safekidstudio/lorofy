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
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, -1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();

    // Dismiss overlay after 3.5 seconds
    Future.delayed(const Duration(milliseconds: 3500), () {
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
      top: 50,
      left: 16,
      right: 16,
      child: SafeArea(
        child: SlideTransition(
          position: _offsetAnimation,
          child: FadeTransition(
            opacity: _opacityAnimation,
            child: DefaultTextStyle(
              style: const TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                color: AppColors.primary,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9F9F9).withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: CupertinoColors.white.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: CupertinoColors.black.withValues(alpha: 0.08),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Avatar
                        Container(
                          width: 42,
                          height: 42,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: widget.avatarUrl != null && widget.avatarUrl!.isNotEmpty
                              ? Image.network(
                                  widget.avatarUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (c, e, s) => Container(
                                    color: const Color(0xFFE5E5EA),
                                    child: const Icon(
                                      CupertinoIcons.person_fill,
                                      size: 20,
                                      color: Color(0xFF8E8E93),
                                    ),
                                  ),
                                )
                              : Container(
                                  color: const Color(0xFFE5E5EA),
                                  child: const Icon(
                                    CupertinoIcons.person_fill,
                                    size: 20,
                                    color: Color(0xFF8E8E93),
                                  ),
                                ),
                        ),
                        const SizedBox(width: 12),
                        // Text details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.displayName,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'just finished focusing!',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.mutedForeground,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Points award bubble
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE2FBE9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '+${widget.earnedPoints} pts',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1B5E20),
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                '🔥',
                                style: TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
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
    );
  }
}
