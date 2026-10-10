import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lorofy/components/layout/app_header.dart';
import 'package:lorofy/components/ui/app_empty_state.dart';
import 'package:lorofy/components/ui/app_refresh_control.dart';
import 'package:lorofy/components/ui/fomo_toast.dart';
import 'package:lorofy/components/ui/sliding_segmented_control.dart';
import 'package:lorofy/components/ui/svg_asset.dart';
import 'package:lorofy/core/localization/l10n_extension.dart';
import 'package:lorofy/core/theme/app_theme.dart';
import 'package:lorofy/features/explore/presentation/providers/leaderboard_provider.dart';
import 'package:lorofy/features/explore/presentation/widgets/leaderboard/leaderboard.dart';

class LeaderboardPage extends ConsumerStatefulWidget {
  const LeaderboardPage({super.key});

  @override
  ConsumerState<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends ConsumerState<LeaderboardPage> {
  int _selectedTab = 0; // 0: Day, 1: Week, 2: National
  final Set<String> _recentlyBoosted = {};

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    // Listen to real-time SSE updates for toast notifications & live rank invalidation
    ref.listen(leaderboardRealtimeStreamProvider, (previous, next) {
      next.whenData((fomoEvent) {
        FomoToast.show(
          context,
          displayName: fomoEvent.displayName,
          avatarUrl: fomoEvent.avatarUrl,
          earnedPoints: fomoEvent.earnedPoints,
        );

        // Highlight recently active user
        if (mounted) {
          setState(() {
            _recentlyBoosted.add(fomoEvent.displayName);
          });
        }
      });
    });

    final String timeframe = switch (_selectedTab) {
      0 => 'TODAY',
      1 => 'WEEK',
      _ => 'ALL',
    };

    final leaderboardAsync = ref.watch(leaderboardProvider(timeframe: timeframe));

    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // App Header
            AppHeader(
              leftActions: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE4E4E6),
                    shape: BoxShape.circle,
                  ),
                  child: const SVG(
                    'assets/icons/chevron-left.svg',
                    width: 24,
                    height: 24,
                  ),
                ),
              ),
              title: l10n.explore_leaderboard,
            ),

            // Scrollable Content Area
            Expanded(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: [
                  AppRefreshControl(
                    onRefresh: () async {
                      ref.invalidate(leaderboardProvider(timeframe: timeframe));
                      await ref.read(leaderboardProvider(timeframe: timeframe).future);
                    },
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 12),
                          // Timeframe Tabs Selector
                          Center(
                            child: SlidingSegmentedControl(
                              tabs: [
                                l10n.common_day,
                                l10n.common_week,
                                l10n.common_all,
                              ],
                              selectedIndex: _selectedTab,
                              onTabChanged: (index) {
                                if (_selectedTab != index) {
                                  setState(() {
                                    _selectedTab = index;
                                    _recentlyBoosted.clear();
                                  });
                                }
                              },
                            ),
                          ),
                          const SizedBox(height: 28),

                          leaderboardAsync.when(
                            loading: () => const LeaderboardPageSkeleton(),
                            error: (err, stack) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 24),
                              child: AppEmptyState.error(
                                title: l10n.common_retry,
                                onRetry: () => ref.invalidate(
                                  leaderboardProvider(timeframe: timeframe),
                                ),
                              ),
                            ),
                            data: (data) {
                              final rawList = data.leaderboard.content;

                              if (rawList.isEmpty) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 40),
                                  child: AppEmptyState(
                                    title: l10n.explore_noRankingsYet,
                                    description: l10n.explore_noRankingsDesc,
                                    rivePath: 'assets/rive/cat-not-track.riv',
                                  ),
                                );
                              }

                              final top3 = rawList.take(3).toList();
                              final listItems = rawList.skip(3).toList();

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Top 3 Podium Stage
                                  PodiumStage(
                                    top3: top3,
                                    currentUserRank: data.currentUserRank,
                                    recentlyBoosted: _recentlyBoosted,
                                  ),

                                  const SizedBox(height: 32),

                                  // Rank 4+ Reordering List
                                  if (listItems.isNotEmpty)
                                    ReorderingCardsList(
                                      listItems: listItems,
                                      currentUserRank: data.currentUserRank,
                                      recentlyBoosted: _recentlyBoosted,
                                    ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
