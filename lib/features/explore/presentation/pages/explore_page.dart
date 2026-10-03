import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lorofy/components/layout/app_header.dart';
import 'package:lorofy/components/ui/fomo_toast.dart';
import 'package:lorofy/components/ui/svg_asset.dart';
import 'package:lorofy/core/theme/app_theme.dart';
import 'package:lorofy/features/explore/presentation/providers/leaderboard_provider.dart';

// Modular explore page sections
import 'package:lorofy/features/explore/presentation/widgets/explore_stats_section.dart';
import 'package:lorofy/features/explore/presentation/widgets/explore_leaderboard_section.dart';
import 'package:lorofy/features/explore/presentation/widgets/explore_chart_section.dart';
import 'package:lorofy/features/explore/presentation/widgets/explore_record_section.dart';
import 'package:lorofy/features/profile/presentation/pages/profile_page.dart';

import 'package:lorofy/core/localization/l10n_extension.dart';

/// Pinned Explore AppHeader delegate for SliverPersistentHeader
class ExploreHeaderDelegate extends SliverPersistentHeaderDelegate {
  final VoidCallback onBack;
  final VoidCallback onProfile;

  ExploreHeaderDelegate({
    required this.onBack,
    required this.onProfile,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.background,
      child: AppHeader(
        leftActions: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: onBack,
          child: const SVG(
            'assets/icons/cancel.svg',
            height: 24,
            width: 24,
          ),
        ),
        title: context.l10n.explore_title,
        rightActions: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: onProfile,
          child: const SVG(
            'assets/icons/user-square.svg',
            height: 24,
            width: 24,
          ),
        ),
      ),
    );
  }

  @override
  double get maxExtent => 56.0;

  @override
  double get minExtent => 56.0;

  @override
  bool shouldRebuild(covariant ExploreHeaderDelegate oldDelegate) => false;
}

/// Modular Explore Content Slivers (Land SVG, Stats, Leaderboard, Chart, Records)
class ExploreContentSlivers extends StatelessWidget {
  const ExploreContentSlivers({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: Transform.translate(
            offset: const Offset(0, -12),
            child: const RepaintBoundary(
              child: SVG(
                'assets/illustrations/land.svg',
                width: double.infinity,
                height: 82,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: 32,
          ),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const RepaintBoundary(child: ExploreStatsSection()),
              const SizedBox(height: 24),
              const RepaintBoundary(child: ExploreLeaderboardSection()),
              const SizedBox(height: 24),
              const RepaintBoundary(child: ExploreChartSection()),
              const SizedBox(height: 24),
              const RepaintBoundary(child: ExploreRecordSection()),
            ]),
          ),
        ),
      ],
    );
  }
}

/// Standalone Explore Page widget
class ExplorePage extends ConsumerWidget {
  final VoidCallback? onClose;

  const ExplorePage({super.key, this.onClose});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            SliverPersistentHeader(
              pinned: true,
              delegate: ExploreHeaderDelegate(
                onBack: () {
                  if (onClose != null) {
                    onClose!();
                  } else if (context.canPop()) {
                    context.pop();
                  }
                },
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
            const ExploreContentSlivers(),
          ],
        ),
      ),
    );
  }
}
