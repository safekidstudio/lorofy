import 'dart:async';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Material, MaterialType;
import 'package:lorofy/core/theme/app_theme.dart';

enum ToastType { success, error, info, warning }

class _ToastItem {
  final String id;
  final String title;
  final String message;
  final String? subtitle;
  final String? timeText;
  final Color accentColor;
  final Color badgeBgColor;
  final Widget? customAppIcon;
  final Duration duration;

  _ToastItem({
    required this.id,
    required this.title,
    required this.message,
    this.subtitle,
    this.timeText,
    required this.accentColor,
    required this.badgeBgColor,
    this.customAppIcon,
    required this.duration,
  });
}

class AppToast {
  static final List<_ToastItem> _activeToasts = [];
  static OverlayEntry? _overlayEntry;
  static final GlobalKey<_ToastStackOverlayState> _overlayKey =
      GlobalKey<_ToastStackOverlayState>();

  static void show(
    BuildContext context, {
    required String message,
    String? title,
    String? subtitle,
    String? timeText,
    Widget? customAppIcon,
    ToastType type = ToastType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final id = DateTime.now().microsecondsSinceEpoch.toString();

    Color accentColor;

    switch (type) {
      case ToastType.success:
        accentColor = const Color(0xFF34C759);
        break;
      case ToastType.error:
        accentColor = const Color(0xFFFF3B30);
        break;
      case ToastType.warning:
        accentColor = const Color(0xFFFF9500);
        break;
      case ToastType.info:
        accentColor = const Color(0xFF007AFF);
        break;
    }

    final item = _ToastItem(
      id: id,
      title: title ?? _defaultTitle(type),
      message: message,
      subtitle: subtitle,
      timeText: timeText ?? 'now',
      accentColor: accentColor,
      badgeBgColor: accentColor,
      customAppIcon: customAppIcon,
      duration: duration,
    );

    _activeToasts.add(item);

    // Limit maximum active toasts to 3
    if (_activeToasts.length > 3) {
      _activeToasts.removeAt(0);
    }

    _updateOverlay(context);
  }

  static void success(
    BuildContext context, {
    required String message,
    String? title,
    String? subtitle,
  }) {
    show(
      context,
      message: message,
      title: title,
      subtitle: subtitle,
      type: ToastType.success,
    );
  }

  static void error(
    BuildContext context, {
    required String message,
    String? title,
    String? subtitle,
  }) {
    show(
      context,
      message: message,
      title: title,
      subtitle: subtitle,
      type: ToastType.error,
    );
  }

  static void info(
    BuildContext context, {
    required String message,
    String? title,
    String? subtitle,
  }) {
    show(
      context,
      message: message,
      title: title,
      subtitle: subtitle,
      type: ToastType.info,
    );
  }

  static void warning(
    BuildContext context, {
    required String message,
    String? title,
    String? subtitle,
  }) {
    show(
      context,
      message: message,
      title: title,
      subtitle: subtitle,
      type: ToastType.warning,
    );
  }

  static void _dismissItem(String id, BuildContext context) {
    final index = _activeToasts.indexWhere((t) => t.id == id);
    if (index != -1) {
      _activeToasts.removeAt(index);
      _updateOverlay(context);
    }
  }

  static void dismissAll() {
    _activeToasts.clear();
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
  }

  static void _updateOverlay(BuildContext context) {
    if (_activeToasts.isEmpty) {
      if (_overlayEntry != null) {
        _overlayEntry!.remove();
        _overlayEntry = null;
      }
      return;
    }

    if (_overlayEntry == null) {
      final overlay = Overlay.of(context);
      _overlayEntry = OverlayEntry(
        builder: (context) {
          return _ToastStackOverlay(key: _overlayKey);
        },
      );
      overlay.insert(_overlayEntry!);
    } else {
      _overlayKey.currentState?.update();
    }
  }

  static String _defaultTitle(ToastType type) {
    switch (type) {
      case ToastType.success:
        return 'Success';
      case ToastType.error:
        return 'Notice';
      case ToastType.warning:
        return 'Warning';
      case ToastType.info:
        return 'Lorofy';
    }
  }
}

class _ToastStackOverlay extends StatefulWidget {
  const _ToastStackOverlay({super.key});

  @override
  State<_ToastStackOverlay> createState() => _ToastStackOverlayState();
}

class _ToastStackOverlayState extends State<_ToastStackOverlay> {
  void update() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Positioned(
      top: topPadding + 12,
      left: 16,
      right: 16,
      child: Material(
        type: MaterialType.transparency,
        child: Stack(
          alignment: Alignment.topCenter,
          clipBehavior: Clip.none,
          children: List.generate(AppToast._activeToasts.length, (index) {
            final item = AppToast._activeToasts[index];
            final int depth = AppToast._activeToasts.length - 1 - index;

            return _AnimatedToastCard(
              key: ValueKey(item.id),
              item: item,
              depth: depth,
              onDismiss: () => AppToast._dismissItem(item.id, context),
            );
          }),
        ),
      ),
    );
  }
}

class _AnimatedToastCard extends StatefulWidget {
  final _ToastItem item;
  final int depth;
  final VoidCallback onDismiss;

  const _AnimatedToastCard({
    super.key,
    required this.item,
    required this.depth,
    required this.onDismiss,
  });

  @override
  State<_AnimatedToastCard> createState() => _AnimatedToastCardState();
}

class _AnimatedToastCardState extends State<_AnimatedToastCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  Timer? _autoDismissTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, -0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _scaleAnimation = Tween<double>(
      begin: 0.88,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();

    _autoDismissTimer = Timer(widget.item.duration, () {
      _dismiss();
    });
  }

  @override
  void dispose() {
    _autoDismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _dismiss() async {
    _autoDismissTimer?.cancel();
    if (mounted) {
      await _controller.reverse();
    }
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    final double scale = 1.0 - (widget.depth * 0.05);
    final double yOffset = (widget.depth * 10.0);
    final bool isTop = widget.depth == 0;

    final cardBgColor = CupertinoDynamicColor.resolve(
      AppColors.card,
      context,
    ).withValues(alpha: 0.94);

    final borderColor = CupertinoDynamicColor.resolve(
      AppColors.border,
      context,
    ).withValues(alpha: 0.4);

    final foregroundColor = CupertinoDynamicColor.resolve(
      AppColors.foreground,
      context,
    );

    final mutedColor = CupertinoDynamicColor.resolve(
      AppColors.mutedForeground,
      context,
    );

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            transform: Matrix4.translationValues(0, yOffset, 0)
              ..setEntry(0, 0, scale)
              ..setEntry(1, 1, scale),
            transformAlignment: Alignment.topCenter,
            child: IgnorePointer(
              ignoring: !isTop,
              child: GestureDetector(
                onTap: _dismiss,
                onVerticalDragEnd: (details) {
                  if (details.primaryVelocity != null &&
                      details.primaryVelocity! < -100) {
                    _dismiss();
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: CupertinoColors.black.withValues(alpha: 0.08),
                        blurRadius: 24,
                        spreadRadius: 0,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: cardBgColor,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: borderColor, width: 1.0),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // App Logo Squircle with Type Badge Dot overlay
                            SizedBox(
                              width: 44,
                              height: 44,
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  // App Logo container
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(13),
                                      boxShadow: [
                                        BoxShadow(
                                          color: CupertinoColors.black
                                              .withValues(alpha: 0.08),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child:
                                        widget.item.customAppIcon ??
                                        Image.asset(
                                          'assets/logos/logo.png',
                                          width: 44,
                                          height: 44,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                                return Image.asset(
                                                  'assets/logos/lorofy.png',
                                                  width: 44,
                                                  height: 44,
                                                  fit: BoxFit.cover,
                                                  errorBuilder:
                                                      (
                                                        context,
                                                        error,
                                                        stackTrace,
                                                      ) {
                                                        return Container(
                                                          color:
                                                              AppColors.primary,
                                                          alignment:
                                                              Alignment.center,
                                                          child: const Text(
                                                            'L',
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  AppTextStyles
                                                                      .titleFontFamily,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w900,
                                                              fontSize: 22,
                                                              color:
                                                                  CupertinoColors
                                                                      .white,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                );
                                              },
                                        ),
                                  ),
                                  // Status dot badge floating on bottom-right corner
                                  Positioned(
                                    right: -2,
                                    bottom: -2,
                                    child: Container(
                                      width: 13,
                                      height: 13,
                                      decoration: BoxDecoration(
                                        color: widget.item.badgeBgColor,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: cardBgColor,
                                          width: 2.0,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: CupertinoColors.black
                                                .withValues(alpha: 0.15),
                                            blurRadius: 4,
                                            offset: const Offset(0, 1),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 14),
                            // Content Column
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Title & Time
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          widget.item.title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontFamily:
                                                AppTextStyles.fontFamily,
                                            fontSize: 14.5,
                                            fontWeight: FontWeight.w700,
                                            color: foregroundColor,
                                            letterSpacing: -0.2,
                                          ),
                                        ),
                                      ),
                                      if (widget.item.timeText != null) ...[
                                        const SizedBox(width: 8),
                                        Text(
                                          widget.item.timeText!,
                                          style: TextStyle(
                                            fontFamily:
                                                AppTextStyles.fontFamily,
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w400,
                                            color: mutedColor.withValues(
                                              alpha: 0.7,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  // Optional Subtitle
                                  if (widget.item.subtitle != null) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      widget.item.subtitle!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontFamily: AppTextStyles.fontFamily,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: foregroundColor.withValues(
                                          alpha: 0.9,
                                        ),
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 2),
                                  // Message Body
                                  Text(
                                    widget.item.message,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontFamily: AppTextStyles.fontFamily,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                      color: mutedColor,
                                      height: 1.3,
                                    ),
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
        ),
      ),
    );
  }
}
