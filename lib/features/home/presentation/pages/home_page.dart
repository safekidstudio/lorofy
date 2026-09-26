import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lorofy/components/ui/svg_asset.dart';
import 'package:lorofy/core/theme/app_theme.dart';
import 'package:lorofy/features/focus/data/repositories/focus_repository_impl.dart';
import 'package:lorofy/features/focus/presentation/pages/quick_start_page.dart';
import 'package:lorofy/features/focus/presentation/widgets/focus_timer/active_session_dialog.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with TickerProviderStateMixin {
  late final AnimationController _bounceController;
  late final Animation<Offset> _slideAnimation;

  // Animation controller for drag feedback
  late final AnimationController _dragController;

  bool _isFocusLocked = false;
  double _dragStartY = 0.0;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();

    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 1600),
      vsync: this,
    )..repeat(reverse: true);

    _slideAnimation =
        Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(0.0, -0.15),
        ).animate(
          CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
        );

    _dragController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    // Silently check active session state on app launch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkActiveSession();
    });
  }

  Future<void> _checkActiveSession() async {
    try {
      final currentData =
          await ref.read(focusRepositoryProvider).getCurrentSession();
      if (!mounted ||
          !currentData.hasActiveSession ||
          currentData.session == null) {
        return;
      }

      // Case 1: Session completed while device was inactive (isOverdue == true)
      if (currentData.isOverdue) {
        final session = currentData.session!;
        await ref.read(focusRepositoryProvider).completeSession(
              session.id,
              session.plannedMinutes,
            );
        if (mounted) {
          _showSessionCompletedBanner(session.plannedMinutes);
        }
        return;
      }

      // Case 2: Session still has remaining time -> Prompt user to resume
      if (mounted) {
        showActiveSessionDialog(
          context: context,
          ref: ref,
          activeState: currentData,
        );
      }
    } catch (e) {
      debugPrint('Background session check failed (offline or not logged in): $e');
    }
  }

  void _showSessionCompletedBanner(int minutes) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('🎉 Congratulations!'),
        content: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            'You completed your $minutes-minute focus session while the app was inactive. Your points and streak have been credited!',
          ),
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Awesome'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _dragController.dispose();
    super.dispose();
  }

  void _onDragStart(DragStartDetails details) {
    if (_isFocusLocked) return;
    _dragStartY = details.globalPosition.dy;
    _isDragging = true;
    _bounceController.stop(); // Pause bounce animation during user interaction
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (!_isDragging) return;
    final double currentY = details.globalPosition.dy;
    final double deltaY = currentY - _dragStartY;

    // Only allow dragging upwards (negative deltaY)
    if (deltaY < 0) {
      // Max drag height is 150.0 pixels
      final double progress = (deltaY.abs() / 150.0).clamp(0.0, 1.0);
      _dragController.value = progress;
    } else {
      _dragController.value = 0.0;
    }
  }

  void _onDragEnd(DragEndDetails details) {
    if (!_isDragging) return;
    _isDragging = false;

    final double velocity = details.primaryVelocity ?? 0.0;
    final double progress = _dragController.value;

    // Trigger transition immediately if dragged more than 30% or swiped up fast
    if (progress > 0.3 || velocity < -200) {
      context.push('/explore').then((_) {
        if (mounted) {
          _dragController.value = 0.0;
          _bounceController.repeat(reverse: true);
        }
      });
    } else {
      // Spring back to original position
      _dragController.animateTo(0.0, curve: Curves.easeOutBack).then((_) {
        if (mounted && !_isDragging) {
          _bounceController.repeat(reverse: true);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      child: SafeArea(
        child: Stack(
          children: [
            AnimatedBuilder(
              animation: _dragController,
              builder: (context, child) {
                final double scale = 1.0 - _dragController.value * 0.05;
                final double opacity = (1.0 - _dragController.value * 0.4)
                    .clamp(0.0, 1.0);
                final double translationY = _dragController.value * -60.0;

                return Transform.translate(
                  offset: Offset(0, translationY),
                  child: Transform.scale(
                    scale: scale,
                    child: Opacity(opacity: opacity, child: child),
                  ),
                );
              },
              child: QuickStartPage(
                onFocusStateChanged: (isLocked) {
                  setState(() {
                    _isFocusLocked = isLocked;
                  });
                },
              ),
            ),
            // Bottom "swipe to explore" nudge (hidden when focused/locked)
            if (!_isFocusLocked)
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: AnimatedBuilder(
                  animation: _dragController,
                  builder: (context, child) {
                    final double translationY = _dragController.value * -100.0;
                    final double opacity = (1.0 - _dragController.value).clamp(
                      0.0,
                      1.0,
                    );

                    return Transform.translate(
                      offset: Offset(0, translationY),
                      child: Opacity(opacity: opacity, child: child),
                    );
                  },
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onVerticalDragStart: _onDragStart,
                    onVerticalDragUpdate: _onDragUpdate,
                    onVerticalDragEnd: _onDragEnd,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: const RepaintBoundary(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 20,
                          ), // Enlarged hit area
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
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
