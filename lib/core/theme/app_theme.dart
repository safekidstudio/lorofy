import 'package:flutter/cupertino.dart';

class AppColors {
  // Background Color
  static const CupertinoDynamicColor background =
      CupertinoDynamicColor.withBrightness(
        color: Color(0xFFF6F6F6),
        darkColor: Color(0xFFF6F6F6),
      );

  // Card Color
  static const CupertinoDynamicColor card =
      CupertinoDynamicColor.withBrightness(
        color: CupertinoColors.white,
        darkColor: Color(0xff1c1c1e),
      );

  // Primary Color
  static const CupertinoDynamicColor primary =
      CupertinoDynamicColor.withBrightness(
        color: Color(0xff111111),
        darkColor: Color(0xfff2f2f7),
      );

  // Secondary Color
  static const CupertinoDynamicColor secondary =
      CupertinoDynamicColor.withBrightness(
        color: Color(0xff8e8e93),
        darkColor: Color(0xff8e8e93),
      );

  // Border Color
  static const CupertinoDynamicColor border =
      CupertinoDynamicColor.withBrightness(
        color: Color(0xffe5e5ea),
        darkColor: Color(0xff3a3a3c),
      );

  // Input Background Color
  static const CupertinoDynamicColor inputBg =
      CupertinoDynamicColor.withBrightness(
        color: Color(0xfffafafa),
        darkColor: Color(0xff2c2c2e),
      );

  // Destructive Color
  static const Color destructive = CupertinoColors.destructiveRed;
}

class AppRadius {
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 28.0;
  static const double xl = 36.0;
}

class AppTextStyles {
  // Định nghĩa Font Family trùng tên với khai báo trong pubspec.yaml
  static const String fontFamily = 'Fredoka';
  static const String titleFontFamily = 'NerkoOne';

  // 1. Tiêu đề lớn màn hình (Welcome back, Create your own account)
  static const TextStyle titleLarge = TextStyle(
    fontFamily: titleFontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
    letterSpacing: -0.5,
    height: 1.25,
  );

  // Tiêu đề phụ
  static const TextStyle titleMedium = TextStyle(
    fontFamily: titleFontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
    letterSpacing: -0.3,
  );

  // 2. Nhãn (Label) phía trên ô nhập liệu
  static const TextStyle label = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
    letterSpacing: -0.1,
  );

  // 3. Văn bản chính (Chữ gõ vào ô nhập)
  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.primary,
    height: 1.35,
  );

  // Chữ gợi ý (Placeholder)
  static const TextStyle placeholder = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.secondary,
  );

  // 4. Chú thích nhỏ (Terms / Disclaimer)
  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.secondary,
    height: 1.3,
  );

  // Link gạch chân
  static const TextStyle link = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
    decoration: TextDecoration.underline,
  );

  // 5. Chữ hiển thị trên Nút bấm chính
  static const TextStyle buttonText = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
  );
}
