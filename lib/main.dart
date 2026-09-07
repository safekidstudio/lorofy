import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:lorofy/core/storage/settings_storage.dart';
import 'package:lorofy/components/ui/global_loading_overlay.dart';

import 'package:lorofy/core/services/feedback/feedback_provider.dart';
import 'package:lorofy/core/services/feedback/ui_feedback_service_impl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  
  // Pre-initialize UI sound and haptic feedback
  final feedbackService = UIFeedbackServiceImpl();
  await feedbackService.init();

  runApp(
    ProviderScope(
      overrides: [
        settingsStorageProvider.overrideWithValue(SettingsStorage(prefs)),
        feedbackServiceProvider.overrideWithValue(feedbackService),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return CupertinoApp.router(
      title: 'Lorofy',
      debugShowCheckedModeBanner: false,
      theme: const CupertinoThemeData(
        primaryColor: CupertinoColors.activeBlue,
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.background,
        textTheme: CupertinoTextThemeData(
          textStyle: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            color: AppColors.primary,
          ),
        ),
      ),
      localizationsDelegates: const [
        DefaultMaterialLocalizations.delegate,
        DefaultCupertinoLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
      ],
      routerConfig: router,
      builder: (context, child) {
        return GlobalLoadingOverlay(
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
