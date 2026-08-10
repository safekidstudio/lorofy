import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lorofy/components/layout/app_header.dart';
import 'package:lorofy/components/ui/svg_asset.dart';
import 'package:lorofy/features/focus/presentation/widgets/session_settings/settings_sound_tab.dart';

class SoundSettingsPage extends StatelessWidget {
  const SoundSettingsPage({super.key});

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
                title: 'Sounds',
              ),
              const SizedBox(height: 24),
              const Expanded(
                child: SettingsSoundTab(key: ValueKey('sound_settings_tab')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
