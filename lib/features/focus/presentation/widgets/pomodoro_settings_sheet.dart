import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lorofy/core/theme/app_theme.dart';
import 'package:lorofy/features/focus/presentation/widgets/settings_pomodoro_tab.dart';
import 'package:lorofy/features/focus/presentation/widgets/settings_sound_tab.dart';

class PomodoroSettingsSheet extends ConsumerStatefulWidget {
  final int initialTab;
  const PomodoroSettingsSheet({super.key, this.initialTab = 0});

  @override
  ConsumerState<PomodoroSettingsSheet> createState() =>
      _PomodoroSettingsSheetState();
}

class _PomodoroSettingsSheetState extends ConsumerState<PomodoroSettingsSheet> {
  late int _selectedTab;

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTab;
  }

  Widget _buildSlidingSegmentedControl() {
    return Container(
      width: 180,
      height: 38,
      decoration: BoxDecoration(
        color: const Color(0xFFE5E5EA).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          // Smooth Animated sliding active background block
          AnimatedAlign(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOutCubic,
            alignment: _selectedTab == 0
                ? Alignment.centerLeft
                : Alignment.centerRight,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              child: Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: CupertinoColors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF000000).withValues(alpha: 0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Interactive tab labels
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => setState(() => _selectedTab = 0),
                  child: Center(
                    child: Text(
                      'Pomodoro',
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: _selectedTab == 0
                            ? const Color(0xFF232321)
                            : const Color(0xFF8E8E93),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => setState(() => _selectedTab = 1),
                  child: Center(
                    child: Text(
                      'Sound',
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: _selectedTab == 1
                            ? const Color(0xFF232321)
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

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 12),

            // Top Bar: Centered sliding control using Stack
            Padding(
              padding: AppPadding.horizontalMd,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Close Button on Left
                  Align(
                    alignment: Alignment.centerLeft,
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.pop(context),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE5E5EA),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          CupertinoIcons.xmark,
                          color: Color(0xFF232321),
                          fontWeight: FontWeight.bold,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                  // Centered Premium Sliding Tab Control
                  _buildSlidingSegmentedControl(),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Tab View content
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                layoutBuilder:
                    (Widget? currentChild, List<Widget> previousChildren) {
                      return Stack(
                        alignment: Alignment.topCenter,
                        children: <Widget>[...previousChildren, ?currentChild],
                      );
                    },
                child: _selectedTab == 0
                    ? const SettingsPomodoroTab(key: ValueKey('pomodoro_tab'))
                    : const SettingsSoundTab(key: ValueKey('sound_tab')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
