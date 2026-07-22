import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lorofy/components/ui/app_avatar.dart';
import 'package:lorofy/components/ui/toast.dart';
import 'package:lorofy/features/auth/presentation/providers/auth_provider.dart';
import 'package:lorofy/core/theme/app_theme.dart';
import 'package:lorofy/features/home/presentation/pages/quick_start_page.dart';
import 'package:lorofy/features/home/presentation/pages/explore_page.dart';

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
  bool _isFocusLocked = false;

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
    final double pageOffset = _pageController.hasClients
        ? _pageController.offset
        : 0;
    final double pageValue = _pageController.hasClients
        ? _pageController.page ?? 0
        : 0;
    final double screenHeight = MediaQuery.of(context).size.height;

    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      child: SafeArea(
        child: Stack(
          children: [
            PageView(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              physics: _isFocusLocked
                  ? const NeverScrollableScrollPhysics()
                  : const BouncingScrollPhysics(),
              children: [
                QuickStartPage(
                  pageOffset: pageOffset,
                  pageValue: pageValue,
                  onSettingsPressed: _showSettings,
                  onFocusStateChanged: (isLocked) {
                    setState(() {
                      _isFocusLocked = isLocked;
                    });
                  },
                ),
                ExplorePage(
                  pageOffset: pageOffset,
                  pageValue: pageValue,
                  screenHeight: screenHeight,
                  onBackTap: () {
                    _pageController.animateToPage(
                      0,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOutCubic,
                    );
                  },
                  onSettingsTap: _showSettings,
                ),
              ],
            ),
            // Bottom "swipe to explore" nudge (hidden when focused/locked)
            if (pageValue < 0.05 && !_isFocusLocked)
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
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
}
