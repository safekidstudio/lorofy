import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lorofy/core/theme/app_theme.dart';
import 'package:lorofy/features/focus/domain/enums/block_mode.dart';
import 'package:lorofy/features/focus/presentation/providers/pomodoro_settings.dart';
import 'blocked_categories_section.dart';

class AdvancedModeSection extends ConsumerStatefulWidget {
  const AdvancedModeSection({super.key});

  @override
  ConsumerState<AdvancedModeSection> createState() => _AdvancedModeSectionState();
}

class _AdvancedModeSectionState extends ConsumerState<AdvancedModeSection> {
  bool _isBlockedCategoriesExpanded = true;

  Widget _buildAdvancedModeCard({
    required String title,
    required String badgeText,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF071B12) : CupertinoColors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? CupertinoColors.white : const Color(0xFF232321),
                      ),
                    ),
                  ),
                  if (isSelected)
                    const Icon(
                      CupertinoIcons.checkmark,
                      size: 16,
                      color: CupertinoColors.white,
                    ),
                ],
              ),
            ),
            Positioned(
              top: -8,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C2C24),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFF6F6F6), width: 1.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      badgeText,
                      style: const TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: CupertinoColors.white,
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(
                      CupertinoIcons.shield_fill,
                      color: Color(0xFFE25C5C),
                      size: 10,
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

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(pomodoroSettingsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Advanced mode',
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF232321),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildAdvancedModeCard(
              title: 'Medium',
              badgeText: 'x1.2',
              isSelected: settings.blockMode == BlockMode.MEDIUM,
              onTap: () {
                ref.read(pomodoroSettingsProvider.notifier).updateSettings(
                      settings.copyWith(blockMode: BlockMode.MEDIUM),
                    );
              },
            ),
            const SizedBox(width: 16),
            _buildAdvancedModeCard(
              title: 'Strict',
              badgeText: 'x1.5',
              isSelected: settings.blockMode == BlockMode.STRICT,
              onTap: () {
                ref.read(pomodoroSettingsProvider.notifier).updateSettings(
                      settings.copyWith(blockMode: BlockMode.STRICT),
                    );
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              CupertinoIcons.info_circle,
              size: 14,
              color: Color(0xFF8E8E93),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Block distraction apps, allow work/study apps.',
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 13,
                  color: const Color(0xFF8E8E93),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Chevron collapse / expand arrow
        GestureDetector(
          onTap: () => setState(() =>
              _isBlockedCategoriesExpanded = !_isBlockedCategoriesExpanded),
          child: Align(
            alignment: Alignment.center,
            child: Icon(
              _isBlockedCategoriesExpanded
                  ? CupertinoIcons.chevron_up
                  : CupertinoIcons.chevron_down,
              color: const Color(0xFF8E8E93),
              size: 20,
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Expandable Blocked Categories Checklist
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: !_isBlockedCategoriesExpanded
              ? const SizedBox.shrink()
              : const BlockedCategoriesSection(),
        ),
      ],
    );
  }
}
