import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Material, MaterialType;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lorofy/components/ui/drawing_container.dart';
import 'package:lorofy/core/theme/app_theme.dart';

enum ToastType { success, error, info, warning }

class _ToastItem {
  final String id;
  final String title;
  final String message;
  final Color accentColor;
  final Color fillColor;
  final SvgPicture icon;
  final Duration duration;

  _ToastItem({
    required this.id,
    required this.title,
    required this.message,
    required this.accentColor,
    required this.fillColor,
    required this.icon,
    required this.duration,
  });
}

class AppToast {
  static final List<_ToastItem> _activeToasts = [];
  static OverlayEntry? _overlayEntry;
  static final GlobalKey<_ToastStackOverlayState> _overlayKey = GlobalKey<_ToastStackOverlayState>();

  static void show(
    BuildContext context, {
    required String message,
    String? title,
    ToastType type = ToastType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final id = DateTime.now().microsecondsSinceEpoch.toString();

    Color accentColor;
    Color fillColor;
    SvgPicture icon;
    switch (type) {
      case ToastType.success:
        accentColor = const Color(0xFF1EA756); // Green
        fillColor = const Color(0xFFE3F8EB); // Light green
        icon = SvgPicture.asset(
          'assets/icons/square-check.svg',
          width: 24,
          height: 24,
          colorFilter: const ColorFilter.mode(Color(0xFF1EA756), BlendMode.srcIn),
        );
        break;
      case ToastType.error:
        accentColor = const Color(0xFFE02424); // Red
        fillColor = const Color(0xFFFDE8E8); // Light red
        icon = SvgPicture.asset(
          'assets/icons/square-cancel.svg',
          width: 24,
          height: 24,
          colorFilter: const ColorFilter.mode(Color(0xFFE02424), BlendMode.srcIn),
        );
        break;
      case ToastType.warning:
        accentColor = const Color(0xFFD97706); // Orange
        fillColor = const Color(0xFFFEF3C7); // Light orange/yellow
        icon = SvgPicture.asset(
          'assets/icons/square-warning.svg',
          width: 24,
          height: 24,
          colorFilter: const ColorFilter.mode(Color(0xFFD97706), BlendMode.srcIn),
        );
        break;
      case ToastType.info:
        accentColor = const Color(0xFF2563EB); // Blue
        fillColor = const Color(0xFFE1EFFE); // Light blue
        icon = SvgPicture.asset(
          'assets/icons/square-info.svg',
          width: 24,
          height: 24,
          colorFilter: const ColorFilter.mode(Color(0xFF2563EB), BlendMode.srcIn),
        );
        break;
    }

    final item = _ToastItem(
      id: id,
      title: title ?? _defaultTitle(type),
      message: message,
      accentColor: accentColor,
      fillColor: fillColor,
      icon: icon,
      duration: duration,
    );

    _activeToasts.add(item);

    // Giới hạn tối đa 3 active toasts
    if (_activeToasts.length > 3) {
      _activeToasts.removeAt(0);
    }

    _updateOverlay(context);
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
        return 'Error';
      case ToastType.warning:
        return 'Warning';
      case ToastType.info:
        return 'Lorofy: Info';
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
      top: topPadding + 28,
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
      duration: const Duration(milliseconds: 300),
    );

    // Subtle slide: slide down just 10% of its size (very tiny slide)
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, -0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    // Entrance scale: scale up from 0.9 to 1.0
    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    _controller.forward();

    // Khởi tạo timer tự động dismiss cho card này
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

  Future<_ToastItem?> _dismiss() async {
    _autoDismissTimer?.cancel();
    if (mounted) {
      await _controller.reverse();
    }
    widget.onDismiss();
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final double scale = 1.0 - (widget.depth * 0.04);
    final double yOffset = -(widget.depth * 8.0);
    final bool isTop = widget.depth == 0;

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            transform: Matrix4.translationValues(0, yOffset, 0)
              ..setEntry(0, 0, scale)
              ..setEntry(1, 1, scale),
            transformAlignment: Alignment.topCenter,
            child: IgnorePointer(
              ignoring: !isTop,
              child: GestureDetector(
                onTap: _dismiss,
                child: DrawingContainer(
                  fillColor: widget.item.fillColor,
                  borderColor: widget.item.accentColor,
                  borderWidth: 2.0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      widget.item.icon,
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.item.title,
                              style: AppTextStyles.titleMedium.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF232321),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.item.message,
                              style: AppTextStyles.body.copyWith(
                                fontSize: 14,
                                color: const Color(0xFF484C52),
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
    );
  }
}
