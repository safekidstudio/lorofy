import 'package:flutter/cupertino.dart';

class AppColors {
  // Canvas & Main Text (shadcn tokens)
  static const CupertinoDynamicColor background =
      CupertinoDynamicColor.withBrightness(
        color: Color(0xFFF6F6F6),
        darkColor: Color(0xFF1C1C1E),
      );

  static const CupertinoDynamicColor foreground =
      CupertinoDynamicColor.withBrightness(
        color: Color(0xFF232321),
        darkColor: Color(0xFFF2F2F7),
      );

  // Cards & Panels
  static const CupertinoDynamicColor card =
      CupertinoDynamicColor.withBrightness(
        color: CupertinoColors.white,
        darkColor: Color(0xFF1C1C1E),
      );

  static const CupertinoDynamicColor cardForeground =
      CupertinoDynamicColor.withBrightness(
        color: Color(0xFF232321),
        darkColor: Color(0xFFF2F2F7),
      );

  // Primary Action & Brand
  static const CupertinoDynamicColor primary =
      CupertinoDynamicColor.withBrightness(
        color: Color(0xFF071B12),
        darkColor: Color(0xFFF2F2F7),
      );

  static const Color primaryForeground = CupertinoColors.white;

  // Secondary Container & Elements
  static const CupertinoDynamicColor secondary =
      CupertinoDynamicColor.withBrightness(
        color: Color(0xFFE4E4E6),
        darkColor: Color(0xFF2C2C2E),
      );

  static const CupertinoDynamicColor secondaryForeground =
      CupertinoDynamicColor.withBrightness(
        color: Color(0xFF232321),
        darkColor: Color(0xFFF2F2F7),
      );

  // Muted Background & Subtle Text
  static const CupertinoDynamicColor muted =
      CupertinoDynamicColor.withBrightness(
        color: Color(0xFFF2F4F7),
        darkColor: Color(0xFF2C2C2E),
      );

  static const CupertinoDynamicColor mutedForeground =
      CupertinoDynamicColor.withBrightness(
        color: Color(0xFF8E8E93),
        darkColor: Color(0xFF8E8E93),
      );

  // Borders & Inputs
  static const CupertinoDynamicColor border =
      CupertinoDynamicColor.withBrightness(
        color: Color(0xFFECECED),
        darkColor: Color(0xFF3A3A3C),
      );

  static const CupertinoDynamicColor input =
      CupertinoDynamicColor.withBrightness(
        color: Color(0xFFE2E2E2),
        darkColor: Color(0xFF2C2C2E),
      );

  // Actions & Destructive
  static const Color destructive = CupertinoColors.destructiveRed;
}

class AppRadius {
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 28.0;
  static const double xl = 36.0;
}

class AppPadding {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0; // standard 12px padding for the app
  static const double lg = 16.0;
  static const double xl = 24.0;

  static const EdgeInsets allXs = EdgeInsets.all(xs);
  static const EdgeInsets allSm = EdgeInsets.all(sm);
  static const EdgeInsets allMd = EdgeInsets.all(md);
  static const EdgeInsets allLg = EdgeInsets.all(lg);
  static const EdgeInsets allXl = EdgeInsets.all(xl);

  static const EdgeInsets horizontalXs = EdgeInsets.symmetric(horizontal: xs);
  static const EdgeInsets horizontalSm = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets horizontalMd = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets horizontalLg = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets horizontalXl = EdgeInsets.symmetric(horizontal: xl);

  static const EdgeInsets verticalXs = EdgeInsets.symmetric(vertical: xs);
  static const EdgeInsets verticalSm = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets verticalMd = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets verticalLg = EdgeInsets.symmetric(vertical: lg);
  static const EdgeInsets verticalXl = EdgeInsets.symmetric(vertical: xl);
}

class AppTextStyles {
  // Font Family definitions
  static const String fontFamily = 'Fredoka';
  static const String titleFontFamily = 'NerkoOne';

  // 1. Title Large
  static const TextStyle titleLarge = TextStyle(
    fontFamily: titleFontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.foreground,
    letterSpacing: -0.5,
    height: 1.25,
  );

  // Title Medium
  static const TextStyle titleMedium = TextStyle(
    fontFamily: titleFontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.foreground,
    letterSpacing: -0.3,
  );

  // 2. Input Label
  static const TextStyle label = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.foreground,
    letterSpacing: -0.1,
  );

  // 3. Body Text
  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.foreground,
    height: 1.35,
  );

  // Placeholder
  static const TextStyle placeholder = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.mutedForeground,
  );

  // 4. Caption / Disclaimer
  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.mutedForeground,
    height: 1.3,
  );

  // Link
  static const TextStyle link = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.foreground,
    decoration: TextDecoration.underline,
  );

  // 5. Button Text
  static const TextStyle buttonText = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
  );
}
