import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lorofy/components/ui/app_avatar.dart';
import 'package:lorofy/components/layout/app_header.dart';
import 'package:lorofy/components/ui/svg_asset.dart';
import 'package:lorofy/components/ui/toast.dart';
import 'package:lorofy/core/theme/app_theme.dart';
import 'package:lorofy/features/auth/presentation/providers/auth_provider.dart';

// Modular explore page sections
import 'package:lorofy/features/explore/presentation/widgets/explore_stats_section.dart';
import 'package:lorofy/features/explore/presentation/widgets/explore_leaderboard_section.dart';
import 'package:lorofy/features/explore/presentation/widgets/explore_chart_section.dart';
import 'package:lorofy/features/explore/presentation/widgets/explore_record_section.dart';

class ExplorePage extends ConsumerStatefulWidget {
  const ExplorePage({super.key});

  @override
  ConsumerState<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends ConsumerState<ExplorePage> {
  void _showSettings() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text(
          'Settings',
          style: TextStyle(
            fontFamily: AppTextStyles.titleFontFamily,
            fontSize: 24,
            color: Color(0xFF232321),
          ),
        ),
        message: Column(
          children: [
            const SizedBox(height: 8),
            Consumer(
              builder: (context, ref, child) {
                final authStatus = ref.watch(authProvider);
                final name = authStatus.displayName ?? 'User';
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const AppAvatar(path: null, size: 64),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF232321),
                          ),
                        ),
                        const Text(
                          'Lorofy Focus Champion',
                          style: TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 13,
                            color: Color(0xFF8E8E93),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              AppToast.show(
                context,
                message: 'Feature coming soon in the next release!',
                type: ToastType.info,
              );
            },
            child: const Text(
              'Edit Profile',
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                color: Color(0xFF232321),
              ),
            ),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              ref.read(authProvider.notifier).logout();
            },
            child: const Text(
              'Logout',
              style: TextStyle(fontFamily: AppTextStyles.fontFamily),
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Close',
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              color: Color(0xFF8E8E93),
            ),
          ),
        ),
      ),
    );
  }

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
                onPressed: _showSettings,
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
