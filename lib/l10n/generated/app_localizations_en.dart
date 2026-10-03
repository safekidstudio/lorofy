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
  String get common_month => 'Month';

  @override
  String get common_day => 'Day';

  @override
  String get common_update => 'Update';

  @override
  String get common_retry => 'Retry';

  @override
  String get common_viewMore => 'View more';

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
  String get home_congratulationsTitle => '🎉 Congratulations!';

  @override
  String home_sessionCompletedInactive(int minutes) {
    return 'You completed your $minutes-minute focus session while the app was inactive. Your points and streak have been credited!';
  }

  @override
  String get home_awesome => 'Awesome';

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
  String get focus_keepGoing => 'Keep Going';

  @override
  String get focus_giveUpConfirmTitle => 'Giving up already?';

  @override
  String get focus_cancelSessionConfirmTitle => 'Cancel Focus Session?';

  @override
  String get focus_gracePeriodDesc =>
      'You started less than 1 minute ago. Cancelling now will incur NO penalties.';

  @override
  String get focus_giveUpBtn => 'I give up...';

  @override
  String get focus_cancelSessionBtn => 'Cancel Session';

  @override
  String get focus_gracePeriodProtection => 'Grace Period Protection';

  @override
  String get focus_noPointsDeducted => 'No points will be deducted';

  @override
  String get focus_sessionProgressReset => 'Session Progress Reset';

  @override
  String get focus_sessionNotLogged => 'Session won\'t be logged in stats';

  @override
  String get focus_treeWithered => 'Focus Tree Withered';

  @override
  String get focus_growingTreeWillDie => 'Your growing tree will die';

  @override
  String get focus_rankPointsDeducted => 'Rank Points Deducted';

  @override
  String focus_modePenalty(String mode) {
    return '$mode mode penalty';
  }

  @override
  String get focus_dailyStreakRisk => 'Daily Streak Risk';

  @override
  String get focus_streakResetTip => 'Streak resets if no session today';

  @override
  String get focus_wow => 'Wow!';

  @override
  String get focus_plantGrownUp => 'The plant has grown up';

  @override
  String focus_dayStreak(int count) {
    return '$count-Day Streak!';
  }

  @override
  String get focus_plusOneToday => '+1 Today 🎉';

  @override
  String get focus_haveARest => 'Have a rest';

  @override
  String get focus_plantDead => 'Oh no, your plant is dead';

  @override
  String get focus_restart => 'Restart';

  @override
  String get focus_backToHome => 'Back to Home';

  @override
  String get explore_title => 'Explore';

  @override
  String get explore_todayFocus => 'Today Focus';

  @override
  String get explore_allFocus => 'All Focus';

  @override
  String get explore_todayKill => 'Today Kill';

  @override
  String get explore_allKill => 'All Kill';

  @override
  String get explore_avgFocusTime => 'Average\nFocus time';

  @override
  String get explore_avgKillTime => 'Average\nKill time';

  @override
  String explore_mins(int count) {
    return '$count mins';
  }

  @override
  String get explore_recentFocus => 'Recent Focus';

  @override
  String get explore_dailyAverage => 'Daily Average ';

  @override
  String get explore_noFocusDataWeek => 'No focus data this week 🌿';

  @override
  String get explore_focusRecord => 'Focus Record';

  @override
  String get explore_noFocusRecordsToday => 'No focus records today';

  @override
  String get explore_noFocusRecordsMonth =>
      'No focus records in the last 30 days';

  @override
  String get explore_leaderboard => 'Leaderboard';

  @override
  String get explore_noRankingsYet => 'No Rankings Yet';

  @override
  String get explore_noRankingsDesc =>
      'Be the first to complete a focus session and claim top spot!';

  @override
  String get explore_you => 'You';

  @override
  String get profile_title => 'Profile';

  @override
  String get profile_myProfile => 'My Profile';

  @override
  String get profile_myPoints => 'My Points';

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

  @override
  String get profile_logout => 'Logout';

  @override
  String get profile_logoutConfirm => 'Are you sure you want to log out?';

  @override
  String get profile_displayName => 'Display Name';

  @override
  String get profile_username => 'Username';

  @override
  String get profile_countryRegion => 'Country / Region';

  @override
  String get profile_updatingAvatar => 'Updating avatar...';

  @override
  String get profile_avatarUpdated => 'Avatar updated!';

  @override
  String get profile_uploadingAvatar => 'Uploading avatar...';

  @override
  String get profile_avatarUploaded => 'Avatar uploaded!';

  @override
  String get profile_failedUpdateAvatar => 'Failed to update avatar';

  @override
  String get profile_failedUploadAvatar => 'Failed to upload avatar';

  @override
  String get profile_profileUpdated => 'Profile updated!';

  @override
  String get profile_failedUpdateProfile => 'Failed to update profile';
}
