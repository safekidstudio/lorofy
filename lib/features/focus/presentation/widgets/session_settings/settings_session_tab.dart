import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lorofy/core/theme/app_theme.dart';
import 'package:lorofy/features/focus/presentation/providers/categories_provider.dart';
import 'deep_focus_section.dart';
import 'time_duration_section.dart';
import 'tag_section.dart';
import 'advanced_mode_section.dart';

class SettingsSessionTab extends ConsumerWidget {
  const SettingsSessionTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(focusCategoriesProvider);

    return SingleChildScrollView(
      key: const ValueKey('session_tab'),
      physics: const BouncingScrollPhysics(),
      padding: AppPadding.allMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const DeepFocusSection(),
          const SizedBox(height: 24),
          const TimeDurationSection(),
          const SizedBox(height: 24),
          TagSection(categoriesAsync: categoriesAsync),
          const SizedBox(height: 24),
          const AdvancedModeSection(),
        ],
      ),
    );
  }
}
