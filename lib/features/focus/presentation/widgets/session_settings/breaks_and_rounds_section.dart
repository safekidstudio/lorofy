import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lorofy/core/theme/app_theme.dart';
import 'package:lorofy/features/focus/presentation/providers/pomodoro_settings.dart';

class BreaksAndRoundsSection extends ConsumerStatefulWidget {
  const BreaksAndRoundsSection({super.key});

  @override
  ConsumerState<BreaksAndRoundsSection> createState() => _BreaksAndRoundsSectionState();
}

class _BreaksAndRoundsSectionState extends ConsumerState<BreaksAndRoundsSection> {
  Future<void> _showCustomDialog({
    required BuildContext context,
    required String title,
    required int currentValue,
    required ValueChanged<int> onSubmitted,
  }) async {
    final controller = TextEditingController(text: currentValue.toString());
    await showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: Padding(
          padding: const EdgeInsets.only(top: 12.0),
          child: CupertinoTextField(
            controller: controller,
            keyboardType: TextInputType.number,
            placeholder: 'Value',
            autofocus: true,
            style: const TextStyle(fontFamily: AppTextStyles.fontFamily),
          ),
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            child: const Text('Save'),
            onPressed: () {
              final val = int.tryParse(controller.text);
              if (val != null && val > 0) {
                onSubmitted(val);
              }
              Navigator.pop(context);
            },
          ),
        ],
      ),
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
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Color(0xFF8E8E93),
            ),
            children: [
              TextSpan(text: '$title: '),
              TextSpan(
                text: '$currentValue mins',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF232321),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            ...presetOptions.map((opt) {
              final isSelected = currentValue == opt;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(opt),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.only(right: 8),
                    height: 40,
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF071B12) : CupertinoColors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        '${opt}m',
                        style: TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? CupertinoColors.white : const Color(0xFF232321),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
            GestureDetector(
              onTap: () => _showCustomDialog(
                context: context,
                title: 'Custom Break Duration',
                currentValue: currentValue,
                onSubmitted: onChanged,
              ),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E5EA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  CupertinoIcons.pencil,
                  size: 18,
                  color: Color(0xFF232321),
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
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Color(0xFF8E8E93),
            ),
            children: [
              const TextSpan(text: 'Target rounds: '),
              TextSpan(
                text: '$currentValue rounds',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF232321),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            ...presetOptions.map((opt) {
              final isSelected = currentValue == opt;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(opt),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.only(right: 8),
                    height: 40,
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF071B12) : CupertinoColors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        '${opt}r',
                        style: TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? CupertinoColors.white : const Color(0xFF232321),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
            GestureDetector(
              onTap: () => _showCustomDialog(
                context: context,
                title: 'Custom Target Rounds',
                currentValue: currentValue,
                onSubmitted: onChanged,
              ),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E5EA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  CupertinoIcons.pencil,
                  size: 18,
                  color: Color(0xFF232321),
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
