import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Divider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lorofy/components/ui/button.dart';
import 'package:lorofy/components/ui/app_switch.dart';
import 'package:lorofy/components/ui/svg_asset.dart';
import 'package:lorofy/components/layout/app_header.dart';
import 'package:lorofy/core/theme/app_theme.dart';
import 'package:lorofy/features/focus/presentation/providers/pomodoro_settings.dart';

class EditBreaksAndRoundsSheet extends ConsumerStatefulWidget {
  const EditBreaksAndRoundsSheet({super.key});

  @override
  ConsumerState<EditBreaksAndRoundsSheet> createState() =>
      _EditBreaksAndRoundsSheetState();
}

class _EditBreaksAndRoundsSheetState
    extends ConsumerState<EditBreaksAndRoundsSheet> {
  late int _focusMinutes;
  late int _breakMinutes;
  late int _targetRounds;
  late bool _autoStartBreak;
  late bool _autoStartFocus;

  // Track the custom inputs so we can persist/render them if selected
  int _customFocusMinutes = 22;
  int _customBreakMinutes = 22;
  int _customTargetRounds = 6;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(pomodoroSettingsProvider);
    _focusMinutes = settings.focusMinutes;
    _breakMinutes = settings.breakMinutes;
    _targetRounds = settings.targetRounds;
    _autoStartBreak = settings.autoStartBreak;
    _autoStartFocus = settings.autoStartFocus;

    // Initialize custom variables if active setting is not one of presets
    const focusPresets = [25, 30, 45, 60];
    if (!focusPresets.contains(_focusMinutes)) {
      _customFocusMinutes = _focusMinutes;
    }
    const breakPresets = [5, 10, 15, 20];
    if (!breakPresets.contains(_breakMinutes)) {
      _customBreakMinutes = _breakMinutes;
    }
    const targetPresets = [2, 3, 4, 5];
    if (!targetPresets.contains(_targetRounds)) {
      _customTargetRounds = _targetRounds;
    }
  }

  void _onSave() {
    final settings = ref.read(pomodoroSettingsProvider);
    ref
        .read(pomodoroSettingsProvider.notifier)
        .updateSettings(
          settings.copyWith(
            focusMinutes: _focusMinutes,
            breakMinutes: _breakMinutes,
            targetRounds: _targetRounds,
            autoStartBreak: _autoStartBreak,
            autoStartFocus: _autoStartFocus,
          ),
        );
    Navigator.pop(context);
  }

  Future<void> _showCustomValuePicker({
    required String title,
    required int initialValue,
    required int min,
    required int max,
    required String unit,
    required ValueChanged<int> onSelected,
  }) async {
    int tempVal = initialValue;
    await showCupertinoDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => CupertinoPageScaffold(
        backgroundColor: CupertinoColors.black.withValues(alpha: 0.4),
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFF6F6F6),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: const Color(0xFFE5E5EA)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Custom $title',
                  style: const TextStyle(
                    fontFamily: AppTextStyles.titleFontFamily,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 150,
                  child: CupertinoPicker(
                    itemExtent: 40,
                    scrollController: FixedExtentScrollController(
                      initialItem: (initialValue - min).clamp(0, max - min),
                    ),
                    onSelectedItemChanged: (index) {
                      tempVal = min + index;
                    },
                    children: List.generate(
                      max - min + 1,
                      (index) => Center(
                        child: Text(
                          '${min + index}$unit',
                          style: const TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Button.secondary(
                        text: 'Cancel',
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Button.primary(
                        text: 'OK',
                        onPressed: () {
                          onSelected(tempVal);
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildPresetChips<T>({
    required T currentValue,
    required List<T> presets,
    required T customValue,
    required String Function(T) labelBuilder,
    required ValueChanged<T> onChanged,
    required VoidCallback onCustomTap,
  }) {
    final bool isCustomSelected = !presets.contains(currentValue);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          ...presets.map((preset) {
            final isSelected = currentValue == preset && !isCustomSelected;
            return GestureDetector(
              onTap: () => onChanged(preset),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.only(right: 8),
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF071B12)
                      : CupertinoColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF071B12)
                        : const Color(0xFFE5E5EA),
                  ),
                ),
                child: Text(
                  labelBuilder(preset),
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isSelected
                        ? CupertinoColors.white
                        : AppColors.primary,
                  ),
                ),
              ),
            );
          }),
          GestureDetector(
            onTap: onCustomTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isCustomSelected
                    ? const Color(0xFF071B12)
                    : const Color(0xFFE4E4E6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isCustomSelected
                      ? const Color(0xFF071B12)
                      : const Color(0xFFE4E4E6),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    labelBuilder(customValue),
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isCustomSelected
                          ? CupertinoColors.white
                          : AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  SVG(
                    'assets/icons/edit-drawing.svg',
                    width: 14,
                    height: 14,
                    color: isCustomSelected
                        ? CupertinoColors.white
                        : AppColors.primary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF6F6F6),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppHeader(
              leftActions: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => Navigator.pop(context),
                child: const SVG(
                  'assets/icons/cancel.svg',
                  width: 20,
                  height: 20,
                ),
              ),
              title: 'Pomodoro Rules',
            ),
            const SizedBox(height: 12),
            Expanded(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppPadding.xl,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // 1. Focus Duration
                          _buildSectionHeader('Focus Duration'),
                          _buildPresetChips<int>(
                            currentValue: _focusMinutes,
                            presets: const [25, 30, 45, 60],
                            customValue: _customFocusMinutes,
                            labelBuilder: (val) => '${val}m',
                            onChanged: (val) =>
                                setState(() => _focusMinutes = val),
                            onCustomTap: () {
                              _showCustomValuePicker(
                                title: 'Focus Duration',
                                initialValue: _customFocusMinutes,
                                min: 5,
                                max: 180,
                                unit: 'm',
                                onSelected: (val) {
                                  setState(() {
                                    _customFocusMinutes = val;
                                    _focusMinutes = val;
                                  });
                                },
                              );
                            },
                          ),
                          const SizedBox(height: 20),

                          // 2. Short Break
                          _buildSectionHeader('Short Break'),
                          _buildPresetChips<int>(
                            currentValue: _breakMinutes,
                            presets: const [5, 10, 15, 20],
                            customValue: _customBreakMinutes,
                            labelBuilder: (val) => '${val}m',
                            onChanged: (val) =>
                                setState(() => _breakMinutes = val),
                            onCustomTap: () {
                              _showCustomValuePicker(
                                title: 'Short Break',
                                initialValue: _customBreakMinutes,
                                min: 1,
                                max: 60,
                                unit: 'm',
                                onSelected: (val) {
                                  setState(() {
                                    _customBreakMinutes = val;
                                    _breakMinutes = val;
                                  });
                                },
                              );
                            },
                          ),
                          const SizedBox(height: 20),

                          // 3. Target Rounds
                          _buildSectionHeader('Target Rounds'),
                          _buildPresetChips<int>(
                            currentValue: _targetRounds,
                            presets: const [2, 3, 4, 5],
                            customValue: _customTargetRounds,
                            labelBuilder: (val) => '${val}r',
                            onChanged: (val) =>
                                setState(() => _targetRounds = val),
                            onCustomTap: () {
                              _showCustomValuePicker(
                                title: 'Target Rounds',
                                initialValue: _customTargetRounds,
                                min: 1,
                                max: 20,
                                unit: 'r',
                                onSelected: (val) {
                                  setState(() {
                                    _customTargetRounds = val;
                                    _targetRounds = val;
                                  });
                                },
                              );
                            },
                          ),
                          const SizedBox(height: 20),

                          // 4. Automation Card
                          _buildSectionHeader('Automation'),
                          Container(
                            decoration: BoxDecoration(
                              color: CupertinoColors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Auto-start Break',
                                        style: TextStyle(
                                          fontFamily: AppTextStyles.fontFamily,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.primary.withValues(
                                            alpha: .6,
                                          ),
                                        ),
                                      ),
                                      AppSwitch(
                                        value: _autoStartBreak,
                                        onChanged: (val) => setState(
                                          () => _autoStartBreak = val,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  child: Divider(
                                    height: 1,
                                    color: Color(0xFFE5E5EA),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Auto-start Focus',
                                        style: TextStyle(
                                          fontFamily: AppTextStyles.fontFamily,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.primary.withValues(
                                            alpha: .6,
                                          ),
                                        ),
                                      ),
                                      AppSwitch(
                                        value: _autoStartFocus,
                                        onChanged: (val) => setState(
                                          () => _autoStartFocus = val,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Spacer(),
                          Center(
                            child: SizedBox(
                              width: 160,
                              height: 48,
                              child: Button.primary(
                                text: 'Save',
                                onPressed: _onSave,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
