import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lorofy/components/ui/app_checkbox.dart';
import 'package:lorofy/core/theme/app_theme.dart';
import 'package:lorofy/features/focus/presentation/providers/pomodoro_settings.dart';

class BlockedCategoriesSection extends ConsumerWidget {
  const BlockedCategoriesSection({super.key});

  Widget _buildCheckboxRow({
    required String title,
    required bool isChecked,
    required ValueChanged<bool> onChanged,
  }) {
    return GestureDetector(
      onTap: () => onChanged(!isChecked),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            IgnorePointer(
              child: AppCheckbox(
                value: isChecked,
                onChanged: onChanged,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 14,
                  color: isChecked ? AppColors.primary : AppColors.secondary,
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
            fontWeight: FontWeight.w500,
            color: AppColors.primary,
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
            onChanged: (val) {
              final currentSet = Set<String>.from(settings.blockedCategories);
              if (isChecked) {
                currentSet.remove(categoryLabel);
              } else {
                currentSet.add(categoryLabel);
              }
              ref
                  .read(pomodoroSettingsProvider.notifier)
                  .updateSettings(
                    settings.copyWith(blockedCategories: currentSet),
                  );
            },
          );
        }),
      ],
    );
  }
}
