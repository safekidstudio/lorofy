import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lorofy/core/theme/app_theme.dart';
import 'package:lorofy/features/focus/presentation/providers/pomodoro_settings.dart';

class BlockedCategoriesSection extends ConsumerWidget {
  const BlockedCategoriesSection({super.key});

  Widget _buildCheckboxRow({
    required String title,
    required bool isChecked,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: isChecked ? const Color(0xFF071B12) : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isChecked ? const Color(0xFF071B12) : const Color(0xFFD1D1D6),
                  width: 2,
                ),
              ),
              child: isChecked
                  ? const Icon(
                      CupertinoIcons.checkmark,
                      size: 14,
                      color: CupertinoColors.white,
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: isChecked
                      ? const Color(0xFF232321)
                      : const Color(0xFF8E8E93),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(pomodoroSettingsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Blocked Categories:',
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF232321),
          ),
        ),
        const SizedBox(height: 12),
        ...[
          'Social Media (Facebook, Tiktok, Instagram,...)',
          'Game (Auto-detect game apps)',
          'Entertainment (YouTube, Netflix...)',
          'Shopping & News (Shopee, Newspaper...)',
        ].map((categoryLabel) {
          final isChecked = settings.blockedCategories.contains(categoryLabel);
          return _buildCheckboxRow(
            title: categoryLabel,
            isChecked: isChecked,
            onTap: () {
              final currentSet = Set<String>.from(settings.blockedCategories);
              if (isChecked) {
                currentSet.remove(categoryLabel);
              } else {
                currentSet.add(categoryLabel);
              }
              ref.read(pomodoroSettingsProvider.notifier).updateSettings(
                    settings.copyWith(blockedCategories: currentSet),
                  );
            },
          );
        }),
      ],
    );
  }
}
