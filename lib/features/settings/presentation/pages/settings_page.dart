import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Divider, Colors, Material;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_sheets/smooth_sheets.dart';
import 'package:lorofy/components/layout/app_header.dart';
import 'package:lorofy/components/ui/svg_asset.dart';
import 'package:lorofy/components/ui/app_switch.dart';
import 'package:lorofy/core/theme/app_theme.dart';
import 'package:lorofy/features/focus/presentation/providers/pomodoro_settings.dart';
import 'package:lorofy/features/focus/domain/enums/block_mode.dart';
import 'package:lorofy/features/focus/presentation/widgets/session_settings/edit_breaks_and_rounds_sheet.dart';
import 'package:lorofy/features/focus/presentation/widgets/session_settings/block_mode_selection_sheet.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  void _openPomodoroRules(BuildContext context) {
    Navigator.push(
      context,
      CupertinoModalSheetRoute(
        builder: (context) => const Sheet(
          decoration: MaterialSheetDecoration(
            size: SheetSize.stretch,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            color: Color(0xFFF6F6F6),
          ),
          child: EditBreaksAndRoundsSheet(),
        ),
      ),
    );
  }

  void _openFocusModeSelection(BuildContext context) {
    Navigator.push(
      context,
      CupertinoModalSheetRoute(
        builder: (context) => const Sheet(
          decoration: MaterialSheetDecoration(
            size: SheetSize.stretch,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            color: Color(0xFFF6F6F6),
          ),
          child: BlockModeSelectionSheet(),
        ),
      ),
    );
  }

  void _confirmDeactivate(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Deactivate Account'),
        content: const Text(
          'Are you sure you want to deactivate your account? This action cannot be undone.',
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Deactivate'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Color(0xFF8E8E93),
        ),
      ),
    );
  }

  Widget _buildRow({
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color? titleColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: titleColor ?? AppColors.primary,
                ),
              ),
            ),
            if (subtitle != null) ...[
              Text(
                subtitle,
                style: const TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 14,
                  color: Color(0xFF8E8E93),
                ),
              ),
              const SizedBox(width: 6),
            ],
            if (trailing != null)
              trailing
            else if (onTap != null)
              const Icon(
                CupertinoIcons.chevron_right,
                size: 16,
                color: Color(0xFFC7C7CC),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(pomodoroSettingsProvider);
    final blockModeStr = settings.blockMode == BlockMode.STRICT ? 'Strict' : 'Medium';

    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      child: SafeArea(
        child: Material(
          color: Colors.transparent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppHeader(
                leftActions: CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => context.pop(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE4E4E6),
                      shape: BoxShape.circle,
                    ),
                    child: const SVG(
                      'assets/icons/chevron-left.svg',
                      width: 24,
                      height: 24,
                    ),
                  ),
                ),
                title: 'Settings',
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Section 1: APP PREFERENCES
                      _buildSectionHeader('APP PREFERENCES'),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: CupertinoColors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            _buildRow(
                              title: 'Pomodoro Rules',
                              subtitle: '${settings.breakMinutes}m · ${settings.targetRounds}r',
                              onTap: () => _openPomodoroRules(context),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Divider(height: 1, color: Color(0xFFE5E5EA)),
                            ),
                            _buildRow(
                              title: 'App Blocker Rules',
                              subtitle: blockModeStr,
                              onTap: () => _openFocusModeSelection(context),
                            ),
                          ],
                        ),
                      ),

                      // Section 2: GENERAL SETTINGS
                      _buildSectionHeader('GENERAL SETTINGS'),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: CupertinoColors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            _buildRow(
                              title: 'Push Notifications',
                              trailing: AppSwitch(
                                value: settings.pushNotifications,
                                onChanged: (val) {
                                  ref.read(pomodoroSettingsProvider.notifier).updateSettings(
                                        settings.copyWith(pushNotifications: val),
                                      );
                                },
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Divider(height: 1, color: Color(0xFFE5E5EA)),
                            ),
                            _buildRow(
                              title: 'Background Process',
                              trailing: AppSwitch(
                                value: settings.backgroundProcess,
                                onChanged: (val) {
                                  ref.read(pomodoroSettingsProvider.notifier).updateSettings(
                                        settings.copyWith(backgroundProcess: val),
                                      );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Section 3: ACCOUNT
                      _buildSectionHeader('ACCOUNT'),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: CupertinoColors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: _buildRow(
                          title: 'Deactivate Account',
                          titleColor: const Color(0xFFD93B2B),
                          onTap: () => _confirmDeactivate(context),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
