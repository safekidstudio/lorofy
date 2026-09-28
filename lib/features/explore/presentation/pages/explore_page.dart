import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lorofy/components/layout/app_header.dart';
import 'package:lorofy/components/ui/svg_asset.dart';
import 'package:lorofy/core/theme/app_theme.dart';
import 'package:lorofy/components/ui/fomo_toast.dart';
import 'package:lorofy/features/explore/presentation/providers/leaderboard_provider.dart';

// Modular explore page sections
import 'package:lorofy/features/explore/presentation/widgets/explore_stats_section.dart';
import 'package:lorofy/features/explore/presentation/widgets/explore_leaderboard_section.dart';
import 'package:lorofy/features/explore/presentation/widgets/explore_chart_section.dart';
import 'package:lorofy/features/explore/presentation/widgets/explore_record_section.dart';
import 'package:lorofy/features/profile/presentation/pages/profile_page.dart';

class ExplorePage extends ConsumerStatefulWidget {
  final VoidCallback? onClose;

  const ExplorePage({super.key, this.onClose});

  @override
  ConsumerState<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends ConsumerState<ExplorePage> {

  @override
  Widget build(BuildContext context) {
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Fixed header — sits naturally at top via Column
            AppHeader(
              leftActions: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  if (widget.onClose != null) {
                    widget.onClose!();
                  } else if (context.canPop()) {
                    context.pop();
                  }
                },
                child: const SVG(
                  'assets/icons/cancel.svg',
                  height: 24,
                  width: 24,
                ),
              ),
              title: 'Explore',
              rightActions: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => const ProfilePage(),
                    ),
                  );
                },
                child: const SVG(
                  'assets/icons/user-square.svg',
                  height: 24,
                  width: 24,
                ),
              ),
            ),

            // Scrollable content with CustomScrollView & Slivers for 60fps performance
            Expanded(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
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
                        const RepaintBoundary(
                          child: ExploreStatsSection(),
                        ),
                        const SizedBox(height: 24),
                        const RepaintBoundary(
                          child: ExploreLeaderboardSection(),
                        ),
                        const SizedBox(height: 24),
                        const RepaintBoundary(
                          child: ExploreChartSection(),
                        ),
                        const SizedBox(height: 24),
                        const RepaintBoundary(
                          child: ExploreRecordSection(),
                        ),
                      ]),
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
