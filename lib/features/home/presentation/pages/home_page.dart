import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lorofy/components/ui/button.dart';
import 'package:lorofy/components/ui/svg_asset.dart';
import 'package:lorofy/components/ui/drawing_container.dart';
import 'package:lorofy/components/ui/app_avatar.dart';
import 'package:lorofy/components/ui/toast.dart';
import 'package:lorofy/features/auth/presentation/providers/auth_provider.dart';
import 'package:lorofy/core/theme/app_theme.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with SingleTickerProviderStateMixin {
  late final PageController _pageController;
  late final AnimationController _bounceController;
  late final Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageController.addListener(() {
      setState(() {});
    });

    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _bounceAnimation = Tween<double>(begin: 0.0, end: 8.0).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

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
                    const AppAvatar(
                      path: null,
                      size: 64,
                    ),
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
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
              ),
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

  void _startFocusSession() {
    AppToast.show(
      context,
      message: 'Focus session started! Time to grow your plant! 🌿',
      type: ToastType.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    final double pageOffset = _pageController.hasClients ? _pageController.offset : 0;
    final double pageValue = _pageController.hasClients ? _pageController.page ?? 0 : 0;
    final double screenHeight = MediaQuery.of(context).size.height;

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.white,
      child: SafeArea(
        child: Stack(
          children: [
            // Vertical PageView for dual-pane Home and Explore
            PageView(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              physics: const BouncingScrollPhysics(),
              children: [
                _buildQuickStartPage(pageOffset, pageValue),
                _buildExplorePage(pageOffset, pageValue, screenHeight),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- Pane 1: Quick Start Screen ---
  Widget _buildQuickStartPage(double pageOffset, double pageValue) {
    // Opacity fades out as we swipe up
    final double opacity = (1.0 - pageValue * 2.5).clamp(0.0, 1.0);

    return Opacity(
      opacity: opacity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Custom Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'lorofy.',
                  style: TextStyle(
                    fontFamily: AppTextStyles.titleFontFamily,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF232321),
                    letterSpacing: -0.5,
                  ),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: _showSettings,
                  child: const SVG(
                    'assets/icons/settings_drawing.svg',
                    width: 32,
                    height: 32,
                  ),
                ),
              ],
            ),
            const Spacer(),
            // Potted Plant (Parallax translate)
            Transform.translate(
              offset: Offset(0, -pageOffset * 0.35),
              child: Center(
                child: Column(
                  children: [
                    const SVG(
                      'assets/illustrations/plant.svg',
                      width: 200,
                      height: 200,
                    ),
                    const SizedBox(height: 48),
                    // Start Button (Blob hand-drawn style via primary variant)
                    SizedBox(
                      width: 180,
                      child: Button.primary(
                        text: 'Start',
                        onPressed: _startFocusSession,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            // Bottom "swipe to explore" nudge
            Transform.translate(
              offset: Offset(0, -pageOffset * 0.15),
              child: Column(
                children: [
                  AnimatedBuilder(
                    animation: _bounceController,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _bounceAnimation.value),
                        child: child,
                      );
                    },
                    child: const Icon(
                      CupertinoIcons.chevron_compact_up,
                      color: Color(0xFF8E8E93),
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'swipe to explore',
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF8E8E93),
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

  // --- Pane 2: Explore Screen ---
  Widget _buildExplorePage(double pageOffset, double pageValue, double screenHeight) {
    // Opacity fades in as we swipe up
    final double opacity = ((pageValue - 0.2) * 1.25).clamp(0.0, 1.0);
    // Parallax slides up content slightly faster than standard swipe rate
    final double contentOffset = (1.0 - pageValue) * screenHeight * 0.25;

    return Opacity(
      opacity: opacity,
      child: Transform.translate(
        offset: Offset(0, contentOffset),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Explore',
                    style: TextStyle(
                      fontFamily: AppTextStyles.titleFontFamily,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF232321),
                      letterSpacing: -0.5,
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      _pageController.animateToPage(
                        0,
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeOutCubic,
                      );
                    },
                    child: const Icon(
                      CupertinoIcons.chevron_compact_down,
                      color: Color(0xFF232321),
                      size: 28,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Search Bar
              const DrawingContainer(
                height: 52,
                fillColor: Color(0xFFFAFAFA),
                borderColor: Color(0xFF232321),
                borderWidth: 2.0,
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Icon(CupertinoIcons.search, color: Color(0xFF232321), size: 20),
                    SizedBox(width: 12),
                    Text(
                      'Search focus rooms...',
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        color: Color(0xFF8E8E93),
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Grid of Focus Rooms
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    const Text(
                      'Popular Environments',
                      style: TextStyle(
                        fontFamily: AppTextStyles.titleFontFamily,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF232321),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: FocusRoomCard(
                            title: 'Forest Sanctuary',
                            duration: '25 min',
                            icon: '🌲',
                            bgColor: const Color(0xFFEAF7F0),
                            textColor: const Color(0xFF197645),
                            onTap: () => _startRoom('Forest Sanctuary'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: FocusRoomCard(
                            title: 'Deep Ocean',
                            duration: '45 min',
                            icon: '🌊',
                            bgColor: const Color(0xFFEAF2F9),
                            textColor: const Color(0xFF1E64A7),
                            onTap: () => _startRoom('Deep Ocean'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: FocusRoomCard(
                            title: 'Cozy Café',
                            duration: '15 min',
                            icon: '☕',
                            bgColor: const Color(0xFFFDF4EA),
                            textColor: const Color(0xFFC66F17),
                            onTap: () => _startRoom('Cozy Café'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: FocusRoomCard(
                            title: 'Old Library',
                            duration: '50 min',
                            icon: '📚',
                            bgColor: const Color(0xFFF4EAF9),
                            textColor: const Color(0xFF7E3DA7),
                            onTap: () => _startRoom('Old Library'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Weekly Stats Card
                    const Text(
                      'Your Progress',
                      style: TextStyle(
                        fontFamily: AppTextStyles.titleFontFamily,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF232321),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DrawingContainer(
                      fillColor: const Color(0xFFFDF9EA),
                      borderColor: const Color(0xFF232321),
                      borderWidth: 2.5,
                      padding: const EdgeInsets.all(16),
                      child: const Row(
                        children: [
                          Text(
                            '📊',
                            style: TextStyle(fontSize: 32),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Weekly Focus Journey',
                                  style: TextStyle(
                                    fontFamily: AppTextStyles.titleFontFamily,
                                    fontSize: 18,
                                    color: Color(0xFF232321),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'You focused for 4.5 hours this week. Keep growing!',
                                  style: TextStyle(
                                    fontFamily: AppTextStyles.fontFamily,
                                    fontSize: 13,
                                    color: Color(0xFF636366),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startRoom(String roomName) {
    AppToast.show(
      context,
      message: 'Entering $roomName focus room... 🤫',
      type: ToastType.success,
    );
  }
}

// --- Helper FocusRoomCard Widget ---
class FocusRoomCard extends StatelessWidget {
  final String title;
  final String duration;
  final String icon;
  final Color bgColor;
  final Color textColor;
  final VoidCallback onTap;

  const FocusRoomCard({
    super.key,
    required this.title,
    required this.duration,
    required this.icon,
    required this.bgColor,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: DrawingContainer(
        height: 124,
        fillColor: bgColor,
        borderColor: const Color(0xFF232321),
        borderWidth: 2.5,
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  icon,
                  style: const TextStyle(fontSize: 28),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF232321),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    duration,
                    style: const TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      color: CupertinoColors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            Text(
              title,
              style: TextStyle(
                fontFamily: AppTextStyles.titleFontFamily,
                fontSize: 18,
                color: textColor,
                fontWeight: FontWeight.w900,
                height: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
