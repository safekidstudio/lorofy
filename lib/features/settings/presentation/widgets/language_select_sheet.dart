import 'package:flutter/cupertino.dart';
import 'package:lorofy/components/ui/svg_asset.dart';
import 'package:lorofy/core/localization/l10n_extension.dart';
import 'package:lorofy/core/theme/app_theme.dart';
import 'package:lorofy/l10n/generated/app_localizations.dart';

class LanguageSelectSheet extends StatelessWidget {
  final Locale? currentLocale;
  final ValueChanged<Locale?> onSelect;

  const LanguageSelectSheet({
    super.key,
    required this.currentLocale,
    required this.onSelect,
  });

  Widget _buildOption(
    BuildContext context, {
    required String label,
    required Locale? locale,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        onSelect(locale);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : CupertinoColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? CupertinoColors.white : AppColors.foreground,
              ),
            ),
            if (isSelected)
              const SVG(
                'assets/icons/check.svg',
                width: 16,
                height: 16,
                color: CupertinoColors.white,
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    // Keep switching logic, currently showing English ('en') option only
    final options = <({Locale? locale, String label})>[
      // (locale: null, label: l10n.settings_languageSystem),
      ...AppLocalizations.supportedLocales
          .where((locale) => locale.languageCode == 'en')
          .map((locale) {
        final label = locale.languageCode == 'vi'
            ? l10n.settings_languageVietnamese
            : l10n.settings_languageEnglish;
        return (locale: locale, label: label);
      }),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Pull bar / Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Title
            Text(
              l10n.settings_language,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: AppTextStyles.titleFontFamily,
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: AppColors.foreground,
                letterSpacing: -0.5,
                decoration: TextDecoration.none,
              ),
            ),
            const SizedBox(height: 24),
            ...options.map((opt) {
              final isSelected = (opt.locale?.languageCode == currentLocale?.languageCode) ||
                  (opt.locale == null && currentLocale == null);
              return _buildOption(
                context,
                label: opt.label,
                locale: opt.locale,
                isSelected: isSelected,
              );
            }),
          ],
        ),
      ),
    );
  }
}
