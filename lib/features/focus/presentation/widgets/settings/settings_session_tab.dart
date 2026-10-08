import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lorofy/core/theme/app_theme.dart';
import 'package:lorofy/features/focus/presentation/providers/categories_provider.dart';
import 'deep_focus_section.dart';
import 'time_duration_section.dart';
import 'tag_section.dart';
import 'advanced_mode_section.dart';

class SettingsSessionTab extends ConsumerWidget {
  final GlobalKey? pomodoroModeKey;
  final GlobalKey? durationKey;
  final GlobalKey? tagKey;
  final GlobalKey? blockModeKey;

  const SettingsSessionTab({
    super.key,
    this.pomodoroModeKey,
    this.durationKey,
    this.tagKey,
    this.blockModeKey,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(focusCategoriesProvider);

    return SingleChildScrollView(
      key: const ValueKey('session_tab'),
      physics: const BouncingScrollPhysics(),
      padding: AppPadding.allLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            key: pomodoroModeKey,
            child: const DeepFocusSection(),
          ),
          const SizedBox(height: 24),
          Container(
            key: durationKey,
            child: const TimeDurationSection(),
          ),
          const SizedBox(height: 24),
          Container(
            key: tagKey,
            child: TagSection(categoriesAsync: categoriesAsync),
          ),
          const SizedBox(height: 24),
          Container(
            key: blockModeKey,
            child: const AdvancedModeSection(),
          ),
        ],
      ),
    );
  }
}
