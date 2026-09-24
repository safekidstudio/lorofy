import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lorofy/components/layout/app_header.dart';
import 'package:lorofy/components/ui/app_empty_state.dart';
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

            // Points Card Header
            const MyPointsBalanceCard(),

            const Padding(
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

            // History Transactions List
            Expanded(
              child: historyAsync.when(
                data: (items) {
                  if (items.isEmpty) {
                    return RefreshIndicator(
                      onRefresh: () async {
                        ref.invalidate(pointHistoryProvider);
                        await ref.read(authProvider.notifier).refreshProfile();
                      },
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.08,
                          ),
                          const AppEmptyState(
                            title: 'No Point History Yet',
                            description:
                                'Complete focus sessions or repair streaks to earn points and view your activity log!',
                            iconPath: 'assets/icons/point.svg',
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(pointHistoryProvider);
                      await ref.read(authProvider.notifier).refreshProfile();
                    },
                    child: ListView.separated(
                      padding: const EdgeInsets.all(AppPadding.lg),
                      physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                      itemCount: items.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: AppPadding.md),
                      itemBuilder: (context, index) {
                        return PointHistoryItemTile(item: items[index]);
                      },
                    ),
                  );
                },
                loading: () => const PointHistorySkeleton(),
                error: (err, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        CupertinoIcons.exclamationmark_triangle_fill,
                        color: AppColors.destructive,
                        size: 44,
                      ),
                      const SizedBox(height: AppPadding.md),
                      Text(
                        'Failed to load point history: $err',
                        style: AppTextStyles.placeholder,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppPadding.lg),
                      CupertinoButton.filled(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppPadding.xl,
                          vertical: AppPadding.md,
                        ),
                        onPressed: () => ref.invalidate(pointHistoryProvider),
                        child: const Text('Retry',
                            style: AppTextStyles.buttonText),
                      ),
                    ],
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

