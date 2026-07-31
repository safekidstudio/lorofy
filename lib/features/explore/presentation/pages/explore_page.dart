import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lorofy/components/layout/app_header.dart';
import 'package:lorofy/components/ui/svg_asset.dart';
import 'package:lorofy/core/theme/app_theme.dart';

// Modular explore page sections
import 'package:lorofy/features/explore/presentation/widgets/explore_stats_section.dart';
import 'package:lorofy/features/explore/presentation/widgets/explore_leaderboard_section.dart';
import 'package:lorofy/features/explore/presentation/widgets/explore_chart_section.dart';
import 'package:lorofy/features/explore/presentation/widgets/explore_record_section.dart';
import 'package:lorofy/features/profile/presentation/pages/profile_page.dart';

class ExplorePage extends ConsumerStatefulWidget {
  const ExplorePage({super.key});

  @override
  ConsumerState<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends ConsumerState<ExplorePage> {

  @override
  Widget build(BuildContext context) {
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
                onPressed: () => context.pop(),
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

            // Scrollable content fills remaining space
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // land.svg decorator scrolls with content
                    Transform.translate(
                      offset: const Offset(0, -12),
                      child: const SVG(
                        'assets/illustrations/land.svg',
                        width: double.infinity,
                        height: 82,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Transform.translate(
                      offset: const Offset(
                        0,
                        -12,
                      ), // Overlap 1px to prevent gaps
                      child: const Padding(
                        padding: EdgeInsets.only(
                          left: 16,
                          right: 16,
                          bottom: 16,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // 1. Focus & Kill Stats overview section
                            ExploreStatsSection(),
                            SizedBox(height: 24),

                            // 2. Leaderboard podium section
                            ExploreLeaderboardSection(),
                            SizedBox(height: 24),

                            // 3. Recent focus statistics chart section
                            ExploreChartSection(),
                            SizedBox(height: 24),

                            // 4. Detailed focus records list section
                            ExploreRecordSection(),
                            SizedBox(height: 32),
                          ],
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
