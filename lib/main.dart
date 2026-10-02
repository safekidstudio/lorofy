import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lorofy/features/focus/presentation/providers/focus_lifecycle_observer.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:lorofy/core/storage/settings_storage.dart';
import 'package:lorofy/components/ui/global_loading_overlay.dart';

import 'package:lorofy/core/services/feedback/feedback_provider.dart';
import 'package:lorofy/core/services/feedback/ui_feedback_service_impl.dart';

import 'package:audioplayers/audioplayers.dart';
import 'package:lorofy/core/network/network_connectivity_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure Android 15 / SDK 35 Edge-to-Edge System UI
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarContrastEnforced: false,
      systemStatusBarContrastEnforced: false,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  final prefs = await SharedPreferences.getInstance();

  // Configure global audio context: No player in the app steals or abandons AudioFocus
  try {
    await AudioPlayer.global.setAudioContext(
      AudioContext(
        android: const AudioContextAndroid(
          stayAwake: true,
          contentType: AndroidContentType.music,
          usageType: AndroidUsageType.media,
          audioFocus: AndroidAudioFocus.none,
        ),
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playback,
          options: {AVAudioSessionOptions.mixWithOthers},
        ),
      ),
    );
  } catch (_) {}

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
    // Activate network auto-retry listener across the entire app
    ref.watch(networkRetryNotifierProvider);

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
        return FocusLifecycleObserver(
          child: GlobalLoadingOverlay(
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
    );
  }
}
