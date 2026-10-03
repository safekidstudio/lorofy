// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get common_appName => 'Lorofy';

  @override
  String get common_cancel => 'Cancel';

  @override
  String get common_save => 'Save';

  @override
  String get common_confirm => 'Confirm';

  @override
  String get common_all => 'All';

  @override
  String get common_today => 'Today';

  @override
  String get common_week => 'Week';

  @override
  String get settings_title => 'Settings';

  @override
  String get settings_appPreferences => 'APP PREFERENCES';

  @override
  String get settings_notifications => 'NOTIFICATIONS';

  @override
  String get settings_language => 'Language';

  @override
  String get settings_languageEnglish => 'English';

  @override
  String get settings_languageVietnamese => 'Vietnamese';

  @override
  String get settings_languageSystem => 'System Default';

  @override
  String get settings_pomodoroRules => 'Pomodoro Rules';

  @override
  String get settings_appBlockerRules => 'App Blocker Rules';

  @override
  String get settings_focusReminders => 'Focus Reminders';

  @override
  String get settings_focusRemindersDesc => 'Remind before session starts';

  @override
  String get focus_strictMode => 'Strict Mode';

  @override
  String get focus_strictModeDesc =>
      'In focus, opening other apps kill the plant';

  @override
  String get focus_mediumMode => 'Medium Mode';

  @override
  String get focus_mediumModeDesc =>
      'In focus, only whitelisted apps can be opened';

  @override
  String get focus_selectAllowedApps => 'Select allowed apps';

  @override
  String get focus_nowToEarn => 'Focus Now to Earn Coins 🎯';

  @override
  String get profile_myActivities => 'My activities';

  @override
  String get profile_completed => 'Completed';

  @override
  String get profile_failed => 'Failed';

  @override
  String get profile_noActivitiesFound => 'No activities found';

  @override
  String get profile_tryChangingFilters =>
      'Try changing your filters or start a new focus session.';

  @override
  String get profile_restoreStreak => 'Restore Streak';

  @override
  String profile_saveYourStreak(int count) {
    return 'Save Your $count-Day Streak!';
  }

  @override
  String get profile_recoverStreakDesc =>
      'Recover your progress using a shield or coins.';

  @override
  String get profile_streakFreezeShield => 'Streak Freeze Shield';

  @override
  String profile_availableShields(int count) {
    return 'Available: $count shields';
  }

  @override
  String get profile_noShields => 'No freeze shields in inventory';

  @override
  String profile_useGoldCoins(int cost) {
    return 'Use $cost Gold Coins';
  }

  @override
  String profile_coinBalance(int balance) {
    return 'Balance: $balance coins';
  }

  @override
  String get profile_needMoreCoinsTip =>
      'You need more coins to restore. Complete focus sessions to earn Gold Coins!';
}
