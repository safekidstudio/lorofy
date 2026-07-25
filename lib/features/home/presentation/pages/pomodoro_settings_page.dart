import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lorofy/components/ui/app_header.dart';
import 'package:lorofy/components/ui/button.dart';
import 'package:lorofy/components/ui/toast.dart';
import 'package:lorofy/core/theme/app_theme.dart';
import 'package:lorofy/features/home/presentation/providers/pomodoro_settings.dart';

class PomodoroSettingsPage extends ConsumerStatefulWidget {
  const PomodoroSettingsPage({super.key});

  @override
  ConsumerState<PomodoroSettingsPage> createState() => _PomodoroSettingsPageState();
}

class _PomodoroSettingsPageState extends ConsumerState<PomodoroSettingsPage> {
  late int _focusMinutes;
  late int _breakMinutes;
  late int _longBreakMinutes;
  late int _targetRounds;
  late AmbientSound _ambientSound;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(pomodoroSettingsProvider);
    _focusMinutes = settings.focusMinutes;
    _breakMinutes = settings.breakMinutes;
    _longBreakMinutes = settings.longBreakMinutes;
    _targetRounds = settings.targetRounds;
    _ambientSound = settings.ambientSound;
  }

  void _saveSettings() {
    ref.read(pomodoroSettingsProvider.notifier).updateSettings(
          PomodoroSettings(
            focusMinutes: _focusMinutes,
            breakMinutes: _breakMinutes,
            longBreakMinutes: _longBreakMinutes,
            targetRounds: _targetRounds,
            ambientSound: _ambientSound,
          ),
        );
    AppToast.show(
      context,
      message: 'Settings saved successfully!',
      type: ToastType.success,
    );
    Navigator.pop(context);
  }

  Widget _buildSoundCircle({
    required AmbientSound sound,
    required IconData icon,
    required bool isNone,
  }) {
    final isSelected = _ambientSound == sound;
    final color = isSelected ? const Color(0xFF232321) : const Color(0xFFE5E5EA);
    final iconColor = isSelected ? CupertinoColors.white : const Color(0xFF232321);

    return GestureDetector(
      onTap: () {
        setState(() {
          _ambientSound = sound;
        });
      },
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: isNone && isSelected
              ? Border.all(
                  color: CupertinoColors.white,
                  width: 2.0,
                  style: BorderStyle.solid,
                )
              : null,
        ),
        alignment: Alignment.center,
        child: isNone && isSelected
            ? Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: CupertinoColors.white.withValues(alpha: 0.6),
                    width: 1.5,
                    style: BorderStyle.solid, // Custom paint could be used for dashed, but solid white ring looks identical and clean
                  ),
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 22, color: iconColor),
              )
            : Icon(icon, size: 22, color: iconColor),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final focusPresets = [1, 2, 5, 10, 15, 25, 45, 60, 90];
    final breakPresets = [1, 2, 3, 5, 10, 15, 20];
    final longBreakPresets = [5, 10, 15, 20, 30];

    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Custom Header using reusable AppHeader component
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AppHeader(
                leftActions: CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => Navigator.pop(context),
                  child: const Icon(
                    CupertinoIcons.xmark,
                    color: Color(0xFF232321),
                    size: 24,
                  ),
                ),
                title: 'Settings',
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),

                    // Ambient Sounds Panel
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: CupertinoColors.white,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        boxShadow: [
                          BoxShadow(
                            color: CupertinoColors.systemGrey.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildSoundCircle(
                                  sound: AmbientSound.none,
                                  icon: CupertinoIcons.clear,
                                  isNone: true,
                                ),
                                _buildSoundCircle(
                                  sound: AmbientSound.wind,
                                  icon: CupertinoIcons.wind,
                                  isNone: false,
                                ),
                                _buildSoundCircle(
                                  sound: AmbientSound.beach,
                                  icon: CupertinoIcons.umbrella,
                                  isNone: false,
                                ),
                                _buildSoundCircle(
                                  sound: AmbientSound.nature,
                                  icon: CupertinoIcons.tree,
                                  isNone: false,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildSoundCircle(
                                  sound: AmbientSound.books,
                                  icon: CupertinoIcons.book,
                                  isNone: false,
                                ),
                                _buildSoundCircle(
                                  sound: AmbientSound.fire,
                                  icon: CupertinoIcons.flame,
                                  isNone: false,
                                ),
                                _buildSoundCircle(
                                  sound: AmbientSound.rain,
                                  icon: CupertinoIcons.cloud_rain,
                                  isNone: false,
                                ),
                                _buildSoundCircle(
                                  sound: AmbientSound.cafe,
                                  icon: CupertinoIcons.smoke,
                                  isNone: false,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Focus Duration Presets
                    const Text(
                      'Focus Duration (minutes)',
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8E8E93),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: focusPresets.map((minutes) {
                          final isSelected = _focusMinutes == minutes;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () => setState(() => _focusMinutes = minutes),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFF072013)
                                      : CupertinoColors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFF072013)
                                        : const Color(0xFFE5E5EA),
                                    width: 1.5,
                                  ),
                                ),
                                child: Text(
                                  '${minutes}m',
                                  style: TextStyle(
                                    fontFamily: AppTextStyles.fontFamily,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? CupertinoColors.white
                                        : const Color(0xFF232321),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Short Break Presets
                    const Text(
                      'Short Break (minutes)',
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8E8E93),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: breakPresets.map((minutes) {
                          final isSelected = _breakMinutes == minutes;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () => setState(() => _breakMinutes = minutes),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFF072013)
                                      : CupertinoColors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFF072013)
                                        : const Color(0xFFE5E5EA),
                                    width: 1.5,
                                  ),
                                ),
                                child: Text(
                                  '${minutes}m',
                                  style: TextStyle(
                                    fontFamily: AppTextStyles.fontFamily,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? CupertinoColors.white
                                        : const Color(0xFF232321),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Long Break Presets
                    const Text(
                      'Long Break (minutes)',
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8E8E93),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: longBreakPresets.map((minutes) {
                          final isSelected = _longBreakMinutes == minutes;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () => setState(() => _longBreakMinutes = minutes),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFF072013)
                                      : CupertinoColors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFF072013)
                                        : const Color(0xFFE5E5EA),
                                    width: 1.5,
                                  ),
                                ),
                                child: Text(
                                  '${minutes}m',
                                  style: TextStyle(
                                    fontFamily: AppTextStyles.fontFamily,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? CupertinoColors.white
                                        : const Color(0xFF232321),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Target Rounds Stepper
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Target Rounds',
                          style: TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF8E8E93),
                          ),
                        ),
                        Row(
                          children: [
                            CupertinoButton(
                              padding: EdgeInsets.zero,
                              onPressed: _targetRounds > 1
                                  ? () => setState(() => _targetRounds--)
                                  : null,
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: CupertinoColors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: const Color(0xFFE5E5EA)),
                                ),
                                child: const Icon(
                                  CupertinoIcons.minus,
                                  size: 16,
                                  color: Color(0xFF232321),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                '$_targetRounds',
                                style: const TextStyle(
                                  fontFamily: AppTextStyles.fontFamily,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF232321),
                                ),
                              ),
                            ),
                            CupertinoButton(
                              padding: EdgeInsets.zero,
                              onPressed: _targetRounds < 12
                                  ? () => setState(() => _targetRounds++)
                                  : null,
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: CupertinoColors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: const Color(0xFFE5E5EA)),
                                ),
                                child: const Icon(
                                  CupertinoIcons.plus,
                                  size: 16,
                                  color: Color(0xFF232321),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // Cancel and Save buttons (Using drawing sketch style container)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: Button.secondary(
                        text: 'Cancel',
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: Button.primary(
                        text: 'Save',
                        onPressed: _saveSettings,
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
