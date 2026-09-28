import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lorofy/core/theme/app_theme.dart';
import 'package:lorofy/features/auth/data/models/user_profile.dart';
import 'package:lorofy/features/auth/presentation/providers/auth_provider.dart';
import 'package:lorofy/features/explore/presentation/pages/explore_page.dart';
import 'package:lorofy/features/focus/data/repositories/focus_repository_impl.dart';
import 'package:lorofy/features/focus/presentation/pages/quick_start_page.dart';
import 'package:lorofy/features/focus/presentation/widgets/modals/active_session_dialog.dart';
import 'package:lorofy/features/profile/presentation/widgets/streak_repair_dialog.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  late final PageController _pageController;
  bool _isFocusLocked = false;
  bool _hasCheckedStreakRepair = false;

  @override
  void initState() {
    super.initState();

    _pageController = PageController();

    // Silently check active session state & streak repair on app launch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkActiveSession();
    });
  }

  void _checkStreakRepairPrompt(UserProfile? profile) {
    if (_hasCheckedStreakRepair || profile == null) return;
    if (profile.canRepairStreak && profile.repairableStreak > 0) {
      _hasCheckedStreakRepair = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          StreakRepairDialog.show(context, profile);
        }
      });
    }
  }

  Future<void> _checkActiveSession() async {
    try {
      final currentData =
          await ref.read(focusRepositoryProvider).getCurrentSession();
      if (mounted &&
          currentData.hasActiveSession &&
          currentData.session != null) {
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
        return;
      }
    } catch (e) {
      debugPrint('Background session check failed (offline or not logged in): $e');
    }

    // Prompt streak repair if eligible and no active session running
    if (mounted) {
      final authStatus = ref.read(authProvider);
      _checkStreakRepairPrompt(authStatus.userProfile);
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
    _pageController.dispose();
    super.dispose();
  }

  void _navigateToExplore() {
    HapticFeedback.lightImpact();
    _pageController.animateToPage(
      1,
      duration: const Duration(milliseconds: 400),
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthStatus>(authProvider, (previous, next) {
      _checkStreakRepairPrompt(next.userProfile);
    });

    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      child: SafeArea(
        child: PageView(
          controller: _pageController,
          scrollDirection: Axis.vertical,
          physics: _isFocusLocked
              ? const NeverScrollableScrollPhysics()
              : const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
          onPageChanged: (index) {
            HapticFeedback.selectionClick();
          },
          children: [
            // Page 0: QuickStart Focus Page with Fade & Parallax Scale Depth
            AnimatedBuilder(
              animation: _pageController,
              builder: (context, child) {
                double progress = 0.0;
                if (_pageController.hasClients &&
                    _pageController.position.haveDimensions) {
                  progress = (_pageController.page ?? 0.0).clamp(0.0, 1.0);
                }

                // Stronger Scale: 1.0 -> 0.85
                final double scale = 1.0 - (progress * 0.15);
                // Stronger Opacity: 1.0 -> 0.15
                final double opacity = (1.0 - (progress * 0.85)).clamp(0.0, 1.0);
                // Enhanced downward parallax offset as page recedes
                final double translateY = progress * 80.0;

                return Transform.translate(
                  offset: Offset(0, translateY),
                  child: Transform.scale(
                    scale: scale,
                    child: Opacity(
                      opacity: opacity,
                      child: child,
                    ),
                  ),
                );
              },
              child: QuickStartPage(
                onFocusStateChanged: (isLocked) {
                  setState(() {
                    _isFocusLocked = isLocked;
                  });
                },
                onExploreTap: _navigateToExplore,
              ),
            ),

            // Page 1: Explore Page (Normal full page)
            ExplorePage(
              onClose: () {
                HapticFeedback.lightImpact();
                _pageController.animateToPage(
                  0,
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOutCubic,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
