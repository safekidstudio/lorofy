import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Material, Colors;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lorofy/components/layout/app_header.dart';
import 'package:lorofy/components/ui/sound_clickable.dart';
import 'package:lorofy/core/storage/settings_storage.dart';
import 'package:lorofy/features/focus/presentation/widgets/settings/settings_session_tab.dart';
import 'package:lorofy/features/focus/presentation/widgets/timer/first_time_coachmark_overlay.dart';

class SessionSettingsPage extends ConsumerStatefulWidget {
  const SessionSettingsPage({super.key});

  @override
  ConsumerState<SessionSettingsPage> createState() => _SessionSettingsPageState();
}

class _SessionSettingsPageState extends ConsumerState<SessionSettingsPage> {
  final GlobalKey _pomodoroModeKey = GlobalKey();
  final GlobalKey _durationKey = GlobalKey();
  final GlobalKey _tagKey = GlobalKey();
  final GlobalKey _blockModeKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final storage = ref.read(settingsStorageProvider);
      if (!storage.isFirstSettingsTourCompleted()) {
        showSessionSettingsCoachmarkTour(
          context: context,
          pomodoroModeKey: _pomodoroModeKey,
          durationKey: _durationKey,
          tagKey: _tagKey,
          blockModeKey: _blockModeKey,
          onFinish: () {
            ref.read(settingsStorageProvider).setFirstSettingsTourCompleted(true);
          },
        );
      }
    });
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
              const AppHeader(
                leftActions: AppBackButton(),
                title: 'Focus Settings',
              ),
              const SizedBox(height: 12),
              Expanded(
                child: SettingsSessionTab(
                  pomodoroModeKey: _pomodoroModeKey,
                  durationKey: _durationKey,
                  tagKey: _tagKey,
                  blockModeKey: _blockModeKey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
