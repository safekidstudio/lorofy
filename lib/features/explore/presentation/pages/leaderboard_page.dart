import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lorofy/components/layout/app_header.dart';
import 'package:lorofy/components/shared/drawing_container.dart';
import 'package:lorofy/components/ui/svg_asset.dart';
import 'package:lorofy/components/ui/sliding_segmented_control.dart';
import 'package:lorofy/components/ui/shimmer.dart';
import 'package:lorofy/components/ui/fomo_toast.dart';
import 'package:lorofy/core/theme/app_theme.dart';
import 'package:lorofy/features/explore/presentation/providers/leaderboard_provider.dart';
import 'package:lorofy/features/explore/domain/models/leaderboard.dart';

class LeaderboardPage extends ConsumerStatefulWidget {
  const LeaderboardPage({super.key});

  @override
  ConsumerState<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends ConsumerState<LeaderboardPage> {
  int _selectedTab = 0; // 0: Day, 1: Week, 2: National

  @override
  Widget build(BuildContext context) {
    // Listen to realtime SSE updates to refresh and show toasts
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

    final String timeframe = switch (_selectedTab) {
      0 => 'TODAY',
      1 => 'WEEK',
      _ => 'ALL',
    };

    final leaderboardAsync = ref.watch(
      leaderboardProvider(timeframe: timeframe),
    );

    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
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
              title: 'Leaderboard',
            ),

            // Scrollable Segmented Tab, Podium & Ranks List
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 12),
                    // Tabs Selector
                    Center(
                      child: SlidingSegmentedControl(
                        tabs: const ['Day', 'Week', 'National'],
                        selectedIndex: _selectedTab,
                        onTabChanged: (index) {
                          setState(() {
                            _selectedTab = index;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 60),

                    leaderboardAsync.when(
                      loading: () => const _LeaderboardPageSkeleton(),
                      error: (err, stack) => SizedBox(
                        height: 300,
                        child: Center(
                          child: Text(
                            'Error loading leaderboard: $err',
                            style: TextStyle(
                              fontFamily: AppTextStyles.fontFamily,
                              color: CupertinoColors.systemRed,
                            ),
                          ),
                        ),
                      ),
                      data: (data) {
                        final list = data.leaderboard.content;

                        final first = list.isNotEmpty ? list[0] : null;
                        final second = list.length > 1 ? list[1] : null;
                        final third = list.length > 2 ? list[2] : null;

                        final listItems = list.skip(3).toList();

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Podium
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                // Rank 2 (Left)
                                Expanded(
                                  child: second != null
                                      ? _buildPodiumCol(
                                          second,
                                          borderColor: const Color(0xFFD5DEEA),
                                          isYou:
                                              data.currentUserRank != null &&
                                              second.profileId ==
                                                  data.currentUserRank!.profileId,
                                        )
                                      : const SizedBox(height: 130),
                                ),

                                // Rank 1 (Center) - taller
                                Expanded(
                                  child: first != null
                                      ? _buildPodiumCol(
                                          first,
                                          isCenter: true,
                                          borderColor: const Color(0xFFFFB61D),
                                          isYou:
                                              data.currentUserRank != null &&
                                              first.profileId ==
                                                  data.currentUserRank!.profileId,
                                        )
                                      : const SizedBox(height: 150),
                                ),

                                // Rank 3 (Right)
                                Expanded(
                                  child: third != null
                                      ? _buildPodiumCol(
                                          third,
                                          borderColor: const Color(0xFFD96806),
                                          isYou:
                                              data.currentUserRank != null &&
                                              third.profileId ==
                                                  data.currentUserRank!.profileId,
                                        )
                                      : const SizedBox(height: 130),
                                ),
                              ],
                            ),

                            const SizedBox(height: 32),

                            // Ranks List 4-10
                            if (listItems.isEmpty)
                              SizedBox(
                                height: 100,
                                child: Center(
                                  child: Text(
                                    'No further rankings available',
                                    style: TextStyle(
                                      fontFamily: AppTextStyles.fontFamily,
                                      fontSize: 14,
                                      color: AppColors.secondary,
                                    ),
                                  ),
                                ),
                              )
                            else
                              Column(
                                children: listItems.map((entry) {
                                  final isYou =
                                      data.currentUserRank != null &&
                                      entry.profileId ==
                                          data.currentUserRank!.profileId;

                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: isYou
                                            ? const Color(0xFF072013)
                                            : CupertinoColors.white,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 10,
                                      ),
                                      child: Row(
                                        children: [
                                          // Rank number
                                          SizedBox(
                                            width: 24,
                                            child: Text(
                                              entry.rank.toString(),
                                              style: TextStyle(
                                                fontFamily: AppTextStyles
                                                    .titleFontFamily,
                                                fontSize: 16,
                                                color: isYou
                                                    ? CupertinoColors.white
                                                    : const Color(0xFF232321),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          // Avatar
                                          Container(
                                            width: 32,
                                            height: 32,
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                            ),
                                            clipBehavior: Clip.antiAlias,
                                            child: Image.network(
                                              entry.avatarUrl ??
                                                  'https://res.cloudinary.com/ikupgdru/image/upload/v1784619368/08_tqar6z_nvbvsx.png',
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) => Container(
                                                    color: const Color(
                                                      0xFFE5E5EA,
                                                    ),
                                                    child: const Icon(
                                                      CupertinoIcons
                                                          .person_fill,
                                                      size: 16,
                                                      color: Color(0xFF8E8E93),
                                                    ),
                                                  ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          // Name
                                          Expanded(
                                            child: Text(
                                              isYou ? 'You' : entry.displayName,
                                              style: TextStyle(
                                                fontFamily:
                                                    AppTextStyles.fontFamily,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: isYou
                                                    ? CupertinoColors.white
                                                    : AppColors.primary,
                                              ),
                                            ),
                                          ),
                                          // Points
                                          Text(
                                            '${entry.points} pts',
                                            style: TextStyle(
                                              fontFamily:
                                                  AppTextStyles.fontFamily,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                              color: isYou
                                                  ? CupertinoColors.white
                                                        .withValues(alpha: 0.8)
                                                  : const Color(0xFF8E8E93),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPodiumCol(
    LeaderboardItem user, {
    bool isCenter = false,
    required Color borderColor,
    required bool isYou,
  }) {
    final double avatarSize = isCenter ? 100.0 : 80.0;
    Color badgeColor;
    switch (user.rank) {
      case 1:
        badgeColor = const Color(0xFFFFCA28);
      case 2:
        badgeColor = const Color(0xFFFFFFFF);
      case 3:
        badgeColor = const Color(0xFFF6A661);
      default:
        badgeColor = borderColor;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // Organic blob avatar drawn via DrawingContainer
            DrawingContainer(
              shape: DrawingShape.blob,
              width: avatarSize,
              height: avatarSize,
              borderColor: borderColor,
              borderWidth: 4.0,
              fillColor: CupertinoColors.transparent,
              child: Image.network(
                user.avatarUrl ??
                    'https://res.cloudinary.com/ikupgdru/image/upload/v1784619368/08_tqar6z_nvbvsx.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: const Color(0xFFE5E5EA),
                  child: Icon(
                    CupertinoIcons.person_fill,
                    size: avatarSize * 0.5,
                    color: const Color(0xFF8E8E93),
                  ),
                ),
              ),
            ),

            // Crown on top of Rank 1
            if (user.rank == 1)
              const Positioned(
                top: -45, // Adjusted to fit the 65x65 crown SVG cleanly
                child: SVG(
                  'assets/illustrations/crown.svg',
                  width: 65,
                  height: 65,
                ),
              ),

            // Rank badge at bottom-center
            Positioned(
              bottom: -14,
              child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: badgeColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: borderColor, width: 3),
                ),
                alignment: Alignment.center,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outline stroke
                    Text(
                      user.rank.toString(),
                      style: TextStyle(
                        fontFamily: AppTextStyles.titleFontFamily,
                        fontSize: 14,
                        foreground: Paint()
                          ..style = PaintingStyle.stroke
                          ..strokeWidth = 1
                          ..color = borderColor,
                      ),
                    ),
                    // Solid text fill
                    Text(
                      user.rank.toString(),
                      style: const TextStyle(
                        fontFamily: AppTextStyles.titleFontFamily,
                        color: AppColors.primary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        // User Name
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Text(
            isYou ? 'You' : user.displayName,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(height: 4),
        // Points
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SVG('assets/illustrations/flower.svg', width: 12, height: 12),
            const SizedBox(width: 2),
            Text(
              '${user.points} pts',
              style: const TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 12,
                color: AppColors.secondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _LeaderboardPageSkeleton extends StatelessWidget {
  const _LeaderboardPageSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Podium Skeleton
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const ShimmerPlaceholder.circular(size: 80),
                  const SizedBox(height: 12),
                  ShimmerPlaceholder.rectangular(
                    width: 60,
                    height: 14,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 4),
                  ShimmerPlaceholder.rectangular(
                    width: 40,
                    height: 12,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const ShimmerPlaceholder.circular(size: 100),
                  const SizedBox(height: 12),
                  ShimmerPlaceholder.rectangular(
                    width: 80,
                    height: 16,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 4),
                  ShimmerPlaceholder.rectangular(
                    width: 50,
                    height: 12,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const ShimmerPlaceholder.circular(size: 80),
                  const SizedBox(height: 12),
                  ShimmerPlaceholder.rectangular(
                    width: 60,
                    height: 14,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 4),
                  ShimmerPlaceholder.rectangular(
                    width: 40,
                    height: 12,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 40),
        // List Item Skeletons
        Column(
          children: List.generate(
            5,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: ShimmerPlaceholder.rectangular(
                height: 52,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
