import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lorofy/components/layout/app_header.dart';
import 'package:lorofy/components/ui/svg_asset.dart';
import 'package:lorofy/core/theme/app_theme.dart';
import 'package:lorofy/features/auth/presentation/providers/auth_provider.dart';
import 'package:lorofy/features/profile/presentation/providers/point_history_provider.dart';
import 'package:lorofy/features/profile/presentation/widgets/point_history_item_tile.dart';

class MyPointsPage extends ConsumerWidget {
  const MyPointsPage({super.key});

  Widget _buildPointsCard(BuildContext context, WidgetRef ref) {
    final authStatus = ref.watch(authProvider);
    final profile = authStatus.userProfile;
    final int rankPoints = profile?.rankPoints ?? authStatus.rankPoints ?? 0;
    final int goldCoins = profile?.goldCoins ?? 0;
    final int currentStreak = profile?.currentStreak ?? 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppPadding.lg, vertical: AppPadding.sm),
      padding: const EdgeInsets.all(AppPadding.xl),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Icon Circle
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: CupertinoColors.activeOrange.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: SVG(
                'assets/icons/point.svg',
                width: 36,
                height: 36,
              ),
            ),
          ),
          const SizedBox(height: AppPadding.md),
          const Text(
            'Your Balance',
            style: AppTextStyles.placeholder,
          ),
          const SizedBox(height: 4),
          Text(
            '$rankPoints pts',
            style: AppTextStyles.titleLarge.copyWith(
              fontSize: 34,
              color: AppColors.foreground,
            ),
          ),
          const SizedBox(height: AppPadding.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppPadding.md,
                  vertical: AppPadding.xs,
                ),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemYellow.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      CupertinoIcons.money_dollar_circle_fill,
                      color: CupertinoColors.systemYellow,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$goldCoins coins',
                      style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.foreground,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppPadding.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppPadding.md,
                  vertical: AppPadding.xs,
                ),
                decoration: BoxDecoration(
                  color: CupertinoColors.activeOrange.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      CupertinoIcons.flame_fill,
                      color: CupertinoColors.activeOrange,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$currentStreak-day streak',
                      style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.foreground,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

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
            _buildPointsCard(context, ref),

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
                          SizedBox(height: MediaQuery.of(context).size.height * 0.15),
                          const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  CupertinoIcons.clock_fill,
                                  color: AppColors.mutedForeground,
                                  size: 56,
                                ),
                                SizedBox(height: AppPadding.md),
                                Text(
                                  'No point transactions recorded yet',
                                  style: AppTextStyles.placeholder,
                                ),
                              ],
                            ),
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
                loading: () => const Center(
                  child: CupertinoActivityIndicator(),
                ),
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
                        child: const Text('Retry', style: AppTextStyles.buttonText),
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
