import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Material, Colors;
import 'package:lorofy/components/layout/app_header.dart';
import 'package:lorofy/components/ui/sound_clickable.dart';
import 'package:lorofy/features/focus/presentation/widgets/session_settings/settings_session_tab.dart';

class SessionSettingsPage extends StatelessWidget {
  const SessionSettingsPage({super.key});

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
                title: 'Focus Settings',
              ),
              const SizedBox(height: 12),
              const Expanded(
                child: SettingsSessionTab(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
