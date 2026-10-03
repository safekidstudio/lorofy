// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Lorofy';

  @override
  String get settings => 'Settings';

  @override
  String get appPreferences => 'APP PREFERENCES';

  @override
  String get notifications => 'NOTIFICATIONS';

  @override
  String get language => 'Language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageVietnamese => 'Vietnamese';

  @override
  String get languageSystem => 'System Default';

  @override
  String get pomodoroRules => 'Pomodoro Rules';

  @override
  String get appBlockerRules => 'App Blocker Rules';

  @override
  String get focusReminders => 'Focus Reminders';

  @override
  String get focusRemindersDescription => 'Remind before session starts';

  @override
  String get restoreStreak => 'Restore Streak';

  @override
  String saveYourStreak(int count) {
    return 'Save Your $count-Day Streak!';
  }

  @override
  String get recoverStreakDescription =>
      'Recover your progress using a shield or coins.';

  @override
  String get streakFreezeShield => 'Streak Freeze Shield';

  @override
  String availableShields(int count) {
    return 'Available: $count shields';
  }

  @override
  String get noShields => 'No freeze shields in inventory';

  @override
  String useGoldCoins(int cost) {
    return 'Use $cost Gold Coins';
  }

  @override
  String coinBalance(int balance) {
    return 'Balance: $balance coins';
  }

  @override
  String get focusNowToEarn => 'Focus Now to Earn Coins 🎯';

  @override
  String get needMoreCoinsTip =>
      'You need more coins to restore. Complete focus sessions to earn Gold Coins!';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get confirm => 'Confirm';

  @override
  String get strictMode => 'Strict Mode';

  @override
  String get mediumMode => 'Medium Mode';

  @override
  String get mediumModeDescription =>
      'In focus, only whitelisted apps can be opened';

  @override
  String get strictModeDescription =>
      'In focus, opening other apps kill the plant';

  @override
  String get selectAllowedApps => 'Select allowed apps';

  @override
  String get myActivities => 'My activities';

  @override
  String get all => 'All';

  @override
  String get today => 'Today';

  @override
  String get week => 'Week';

  @override
  String get completed => 'Completed';

  @override
  String get failed => 'Failed';

  @override
  String get noActivitiesFound => 'No activities found';

  @override
  String get tryChangingFilters =>
      'Try changing your filters or start a new focus session.';
}
