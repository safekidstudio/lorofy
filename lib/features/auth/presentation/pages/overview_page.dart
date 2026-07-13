import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:lorofy/components/ui/button.dart';
import 'package:lorofy/components/ui/carousel.dart';
import 'package:lorofy/core/theme/app_theme.dart';

class OverviewPage extends StatefulWidget {
  const OverviewPage({super.key});

  @override
  State<OverviewPage> createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _slidesData = [
    {'image': 'assets/images/auth_bg_1.png'},
    {'image': 'assets/images/auth_bg_2.png'},
    {'image': 'assets/images/auth_bg_3.png'},
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      child: Stack(
        children: [
          // 1. Carousel động
          Positioned.fill(
            child: Carousel(
              controller: _pageController,
              physics: const ClampingScrollPhysics(),
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              children: _slidesData.map((slide) {
                return Image.asset(
                  slide['image']!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      Container(color: CupertinoColors.black),
                );
              }).toList(),
            ),
          ),

          // 2. Indicator nằm nổi trên ảnh nền
          Positioned(
            bottom: 280, // Nằm ngay trên mép Card
            left: 0,
            right: 0,
            child: CarouselIndicator(
              count: _slidesData.length,
              currentIndex: _currentPage,
            ),
          ),

          // 3. Bottom Sheet ôm sát đáy chuẩn di động
          Positioned(
            left: 4,
            right: 4,
            bottom: 4,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
              decoration: const BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppRadius.lg), // Chỉ bo hai góc trên
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Button.primary(
                    text: 'Log in',
                    onPressed: () => context.push('/login'),
                  ),
                  const SizedBox(height: 12),
                  Button.outline(
                    text: 'Sign up',
                    onPressed: () => context.push('/register'),
                  ),
                  const SizedBox(height: 28),

                  // Điều khoản dịch vụ & Chính sách
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text.rich(
                      TextSpan(
                        text: 'By continuing, you agree to Lorofy\'s ',
                        style: AppTextStyles.body.copyWith(
                          fontSize: 14,
                          color: AppColors.secondary,
                        ),
                        children: [
                          TextSpan(
                            text: 'Privacy Policy',
                            style: AppTextStyles.body.copyWith(
                              fontSize: 14,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          const TextSpan(text: ' and '),
                          TextSpan(
                            text: 'Terms of Use',
                            style: AppTextStyles.body.copyWith(
                              fontSize: 14,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
