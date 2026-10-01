import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lorofy/components/layout/app_header.dart';
import 'package:lorofy/components/ui/app_empty_state.dart';
import 'package:lorofy/components/ui/app_refresh_control.dart';
import 'package:lorofy/components/ui/svg_asset.dart';
import 'package:lorofy/core/theme/app_theme.dart';
import 'package:lorofy/features/auth/presentation/providers/auth_provider.dart';
import 'package:lorofy/features/profile/presentation/providers/point_history_provider.dart';
import 'package:lorofy/features/profile/presentation/widgets/my_points_balance_card.dart';
import 'package:lorofy/features/profile/presentation/widgets/point_history_item_tile.dart';
import 'package:lorofy/features/profile/presentation/widgets/point_history_skeleton.dart';

class MyPointsPage extends ConsumerWidget {
  const MyPointsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(pointHistoryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            AppHeader(
              leftActions: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(AppPadding.sm),
                  decoration: const BoxDecoration(
                    color: AppColors.secondary,
                    shape: BoxShape.circle,
                  ),
                  child: const SVG(
                    'assets/icons/chevron-left.svg',
                    width: 24,
                    height: 24,
                  ),
                ),
              ),
              title: 'My Points',
            ),

            // Scrollable Content
            Expanded(
              child: CupertinoScrollbar(
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  slivers: [
                    // Pull To Refresh Control
                    AppRefreshControl(
                      onRefresh: () async {
                        ref.invalidate(pointHistoryProvider);
                        await ref.read(authProvider.notifier).refreshProfile();
                      },
                    ),

                    // Points Card Header
                    const SliverToBoxAdapter(
                      child: MyPointsBalanceCard(),
                    ),

                    // Section Title
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          AppPadding.lg,
                          AppPadding.md,
                          AppPadding.lg,
                          AppPadding.xs,
                        ),
                        child: Text(
                          'Point History',
                          style: AppTextStyles.titleMedium,
                        ),
                      ),
                    ),

                    // History Transactions List Slivers
                    historyAsync.when(
                      data: (items) {
                        if (items.isEmpty) {
                          return const SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.only(top: 32, bottom: 48),
                              child: AppEmptyState(
                                title: 'No Point History Yet',
                                description:
                                    'Complete focus sessions or repair streaks to earn points and view your activity log!',
                                iconPath: 'assets/icons/point.svg',
                                riveSize: 64,
                              ),
                            ),
                          );
                        }

                        return SliverPadding(
                          padding: const EdgeInsets.all(AppPadding.lg),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                if (index.isOdd) {
                                  return const SizedBox(height: AppPadding.md);
                                }
                                final itemIndex = index ~/ 2;
                                return PointHistoryItemTile(item: items[itemIndex]);
                              },
                              childCount: items.length * 2 - 1,
                            ),
                          ),
                        );
                      },
                      loading: () => const SliverToBoxAdapter(
                        child: PointHistorySkeleton(),
                      ),
                      error: (err, stack) => SliverToBoxAdapter(
                        child: AppEmptyState.error(
                          title: 'Unable to Load Point History',
                          description:
                              'Please check your internet connection and tap anywhere to reload.',
                          onRetry: () => ref.invalidate(pointHistoryProvider),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
