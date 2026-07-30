import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smooth_sheets/smooth_sheets.dart';
import 'package:lorofy/components/ui/shimmer.dart';
import 'package:lorofy/core/theme/app_theme.dart';
import 'package:lorofy/features/focus/presentation/providers/pomodoro_settings.dart';
import 'package:lorofy/features/focus/presentation/providers/categories_provider.dart';
import 'package:lorofy/features/focus/presentation/widgets/create_category_sheet.dart';

class SettingsPomodoroTab extends ConsumerWidget {
  const SettingsPomodoroTab({super.key});

  Widget _buildModeSelector({
    required bool isDeep,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFE5E5EA).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOutCubic,
            alignment: isDeep ? Alignment.centerRight : Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              child: Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFF232321),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onChanged(false),
                  child: Center(
                    child: Text(
                      'Pomodoro',
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: !isDeep
                            ? CupertinoColors.white
                            : const Color(0xFF8E8E93),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onChanged(true),
                  child: Center(
                    child: Text(
                      'Deep Focus',
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDeep
                            ? CupertinoColors.white
                            : const Color(0xFF8E8E93),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSelectableRow<T>({
    required List<T> options,
    required T selectedValue,
    required String Function(T) getLabel,
    required ValueChanged<T> onChanged,
  }) {
    return Row(
      children: options.map((option) {
        final isSelected = option == selectedValue;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(option),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 40,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF232321)
                    : CupertinoColors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  getLabel(option),
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isSelected
                        ? CupertinoColors.white
                        : const Color(0xFF232321),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(pomodoroSettingsProvider);
    final categoriesAsync = ref.watch(focusCategoriesProvider);

    final List<int> shortBreakOptions = [3, 5, 10, 15, 20];
    final List<int> targetRoundsOptions = [2, 3, 4, 6, 8];

    final isDeep = settings.isDeepFocusMode;

    // Ensure the currently stored break minutes match one of our options or default it to nearest
    int displayBreakMinutes = settings.breakMinutes;
    if (!isDeep && !shortBreakOptions.contains(displayBreakMinutes)) {
      displayBreakMinutes = 5; // Default fallback
    }

    // Ensure the currently stored target rounds match one of our options or default it to nearest
    int displayTargetRounds = settings.targetRounds;
    if (!isDeep && !targetRoundsOptions.contains(displayTargetRounds)) {
      displayTargetRounds = 4; // Default fallback
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: AppPadding.allMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 0. Mode Selector (Pomodoro vs Deep Focus)
          _buildModeSelector(
            isDeep: isDeep,
            onChanged: (val) {
              ref
                  .read(pomodoroSettingsProvider.notifier)
                  .updateSettings(settings.copyWith(isDeepFocusMode: val));
            },
          ),
          const SizedBox(height: 20),

          // 1. Focus duration slider
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Focus duration : ${settings.focusMinutes}m',
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 32,
                child: SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 2,
                    activeTrackColor: const Color(0xFF232321),
                    inactiveTrackColor: const Color(0xFFE5E5EA),
                    thumbColor: const Color(0xFF232321),
                    overlayColor: const Color(
                      0xFF232321,
                    ).withValues(alpha: 0.1),
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 8,
                    ),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 16,
                    ),
                  ),
                  child: Slider(
                    value: settings.focusMinutes.toDouble().clamp(5.0, isDeep ? 180.0 : 90.0),
                    min: 5.0,
                    max: isDeep ? 180.0 : 90.0,
                    onChanged: (val) {
                      ref
                          .read(pomodoroSettingsProvider.notifier)
                          .updateSettings(
                            settings.copyWith(focusMinutes: val.round()),
                          );
                    },
                  ),
                ),
              ),
            ],
          ),

          // 2. Short Break & Rounds (Segmented selector layout - hidden in Deep Focus)
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: isDeep
                ? const SizedBox.shrink()
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20),
                      // Short break label & selector
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Short break',
                            style: TextStyle(
                              fontFamily: AppTextStyles.fontFamily,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primary.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildSelectableRow<int>(
                        options: shortBreakOptions,
                        selectedValue: displayBreakMinutes,
                        getLabel: (val) => '${val}m',
                        onChanged: (val) {
                          ref
                              .read(pomodoroSettingsProvider.notifier)
                              .updateSettings(settings.copyWith(breakMinutes: val));
                        },
                      ),
                      const SizedBox(height: 16),

                      // Target rounds label & selector
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Target rounds',
                            style: TextStyle(
                              fontFamily: AppTextStyles.fontFamily,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primary.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildSelectableRow<int>(
                        options: targetRoundsOptions,
                        selectedValue: displayTargetRounds,
                        getLabel: (val) => '$val',
                        onChanged: (val) {
                          ref
                              .read(pomodoroSettingsProvider.notifier)
                              .updateSettings(settings.copyWith(targetRounds: val));
                        },
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: 24),

          // 3. Tag selection grid (BorderRadius 16 for cards)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tag',
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary.withValues(alpha: 0.6),
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  Navigator.push(
                    context,
                    ModalSheetRoute(
                      builder: (context) => const Sheet(
                        decoration: MaterialSheetDecoration(
                          size: SheetSize.fit,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(24),
                            topRight: Radius.circular(24),
                          ),
                          color: Color(0xFFF6F6F6),
                        ),
                        child: CreateCategorySheet(),
                      ),
                    ),
                  );
                },
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE5E5EA),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    CupertinoIcons.add,
                    size: 16,
                    color: Color(0xFF232321),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          categoriesAsync.when(
            data: (categories) {
              if (categories.isEmpty) return const SizedBox.shrink();

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 2.8,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isSelected =
                      settings.selectedCategory?.id == category.id;

                  return GestureDetector(
                    onTap: () {
                      ref
                          .read(pomodoroSettingsProvider.notifier)
                          .updateSettings(
                            settings.copyWith(selectedCategory: category),
                          );
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF232321)
                            : CupertinoColors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              category.name,
                              style: TextStyle(
                                fontFamily: AppTextStyles.fontFamily,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: isSelected
                                    ? CupertinoColors.white
                                    : const Color(0xFF232321),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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
                  );
                },
              );
            },
            // Loading skeleton grid
            loading: () => GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 2.8,
              ),
              itemCount: 6,
              itemBuilder: (context, index) {
                return const ShimmerPlaceholder.rectangular(
                  borderRadius: BorderRadius.all(
                    Radius.circular(16),
                  ), // Rounded shimmers radius (16px)
                );
              },
            ),
            error: (err, stack) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
