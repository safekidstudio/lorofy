import 'package:flutter/cupertino.dart';
import 'package:lorofy/core/theme/app_theme.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      // 1. Set background sang màu Primary
      backgroundColor: AppColors.primary,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(), // Đẩy phần trung tâm xuống giữa màn hình
            // 2. Logo & Tên ở chính giữa
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/logos/lorofy.png',
                  width: 96,
                  height: 96,
                  errorBuilder: (_, __, ___) => const Icon(
                    CupertinoIcons.circle_grid_hex,
                    color: CupertinoColors.white,
                    size: 96,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'lorofy',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: CupertinoColors.white,
                    letterSpacing: -1.5,
                  ),
                ),
              ],
            ),

            const Spacer(), // Đẩy phần loading xuống góc dưới một chút cho cân bằng
            // 3. Loader màu trắng nổi bật
            const CupertinoActivityIndicator(
              color: CupertinoColors.white,
              radius: 12, // Tăng kích thước spinner lên một chút cho dễ nhìn
            ),
            const SizedBox(
              height: 60,
            ), // Khoảng cách an toàn với cạnh dưới màn hình
          ],
        ),
      ),
    );
  }
}
