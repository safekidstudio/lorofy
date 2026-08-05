import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lorofy/components/layout/app_header.dart';
import 'package:lorofy/components/ui/svg_asset.dart';
import 'package:lorofy/components/ui/sliding_segmented_control.dart';
import 'package:lorofy/features/focus/presentation/widgets/session_settings/settings_session_tab.dart';
import 'package:lorofy/features/focus/presentation/widgets/session_settings/settings_sound_tab.dart';

class SessionSettingsPage extends ConsumerStatefulWidget {
  final int initialTab;
  const SessionSettingsPage({super.key, this.initialTab = 0});

  @override
  ConsumerState<SessionSettingsPage> createState() =>
      _SessionSettingsPageState();
}

class _SessionSettingsPageState extends ConsumerState<SessionSettingsPage> {
  late int _selectedTab;

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTab;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      child: SafeArea(
        child: Material(
          color: Colors.transparent,
          child: Column(
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
                titleWidget: SlidingSegmentedControl(
                  tabs: const ['Session', 'Sounds'],
                  selectedIndex: _selectedTab,
                  onTabChanged: (index) => setState(() => _selectedTab = index),
                  width: 130,
                  height: 30,
                  backgroundColor: const Color(
                    0xFFE5E5EA,
                  ).withValues(alpha: 0.6),
                  activeColor: CupertinoColors.white,
                  activeTextColor: const Color(0xFF232321),
                  inactiveTextColor: const Color(0xFF8E8E93),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  layoutBuilder: (currentChild, previousChildren) {
                    return Stack(
                      alignment: Alignment.topCenter,
                      children: <Widget>[...previousChildren, currentChild!],
                    );
                  },
                  child: _selectedTab == 0
                      ? const SettingsSessionTab()
                      : const SettingsSoundTab(key: ValueKey('sound_tab')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
