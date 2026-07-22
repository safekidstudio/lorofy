import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lorofy/components/ui/app_avatar.dart';
import 'package:lorofy/components/ui/svg_asset.dart';
import 'package:lorofy/components/ui/toast.dart';
import 'package:lorofy/core/theme/app_theme.dart';

class ExplorePage extends ConsumerStatefulWidget {
  final double pageOffset;
  final double pageValue;
  final double screenHeight;
  final VoidCallback onBackTap;
  final VoidCallback onSettingsTap;

  const ExplorePage({
    super.key,
    required this.pageOffset,
    required this.pageValue,
    required this.screenHeight,
    required this.onBackTap,
    required this.onSettingsTap,
  });

  @override
  ConsumerState<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends ConsumerState<ExplorePage> {
  bool _isDayToggle = true;

  @override
  Widget build(BuildContext context) {
    final double opacity = ((widget.pageValue - 0.2) * 1.25).clamp(0.0, 1.0);
    final double contentOffset =
        (1.0 - widget.pageValue) * widget.screenHeight * 0.25;

    return Opacity(
      opacity: opacity,
      child: Transform.translate(
        offset: Offset(0, contentOffset),
        child: Stack(
          children: [
            // Scrollable content area
            Positioned.fill(
              child: NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification notification) {
                  return true; // Stop scroll notifications from bubbling to PageView
                },
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(
                    top: 60,
                  ), // Start content below fixed header
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // land.svg Decorator (scrolls with content)
                      const SVG(
                        'assets/illustrations/land.svg',
                        width: double.infinity,
                        height: 82, // Maximum height of land is 82px
                        fit: BoxFit.cover,
                      ),
                      Transform.translate(
                        offset: const Offset(
                          0,
                          -1,
                        ), // Overlap by 1px to prevent gaps
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 16,
                            right: 16,
                            bottom: 16,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Stats Cards Row (Today Focus / All Focus)
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 130,
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFF072013,
                                        ), // Dark green
                                        borderRadius: BorderRadius.circular(24),
                                        border: Border.all(
                                          color: const Color(0xFF232321),
                                          width: 2,
                                        ),
                                      ),
                                      padding: const EdgeInsets.all(16),
                                      child: const Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Today Focus',
                                            style: TextStyle(
                                              fontFamily:
                                                  AppTextStyles.fontFamily,
                                              color: Color(0xFF8E9B93),
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Center(
                                            child: Text(
                                              '8',
                                              style: TextStyle(
                                                fontFamily:
                                                    AppTextStyles.fontFamily,
                                                color: CupertinoColors.white,
                                                fontSize: 48,
                                                fontWeight: FontWeight.w900,
                                              ),
                                            ),
                                          ),
                                          Center(
                                            child: Text(
                                              '120 min',
                                              style: TextStyle(
                                                fontFamily:
                                                    AppTextStyles.fontFamily,
                                                color: Color(0xFF8E9B93),
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Container(
                                      height: 130,
                                      decoration: BoxDecoration(
                                        color: CupertinoColors.white,
                                        borderRadius: BorderRadius.circular(24),
                                        border: Border.all(
                                          color: const Color(0xFFE5E5EA),
                                          width: 1.5,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: CupertinoColors.systemGrey
                                                .withValues(alpha: 0.1),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      padding: const EdgeInsets.all(16),
                                      child: const Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'All Focus',
                                            style: TextStyle(
                                              fontFamily:
                                                  AppTextStyles.fontFamily,
                                              color: Color(0xFF8E8E93),
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Center(
                                            child: Text(
                                              '189',
                                              style: TextStyle(
                                                fontFamily:
                                                    AppTextStyles.fontFamily,
                                                color: Color(0xFF232321),
                                                fontSize: 48,
                                                fontWeight: FontWeight.w900,
                                              ),
                                            ),
                                          ),
                                          Center(
                                            child: Text(
                                              '800 hr 58 min',
                                              style: TextStyle(
                                                fontFamily:
                                                    AppTextStyles.fontFamily,
                                                color: Color(0xFF8E8E93),
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Kill Stats Container
                              Container(
                                decoration: BoxDecoration(
                                  color: CupertinoColors.white,
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: const Color(0xFFE5E5EA),
                                    width: 1.5,
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 16,
                                ),
                                child: Column(
                                  children: [
                                    const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Today Kill',
                                          style: TextStyle(
                                            fontFamily:
                                                AppTextStyles.fontFamily,
                                            color: Color(0xFF8E8E93),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          '8',
                                          style: TextStyle(
                                            fontFamily:
                                                AppTextStyles.fontFamily,
                                            color: Color(0xFF197645),
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      child: Container(
                                        height: 1,
                                        color: const Color(0xFFE5E5EA),
                                      ),
                                    ),
                                    const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'All Kill',
                                          style: TextStyle(
                                            fontFamily:
                                                AppTextStyles.fontFamily,
                                            color: Color(0xFF8E8E93),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          '12030',
                                          style: TextStyle(
                                            fontFamily:
                                                AppTextStyles.fontFamily,
                                            color: Color(0xFF197645),
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Average Stats Row
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 80,
                                      decoration: BoxDecoration(
                                        color: CupertinoColors.white,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: const Color(0xFFE5E5EA),
                                          width: 1.5,
                                        ),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Expanded(
                                            child: Text(
                                              'Average\nFocus time',
                                              style: TextStyle(
                                                fontFamily:
                                                    AppTextStyles.fontFamily,
                                                color: Color(0xFF8E8E93),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                height: 1.1,
                                              ),
                                            ),
                                          ),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              const Text(
                                                'min',
                                                style: TextStyle(
                                                  fontFamily:
                                                      AppTextStyles.fontFamily,
                                                  color: Color(0xFF8E8E93),
                                                  fontSize: 10,
                                                ),
                                              ),
                                              Text(
                                                '25',
                                                style: const TextStyle(
                                                  fontFamily:
                                                      AppTextStyles.fontFamily,
                                                  color: Color(0xFF232321),
                                                  fontSize: 28,
                                                  fontWeight: FontWeight.w900,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Container(
                                      height: 80,
                                      decoration: BoxDecoration(
                                        color: CupertinoColors.white,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: const Color(0xFFE5E5EA),
                                          width: 1.5,
                                        ),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Expanded(
                                            child: Text(
                                              'Average\nKill time',
                                              style: TextStyle(
                                                fontFamily:
                                                    AppTextStyles.fontFamily,
                                                color: Color(0xFF8E8E93),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                height: 1.1,
                                              ),
                                            ),
                                          ),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              const Text(
                                                'min',
                                                style: TextStyle(
                                                  fontFamily:
                                                      AppTextStyles.fontFamily,
                                                  color: Color(0xFF8E8E93),
                                                  fontSize: 10,
                                                ),
                                              ),
                                              Text(
                                                '2',
                                                style: const TextStyle(
                                                  fontFamily:
                                                      AppTextStyles.fontFamily,
                                                  color: Color(0xFF232321),
                                                  fontSize: 28,
                                                  fontWeight: FontWeight.w900,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),

                              // Leaderboard Section Header
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Leaderboard',
                                    style: TextStyle(
                                      fontFamily: AppTextStyles.titleFontFamily,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF232321),
                                    ),
                                  ),
                                  CupertinoButton(
                                    padding: EdgeInsets.zero,
                                    onPressed: () {
                                      AppToast.show(
                                        context,
                                        message:
                                            "Leaderboard details coming soon!",
                                      );
                                    },
                                    child: const Row(
                                      children: [
                                        Text(
                                          'View more ',
                                          style: TextStyle(
                                            fontFamily:
                                                AppTextStyles.fontFamily,
                                            color: Color(0xFF8E8E93),
                                            fontSize: 14,
                                          ),
                                        ),
                                        Icon(
                                          CupertinoIcons.chevron_right,
                                          color: Color(0xFF8E8E93),
                                          size: 14,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Leaderboard Podium
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  _buildPodiumUser(
                                    name: 'Graves',
                                    points: 90,
                                    rank: 2,
                                    avatarUrl:
                                        'https://res.cloudinary.com/ikupgdru/image/upload/v1784619368/08_tqar6z_nvbvsx.png',
                                    highlightColor: const Color(
                                      0xFFA6E0B5,
                                    ), // green
                                  ),
                                  _buildPodiumUser(
                                    name: 'James',
                                    points: 120,
                                    rank: 1,
                                    avatarUrl:
                                        'https://res.cloudinary.com/ikupgdru/image/upload/v1784619376/64_d4fo1k_wnebqr.png',
                                    highlightColor: const Color(
                                      0xFFFFD465,
                                    ), // gold
                                    isCenter: true,
                                  ),
                                  _buildPodiumUser(
                                    name: 'David',
                                    points: 75,
                                    rank: 3,
                                    avatarUrl:
                                        'https://res.cloudinary.com/ikupgdru/image/upload/v1784619368/02_aus2zc_tfpypg.png',
                                    highlightColor: const Color(
                                      0xFFFFAC7F,
                                    ), // orange
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),

                              // Recent Focus Section Header
                              const Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Recent Focus',
                                    style: TextStyle(
                                      fontFamily: AppTextStyles.titleFontFamily,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF232321),
                                    ),
                                  ),
                                  Text(
                                    'Daily Average 12',
                                    style: TextStyle(
                                      fontFamily: AppTextStyles.fontFamily,
                                      color: Color(0xFF8E8E93),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _buildRecentFocusChart(),
                              const SizedBox(height: 24),

                              // Focus Record Section Header
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Focus Record',
                                    style: TextStyle(
                                      fontFamily: AppTextStyles.titleFontFamily,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF232321),
                                    ),
                                  ),
                                  _buildRecordToggle(),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _buildFocusRecordList(),
                              const SizedBox(height: 32),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Fixed Header Bar sitting on top of the scrollable content
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 60,
              child: Container(
                color: AppColors.background,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: widget.onBackTap,
                      child: const Icon(
                        CupertinoIcons.xmark,
                        color: Color(0xFF232321),
                        size: 24,
                      ),
                    ),
                    const Text(
                      'Explore',
                      style: TextStyle(
                        fontFamily: AppTextStyles.titleFontFamily,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF232321),
                        letterSpacing: -0.5,
                      ),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: widget.onSettingsTap,
                      child: const AppAvatar(path: null, size: 32),
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

  Widget _buildPodiumUser({
    required String name,
    required int points,
    required int rank,
    required String avatarUrl,
    required Color highlightColor,
    bool isCenter = false,
  }) {
    final avatarSize = isCenter ? 80.0 : 64.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: avatarSize + 10,
              height: avatarSize + 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: highlightColor, width: 4),
              ),
              child: ClipOval(
                child: Image.network(
                  avatarUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: const Color(0xFFE5E5EA),
                      child: Icon(
                        CupertinoIcons.person_fill,
                        size: avatarSize * 0.5,
                        color: const Color(0xFF8E8E93),
                      ),
                    );
                  },
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: highlightColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: CupertinoColors.white, width: 2),
                ),
                alignment: Alignment.center,
                child: Text(
                  rank.toString(),
                  style: const TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    color: Color(0xFF232321),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: isCenter ? 16 : 14,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF232321),
          ),
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🌷 ', style: TextStyle(fontSize: 12)),
            Text(
              '$points pts',
              style: const TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 12,
                color: Color(0xFF8E8E93),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentFocusChart() {
    final List<Map<String, dynamic>> chartData = [
      {'day': '10.6', 'value': 22.0, 'active': true},
      {'day': '10.7', 'value': 10.0, 'active': true},
      {'day': '10.8', 'value': 3.0, 'active': false},
      {'day': '10.9', 'value': 14.0, 'active': true},
      {'day': '10.10', 'value': 3.0, 'active': false},
      {'day': '10.11', 'value': 10.0, 'active': true},
      {'day': '10.12', 'value': 18.0, 'active': true, 'tooltip': '20'},
    ];

    return Container(
      height: 170,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E5EA), width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: chartData.map((data) {
          final double barHeight = data['value'] * 4.5;
          final bool isActive = data['active'] as bool;
          final bool hasTooltip = data.containsKey('tooltip');

          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (hasTooltip) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF232321),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    data['tooltip'].toString(),
                    style: const TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      color: CupertinoColors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
              ],
              Container(
                width: 24,
                height: barHeight,
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFF072013)
                      : const Color(0xFFE5E5EA),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                data['day'].toString(),
                style: const TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  color: Color(0xFF8E8E93),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRecordToggle() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F7),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => setState(() => _isDayToggle = true),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _isDayToggle
                    ? const Color(0xFF232321)
                    : CupertinoColors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Day',
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: _isDayToggle
                      ? CupertinoColors.white
                      : const Color(0xFF8E8E93),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _isDayToggle = false),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: !_isDayToggle
                    ? const Color(0xFF232321)
                    : CupertinoColors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Month',
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: !_isDayToggle
                      ? CupertinoColors.white
                      : const Color(0xFF8E8E93),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFocusRecordList() {
    final List<Map<String, dynamic>> records = [
      {'time': '06:30 PM', 'flowers': 6, 'duration': '60 mins'},
      {'time': '05:00 PM', 'flowers': 3, 'duration': '30 mins'},
      {'time': '04:30 PM', 'flowers': 3, 'duration': '25 mins'},
      {'time': '02:30 PM', 'flowers': 2, 'duration': '15 mins'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E5EA), width: 1.5),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: records.asMap().entries.map((entry) {
          final index = entry.key;
          final record = entry.value;
          final int flowerCount = record['flowers'] as int;

          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    record['time'].toString(),
                    style: const TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      color: Color(0xFF232321),
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: List.generate(
                      flowerCount,
                      (i) => const Text('🌷 ', style: TextStyle(fontSize: 14)),
                    ),
                  ),
                  Text(
                    record['duration'].toString(),
                    style: const TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      color: Color(0xFF8E8E93),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              if (index < records.length - 1)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Container(height: 1, color: const Color(0xFFE5E5EA)),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
