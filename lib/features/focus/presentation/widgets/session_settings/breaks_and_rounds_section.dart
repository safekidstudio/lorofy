import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lorofy/components/ui/svg_asset.dart';
import 'package:lorofy/core/theme/app_theme.dart';
import 'package:lorofy/features/focus/presentation/providers/pomodoro_settings.dart';

class BreaksAndRoundsSection extends ConsumerStatefulWidget {
  const BreaksAndRoundsSection({super.key});

  @override
  ConsumerState<BreaksAndRoundsSection> createState() => _BreaksAndRoundsSectionState();
}

class _BreaksAndRoundsSectionState extends ConsumerState<BreaksAndRoundsSection> {
  Future<void> _showSpinnerPicker({
    required BuildContext context,
    required String title,
    required int currentValue,
    required List<int> options,
    required ValueChanged<int> onSubmitted,
  }) async {
    int selectedVal = currentValue;
    final initialIndex = options.indexOf(currentValue);
    final scrollController = FixedExtentScrollController(
      initialItem: initialIndex != -1 ? initialIndex : 0,
    );

    await showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 280,
          decoration: BoxDecoration(
            color: AppColors.card.resolveFrom(context),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: AppColors.border.resolveFrom(context),
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 16,
                            color: AppColors.secondary,
                          ),
                        ),
                      ),
                      Text(
                        title,
                        style: const TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          onSubmitted(selectedVal);
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Done',
                          style: TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF071B12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: CupertinoPicker(
                    itemExtent: 40.0,
                    scrollController: scrollController,
                    onSelectedItemChanged: (int index) {
                      selectedVal = options[index];
                    },
                    children: List<Widget>.generate(options.length, (int index) {
                      return Center(
                        child: Text(
                          '${options[index]}',
                          style: const TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 20,
                            color: AppColors.primary,
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBreakOptionsRow({
    required String title,
    required int currentValue,
    required List<int> presetOptions,
    required ValueChanged<int> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: const TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.secondary,
            ),
            children: [
              TextSpan(text: '$title: '),
              TextSpan(
                text: '$currentValue mins',
                style: const TextStyle(color: AppColors.primary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            ...presetOptions.map((opt) {
              final isSelected = currentValue == opt;
              return GestureDetector(
                onTap: () => onChanged(opt),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.only(right: 8),
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF071B12) : CupertinoColors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${opt}m',
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? CupertinoColors.white : AppColors.primary,
                    ),
                  ),
                ),
              );
            }),
            GestureDetector(
              onTap: () => _showSpinnerPicker(
                context: context,
                title: 'Break Duration',
                currentValue: currentValue,
                options: List<int>.generate(120, (i) => i + 1),
                onSubmitted: onChanged,
              ),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E5EA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Align(
                  alignment: Alignment.center,
                  child: SVG(
                    'assets/icons/edit-drawing.svg',
                    width: 16,
                    height: 16,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTargetRoundsRow({
    required int currentValue,
    required List<int> presetOptions,
    required ValueChanged<int> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: const TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.secondary,
            ),
            children: [
              const TextSpan(text: 'Target rounds: '),
              TextSpan(
                text: '$currentValue rounds',
                style: const TextStyle(color: AppColors.primary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            ...presetOptions.map((opt) {
              final isSelected = currentValue == opt;
              return GestureDetector(
                onTap: () => onChanged(opt),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.only(right: 8),
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF071B12) : CupertinoColors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${opt}r',
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? CupertinoColors.white : AppColors.primary,
                    ),
                  ),
                ),
              );
            }),
            GestureDetector(
              onTap: () => _showSpinnerPicker(
                context: context,
                title: 'Target Rounds',
                currentValue: currentValue,
                options: List<int>.generate(20, (i) => i + 1),
                onSubmitted: onChanged,
              ),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E5EA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Align(
                  alignment: Alignment.center,
                  child: SVG(
                    'assets/icons/edit-drawing.svg',
                    width: 16,
                    height: 16,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(pomodoroSettingsProvider);

    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      child: settings.isDeepFocusMode
          ? const SizedBox.shrink()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildBreakOptionsRow(
                  title: 'Short break',
                  currentValue: settings.breakMinutes,
                  presetOptions: const [5, 10, 20],
                  onChanged: (val) {
                    ref.read(pomodoroSettingsProvider.notifier).updateSettings(
                          settings.copyWith(breakMinutes: val),
                        );
                  },
                ),
                const SizedBox(height: 24),
                _buildTargetRoundsRow(
                  currentValue: settings.targetRounds,
                  presetOptions: const [2, 3, 4],
                  onChanged: (val) {
                    ref.read(pomodoroSettingsProvider.notifier).updateSettings(
                          settings.copyWith(targetRounds: val),
                        );
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
    );
  }
}
