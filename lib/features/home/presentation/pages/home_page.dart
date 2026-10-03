import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lorofy/components/ui/fomo_toast.dart';
import 'package:lorofy/core/theme/app_theme.dart';
import 'package:lorofy/core/utils/logger.dart';
import 'package:lorofy/features/auth/data/models/user_profile.dart';
import 'package:lorofy/features/auth/presentation/providers/auth_provider.dart';
import 'package:lorofy/features/explore/presentation/pages/explore_page.dart';
import 'package:lorofy/features/explore/presentation/providers/leaderboard_provider.dart';
import 'package:lorofy/features/focus/data/repositories/focus_repository_impl.dart';
import 'package:lorofy/features/focus/presentation/pages/quick_start_page.dart';
import 'package:lorofy/features/focus/presentation/widgets/modals/active_session_dialog.dart';
import 'package:lorofy/features/home/presentation/physics/quick_start_snap_scroll_physics.dart';
import 'package:lorofy/features/profile/presentation/pages/profile_page.dart';
import 'package:lorofy/core/localization/l10n_extension.dart';
import 'package:lorofy/features/profile/presentation/widgets/streak_repair_dialog.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  late final ScrollController _scrollController;
  final _isQuickStartVisibleNotifier = ValueNotifier<bool>(true);
  bool _isFocusLocked = false;
  bool _hasCheckedStreakRepair = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    // Silently check active session state & streak repair on app launch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkActiveSession();
    });
  }

  void _onScroll() {
    if (_scrollController.hasClients &&
        _scrollController.position.haveDimensions) {
      final bool isVisible = _scrollController.offset <= 1.0;
      if (_isQuickStartVisibleNotifier.value != isVisible) {
        _isQuickStartVisibleNotifier.value = isVisible;
      }
    }
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
      AppLogger.warning(
        'Background session check failed (offline or not logged in): $e',
        tag: 'HomePage',
      );
    }

    // Prompt streak repair if eligible and no active session running
    if (mounted) {
      final authStatus = ref.read(authProvider);
      _checkStreakRepairPrompt(authStatus.userProfile);
    }
  }

  void _showSessionCompletedBanner(int minutes) {
    final l10n = context.l10n;
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(l10n.home_congratulationsTitle),
        content: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            l10n.home_sessionCompletedInactive(minutes),
          ),
        ),
        actions: [
          CupertinoDialogAction(
            child: Text(l10n.home_awesome),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _isQuickStartVisibleNotifier.dispose();
    super.dispose();
  }

  void _navigateToExplore(double targetOffset) {
    _scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOutCubic,
    );
  }

  void _navigateToQuickStart() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthStatus>(authProvider, (previous, next) {
      _checkStreakRepairPrompt(next.userProfile);
    });

    ref.listen(leaderboardRealtimeStreamProvider, (previous, next) {
      next.whenData((fomoEvent) {
        FomoToast.show(
          context,
          displayName: fomoEvent.displayName,
          avatarUrl: fomoEvent.avatarUrl,
          earnedPoints: fomoEvent.earnedPoints,
        );
      });
    });

    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double viewportHeight = constraints.maxHeight;

            return CustomScrollView(
              controller: _scrollController,
              cacheExtent: 2500.0, // Pre-renders Explore sections offscreen for 120fps instant smooth scrolling
              physics: _isFocusLocked
                  ? const NeverScrollableScrollPhysics()
                  : QuickStartSnapScrollPhysics(
                      itemDimension: viewportHeight,
                      parent: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                    ),
              slivers: [
                // 1. QuickStart Focus Page with smooth parallax transform
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: viewportHeight,
                    child: _QuickStartParallaxItem(
                      scrollController: _scrollController,
                      viewportHeight: viewportHeight,
                      onFocusStateChanged: (isLocked) {
                        if (_isFocusLocked != isLocked) {
                          setState(() {
                            _isFocusLocked = isLocked;
                          });
                        }
                      },
                      onExploreTap: () => _navigateToExplore(viewportHeight),
                      isFullyVisibleListenable: _isQuickStartVisibleNotifier,
                    ),
                  ),
                ),

                // 2. Pinned Explore Header
                SliverPersistentHeader(
                  pinned: true,
                  delegate: ExploreHeaderDelegate(
                    onBack: _navigateToQuickStart,
                    onProfile: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => const ProfilePage(),
                        ),
                      );
                    },
                  ),
                ),

                // 3. Modular Explore Content Slivers
                const ExploreContentSlivers(),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Helper widget to encapsulate parallax and fade animation for QuickStartPage
class _QuickStartParallaxItem extends StatelessWidget {
  final ScrollController scrollController;
  final double viewportHeight;
  final ValueChanged<bool> onFocusStateChanged;
  final VoidCallback onExploreTap;
  final ValueListenable<bool> isFullyVisibleListenable;

  const _QuickStartParallaxItem({
    required this.scrollController,
    required this.viewportHeight,
    required this.onFocusStateChanged,
    required this.onExploreTap,
    required this.isFullyVisibleListenable,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: scrollController,
      child: QuickStartPage(
        onFocusStateChanged: onFocusStateChanged,
        onExploreTap: onExploreTap,
        isFullyVisibleListenable: isFullyVisibleListenable,
      ),
      builder: (context, child) {
        double offset = 0.0;
        if (scrollController.hasClients &&
            scrollController.position.haveDimensions) {
          offset = scrollController.offset;
        }
        final double progress = viewportHeight > 0
            ? (offset / viewportHeight).clamp(0.0, 1.0)
            : 0.0;
        final double scale = 1.0 - (progress * 0.12);
        final double opacity = (1.0 - (progress * 0.75)).clamp(0.0, 1.0);
        final double translateY = progress * 60.0;

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
    );
  }
}

