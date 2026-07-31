import 'package:flutter/cupertino.dart';
import 'package:lorofy/components/layout/app_header.dart';
import 'package:lorofy/components/shared/drawing_container.dart';
import 'package:lorofy/components/ui/svg_asset.dart';
import 'package:lorofy/components/ui/sliding_segmented_control.dart';
import 'package:lorofy/core/theme/app_theme.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  int _selectedTab = 0; // 0: Day, 1: Week, 2: National

  // Podium configurations per tab (Graves/Asta/Nozel, James/James/Yuno, David/Yuno/Charlotte)
  final List<List<PodiumUser>> podiumData = const [
    // Day Tab
    [
      PodiumUser(
        name: 'Graves',
        points: 90,
        rank: 2,
        avatarUrl:
            'https://res.cloudinary.com/ikupgdru/image/upload/v1784619368/08_tqar6z_nvbvsx.png',
        borderColor: Color(0xFFD5DEEA),
      ),
      PodiumUser(
        name: 'James',
        points: 120,
        rank: 1,
        avatarUrl:
            'https://res.cloudinary.com/ikupgdru/image/upload/v1784619376/64_d4fo1k_wnebqr.png',
        borderColor: Color(0xFFFFB61D),
      ),
      PodiumUser(
        name: 'David',
        points: 75,
        rank: 3,
        avatarUrl:
            'https://res.cloudinary.com/ikupgdru/image/upload/v1784619368/02_aus2zc_tfpypg.png',
        borderColor: Color(0xFFD96806),
      ),
    ],
    // Week Tab
    [
      PodiumUser(
        name: 'Asta',
        points: 450,
        rank: 2,
        avatarUrl:
            'https://res.cloudinary.com/ikupgdru/image/upload/v1784619368/04_hwtksg_j0r2vn.png',
        borderColor: Color(0xFFD5DEEA),
      ),
      PodiumUser(
        name: 'James',
        points: 620,
        rank: 1,
        avatarUrl:
            'https://res.cloudinary.com/ikupgdru/image/upload/v1784619376/64_d4fo1k_wnebqr.png',
        borderColor: Color(0xFFFFB61D),
      ),
      PodiumUser(
        name: 'Yuno',
        points: 410,
        rank: 3,
        avatarUrl:
            'https://res.cloudinary.com/ikupgdru/image/upload/v1784619368/05_ld5pxz_gghyvn.png',
        borderColor: Color(0xFFD96806),
      ),
    ],
    // National Tab
    [
      PodiumUser(
        name: 'Nozel Silva',
        points: 2430,
        rank: 2,
        avatarUrl:
            'https://res.cloudinary.com/ikupgdru/image/upload/v1784619368/03_gq9hsn_s1k2vn.png',
        borderColor: Color(0xFFD5DEEA),
      ),
      PodiumUser(
        name: 'Yuno',
        points: 2900,
        rank: 1,
        avatarUrl:
            'https://res.cloudinary.com/ikupgdru/image/upload/v1784619368/05_ld5pxz_gghyvn.png',
        borderColor: Color(0xFFFFB61D),
      ),
      PodiumUser(
        name: 'Charlotte',
        points: 2100,
        rank: 3,
        avatarUrl:
            'https://res.cloudinary.com/ikupgdru/image/upload/v1784619368/01_o2xysg_r3k2vn.png',
        borderColor: Color(0xFFD96806),
      ),
    ],
  ];

  // Ranks lists per tab (ranks 4 to 10)
  final List<List<LeaderboardEntry>> listData = const [
    // Day Tab
    [
      LeaderboardEntry(
        rank: 4,
        name: 'Yuno Grinberyal',
        points: 60,
        avatarUrl:
            'https://res.cloudinary.com/ikupgdru/image/upload/v1784619368/05_ld5pxz_gghyvn.png',
      ),
      LeaderboardEntry(
        rank: 5,
        name: 'Asta',
        points: 55,
        avatarUrl:
            'https://res.cloudinary.com/ikupgdru/image/upload/v1784619368/04_hwtksg_j0r2vn.png',
      ),
      LeaderboardEntry(
        rank: 6,
        name: 'You',
        points: 50,
        avatarUrl:
            'https://res.cloudinary.com/ikupgdru/image/upload/v1784619368/06_d6z9zq_v5hkvn.png',
        isYou: true,
      ),
      LeaderboardEntry(
        rank: 7,
        name: 'Nozel Silva',
        points: 43,
        avatarUrl:
            'https://res.cloudinary.com/ikupgdru/image/upload/v1784619368/03_gq9hsn_s1k2vn.png',
      ),
      LeaderboardEntry(
        rank: 8,
        name: 'Charlotte',
        points: 36,
        avatarUrl:
            'https://res.cloudinary.com/ikupgdru/image/upload/v1784619368/01_o2xysg_r3k2vn.png',
      ),
      LeaderboardEntry(
        rank: 9,
        name: 'Langris',
        points: 20,
        avatarUrl:
            'https://res.cloudinary.com/ikupgdru/image/upload/v1784619368/07_q9u5e8_cplg8n.png',
      ),
      LeaderboardEntry(
        rank: 10,
        name: 'Marsha',
        points: 12,
        avatarUrl:
            'https://res.cloudinary.com/ikupgdru/image/upload/v1784619368/10_x2zysg_m5k2vn.png',
      ),
    ],
    // Week Tab
    [
      LeaderboardEntry(
        rank: 4,
        name: 'Graves',
        points: 380,
        avatarUrl:
            'https://res.cloudinary.com/ikupgdru/image/upload/v1784619368/08_tqar6z_nvbvsx.png',
      ),
      LeaderboardEntry(
        rank: 5,
        name: 'You',
        points: 350,
        avatarUrl:
            'https://res.cloudinary.com/ikupgdru/image/upload/v1784619368/06_d6z9zq_v5hkvn.png',
        isYou: true,
      ),
      LeaderboardEntry(
        rank: 6,
        name: 'David',
        points: 320,
        avatarUrl:
            'https://res.cloudinary.com/ikupgdru/image/upload/v1784619368/02_aus2zc_tfpypg.png',
      ),
      LeaderboardEntry(
        rank: 7,
        name: 'Nozel Silva',
        points: 290,
        avatarUrl:
            'https://res.cloudinary.com/ikupgdru/image/upload/v1784619368/03_gq9hsn_s1k2vn.png',
      ),
      LeaderboardEntry(
        rank: 8,
        name: 'Charlotte',
        points: 240,
        avatarUrl:
            'https://res.cloudinary.com/ikupgdru/image/upload/v1784619368/01_o2xysg_r3k2vn.png',
      ),
      LeaderboardEntry(
        rank: 9,
        name: 'Langris',
        points: 180,
        avatarUrl:
            'https://res.cloudinary.com/ikupgdru/image/upload/v1784619368/07_q9u5e8_cplg8n.png',
      ),
      LeaderboardEntry(
        rank: 10,
        name: 'Marsha',
        points: 90,
        avatarUrl:
            'https://res.cloudinary.com/ikupgdru/image/upload/v1784619368/10_x2zysg_m5k2vn.png',
      ),
    ],
    // National Tab
    [
      LeaderboardEntry(
        rank: 4,
        name: 'Graves',
        points: 1950,
        avatarUrl:
            'https://res.cloudinary.com/ikupgdru/image/upload/v1784619368/08_tqar6z_nvbvsx.png',
      ),
      LeaderboardEntry(
        rank: 5,
        name: 'James',
        points: 1820,
        avatarUrl:
            'https://res.cloudinary.com/ikupgdru/image/upload/v1784619376/64_d4fo1k_wnebqr.png',
      ),
      LeaderboardEntry(
        rank: 6,
        name: 'David',
        points: 1750,
        avatarUrl:
            'https://res.cloudinary.com/ikupgdru/image/upload/v1784619368/02_aus2zc_tfpypg.png',
      ),
      LeaderboardEntry(
        rank: 7,
        name: 'Asta',
        points: 1500,
        avatarUrl:
            'https://res.cloudinary.com/ikupgdru/image/upload/v1784619368/04_hwtksg_j0r2vn.png',
      ),
      LeaderboardEntry(
        rank: 8,
        name: 'You',
        points: 1420,
        avatarUrl:
            'https://res.cloudinary.com/ikupgdru/image/upload/v1784619368/06_d6z9zq_v5hkvn.png',
        isYou: true,
      ),
      LeaderboardEntry(
        rank: 9,
        name: 'Langris',
        points: 1200,
        avatarUrl:
            'https://res.cloudinary.com/ikupgdru/image/upload/v1784619368/07_q9u5e8_cplg8n.png',
      ),
      LeaderboardEntry(
        rank: 10,
        name: 'Marsha',
        points: 600,
        avatarUrl:
            'https://res.cloudinary.com/ikupgdru/image/upload/v1784619368/10_x2zysg_m5k2vn.png',
      ),
    ],
  ];

  @override
  Widget build(BuildContext context) {
    final currentPodium = podiumData[_selectedTab];
    final currentList = listData[_selectedTab];

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
                        width: 190,
                        height: 30,
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
                    // Podium
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Rank 2 (Left)
                        _buildPodiumCol(currentPodium[0]),
                        // Rank 1 (Center) - taller
                        _buildPodiumCol(currentPodium[1], isCenter: true),
                        // Rank 3 (Right)
                        _buildPodiumCol(currentPodium[2]),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Ranks List 4-10
                    Column(
                      children: currentList.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: entry.isYou
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
                                      fontFamily: AppTextStyles.titleFontFamily,
                                      fontSize: 16,
                                      color: entry.isYou
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
                                    entry.avatarUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Container(
                                              color: const Color(0xFFE5E5EA),
                                              child: const Icon(
                                                CupertinoIcons.person_fill,
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
                                    entry.isYou ? 'You' : entry.name,
                                    style: TextStyle(
                                      fontFamily: AppTextStyles.fontFamily,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: entry.isYou
                                          ? CupertinoColors.white
                                          : AppColors.primary,
                                    ),
                                  ),
                                ),
                                // Points
                                Text(
                                  '${entry.points} pts',
                                  style: TextStyle(
                                    fontFamily: AppTextStyles.fontFamily,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: entry.isYou
                                        ? CupertinoColors.white.withValues(
                                            alpha: 0.8,
                                          )
                                        : const Color(0xFF8E8E93),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
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

  Widget _buildPodiumCol(PodiumUser user, {bool isCenter = false}) {
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
        badgeColor = user.borderColor;
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
              borderColor: user.borderColor,
              borderWidth: 4.0,
              fillColor: CupertinoColors.transparent,
              child: Image.network(
                user.avatarUrl,
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
                  border: Border.all(color: user.borderColor, width: 3),
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
                          ..color = user.borderColor,
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
        Text(
          user.name,
          style: const TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        // Points
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SVG('illustrations/flower.svg', width: 12, height: 12),
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

class PodiumUser {
  final String name;
  final int points;
  final int rank;
  final String avatarUrl;
  final Color borderColor;

  const PodiumUser({
    required this.name,
    required this.points,
    required this.rank,
    required this.avatarUrl,
    required this.borderColor,
  });
}

class LeaderboardEntry {
  final int rank;
  final String name;
  final int points;
  final String avatarUrl;
  final bool isYou;

  const LeaderboardEntry({
    required this.rank,
    required this.name,
    required this.points,
    required this.avatarUrl,
    this.isYou = false,
  });
}
