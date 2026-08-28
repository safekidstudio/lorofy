import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lorofy/components/layout/app_header.dart';
import 'package:lorofy/components/ui/sound_clickable.dart';
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
              const AppHeader(
                leftActions: AppBackButton(),
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
