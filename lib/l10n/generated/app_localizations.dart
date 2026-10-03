import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi'),
  ];

  /// No description provided for @common_appName.
  ///
  /// In en, this message translates to:
  /// **'Lorofy'**
  String get common_appName;

  /// No description provided for @common_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get common_cancel;

  /// No description provided for @common_save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get common_save;

  /// No description provided for @common_confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get common_confirm;

  /// No description provided for @common_all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get common_all;

  /// No description provided for @common_today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get common_today;

  /// No description provided for @common_week.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get common_week;

  /// No description provided for @common_month.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get common_month;

  /// No description provided for @common_day.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get common_day;

  /// No description provided for @common_update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get common_update;

  /// No description provided for @common_retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get common_retry;

  /// No description provided for @common_viewMore.
  ///
  /// In en, this message translates to:
  /// **'View more'**
  String get common_viewMore;

  /// No description provided for @settings_title.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings_title;

  /// No description provided for @settings_appPreferences.
  ///
  /// In en, this message translates to:
  /// **'APP PREFERENCES'**
  String get settings_appPreferences;

  /// No description provided for @settings_notifications.
  ///
  /// In en, this message translates to:
  /// **'NOTIFICATIONS'**
  String get settings_notifications;

  /// No description provided for @settings_language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settings_language;

  /// No description provided for @settings_languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settings_languageEnglish;

  /// No description provided for @settings_languageVietnamese.
  ///
  /// In en, this message translates to:
  /// **'Vietnamese'**
  String get settings_languageVietnamese;

  /// No description provided for @settings_languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get settings_languageSystem;

  /// No description provided for @settings_pomodoroRules.
  ///
  /// In en, this message translates to:
  /// **'Pomodoro Rules'**
  String get settings_pomodoroRules;

  /// No description provided for @settings_appBlockerRules.
  ///
  /// In en, this message translates to:
  /// **'App Blocker Rules'**
  String get settings_appBlockerRules;

  /// No description provided for @settings_focusReminders.
  ///
  /// In en, this message translates to:
  /// **'Focus Reminders'**
  String get settings_focusReminders;

  /// No description provided for @settings_focusRemindersDesc.
  ///
  /// In en, this message translates to:
  /// **'Remind before session starts'**
  String get settings_focusRemindersDesc;

  /// No description provided for @home_congratulationsTitle.
  ///
  /// In en, this message translates to:
  /// **'🎉 Congratulations!'**
  String get home_congratulationsTitle;

  /// No description provided for @home_sessionCompletedInactive.
  ///
  /// In en, this message translates to:
  /// **'You completed your {minutes}-minute focus session while the app was inactive. Your points and streak have been credited!'**
  String home_sessionCompletedInactive(int minutes);

  /// No description provided for @home_awesome.
  ///
  /// In en, this message translates to:
  /// **'Awesome'**
  String get home_awesome;

  /// No description provided for @focus_strictMode.
  ///
  /// In en, this message translates to:
  /// **'Strict Mode'**
  String get focus_strictMode;

  /// No description provided for @focus_strictModeDesc.
  ///
  /// In en, this message translates to:
  /// **'In focus, opening other apps kill the plant'**
  String get focus_strictModeDesc;

  /// No description provided for @focus_mediumMode.
  ///
  /// In en, this message translates to:
  /// **'Medium Mode'**
  String get focus_mediumMode;

  /// No description provided for @focus_mediumModeDesc.
  ///
  /// In en, this message translates to:
  /// **'In focus, only whitelisted apps can be opened'**
  String get focus_mediumModeDesc;

  /// No description provided for @focus_selectAllowedApps.
  ///
  /// In en, this message translates to:
  /// **'Select allowed apps'**
  String get focus_selectAllowedApps;

  /// No description provided for @focus_nowToEarn.
  ///
  /// In en, this message translates to:
  /// **'Focus Now to Earn Coins 🎯'**
  String get focus_nowToEarn;

  /// No description provided for @focus_keepGoing.
  ///
  /// In en, this message translates to:
  /// **'Keep Going'**
  String get focus_keepGoing;

  /// No description provided for @focus_giveUpConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Giving up already?'**
  String get focus_giveUpConfirmTitle;

  /// No description provided for @focus_cancelSessionConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel Focus Session?'**
  String get focus_cancelSessionConfirmTitle;

  /// No description provided for @focus_gracePeriodDesc.
  ///
  /// In en, this message translates to:
  /// **'You started less than 1 minute ago. Cancelling now will incur NO penalties.'**
  String get focus_gracePeriodDesc;

  /// No description provided for @focus_giveUpBtn.
  ///
  /// In en, this message translates to:
  /// **'I give up...'**
  String get focus_giveUpBtn;

  /// No description provided for @focus_cancelSessionBtn.
  ///
  /// In en, this message translates to:
  /// **'Cancel Session'**
  String get focus_cancelSessionBtn;

  /// No description provided for @focus_gracePeriodProtection.
  ///
  /// In en, this message translates to:
  /// **'Grace Period Protection'**
  String get focus_gracePeriodProtection;

  /// No description provided for @focus_noPointsDeducted.
  ///
  /// In en, this message translates to:
  /// **'No points will be deducted'**
  String get focus_noPointsDeducted;

  /// No description provided for @focus_sessionProgressReset.
  ///
  /// In en, this message translates to:
  /// **'Session Progress Reset'**
  String get focus_sessionProgressReset;

  /// No description provided for @focus_sessionNotLogged.
  ///
  /// In en, this message translates to:
  /// **'Session won\'t be logged in stats'**
  String get focus_sessionNotLogged;

  /// No description provided for @focus_treeWithered.
  ///
  /// In en, this message translates to:
  /// **'Focus Tree Withered'**
  String get focus_treeWithered;

  /// No description provided for @focus_growingTreeWillDie.
  ///
  /// In en, this message translates to:
  /// **'Your growing tree will die'**
  String get focus_growingTreeWillDie;

  /// No description provided for @focus_rankPointsDeducted.
  ///
  /// In en, this message translates to:
  /// **'Rank Points Deducted'**
  String get focus_rankPointsDeducted;

  /// No description provided for @focus_modePenalty.
  ///
  /// In en, this message translates to:
  /// **'{mode} mode penalty'**
  String focus_modePenalty(String mode);

  /// No description provided for @focus_dailyStreakRisk.
  ///
  /// In en, this message translates to:
  /// **'Daily Streak Risk'**
  String get focus_dailyStreakRisk;

  /// No description provided for @focus_streakResetTip.
  ///
  /// In en, this message translates to:
  /// **'Streak resets if no session today'**
  String get focus_streakResetTip;

  /// No description provided for @focus_wow.
  ///
  /// In en, this message translates to:
  /// **'Wow!'**
  String get focus_wow;

  /// No description provided for @focus_plantGrownUp.
  ///
  /// In en, this message translates to:
  /// **'The plant has grown up'**
  String get focus_plantGrownUp;

  /// No description provided for @focus_dayStreak.
  ///
  /// In en, this message translates to:
  /// **'{count}-Day Streak!'**
  String focus_dayStreak(int count);

  /// No description provided for @focus_plusOneToday.
  ///
  /// In en, this message translates to:
  /// **'+1 Today 🎉'**
  String get focus_plusOneToday;

  /// No description provided for @focus_haveARest.
  ///
  /// In en, this message translates to:
  /// **'Have a rest'**
  String get focus_haveARest;

  /// No description provided for @focus_plantDead.
  ///
  /// In en, this message translates to:
  /// **'Oh no, your plant is dead'**
  String get focus_plantDead;

  /// No description provided for @focus_restart.
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get focus_restart;

  /// No description provided for @focus_backToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get focus_backToHome;

  /// No description provided for @explore_title.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get explore_title;

  /// No description provided for @explore_todayFocus.
  ///
  /// In en, this message translates to:
  /// **'Today Focus'**
  String get explore_todayFocus;

  /// No description provided for @explore_allFocus.
  ///
  /// In en, this message translates to:
  /// **'All Focus'**
  String get explore_allFocus;

  /// No description provided for @explore_todayKill.
  ///
  /// In en, this message translates to:
  /// **'Today Kill'**
  String get explore_todayKill;

  /// No description provided for @explore_allKill.
  ///
  /// In en, this message translates to:
  /// **'All Kill'**
  String get explore_allKill;

  /// No description provided for @explore_avgFocusTime.
  ///
  /// In en, this message translates to:
  /// **'Average\nFocus time'**
  String get explore_avgFocusTime;

  /// No description provided for @explore_avgKillTime.
  ///
  /// In en, this message translates to:
  /// **'Average\nKill time'**
  String get explore_avgKillTime;

  /// No description provided for @explore_mins.
  ///
  /// In en, this message translates to:
  /// **'{count} mins'**
  String explore_mins(int count);

  /// No description provided for @explore_recentFocus.
  ///
  /// In en, this message translates to:
  /// **'Recent Focus'**
  String get explore_recentFocus;

  /// No description provided for @explore_dailyAverage.
  ///
  /// In en, this message translates to:
  /// **'Daily Average '**
  String get explore_dailyAverage;

  /// No description provided for @explore_noFocusDataWeek.
  ///
  /// In en, this message translates to:
  /// **'No focus data this week 🌿'**
  String get explore_noFocusDataWeek;

  /// No description provided for @explore_focusRecord.
  ///
  /// In en, this message translates to:
  /// **'Focus Record'**
  String get explore_focusRecord;

  /// No description provided for @explore_noFocusRecordsToday.
  ///
  /// In en, this message translates to:
  /// **'No focus records today'**
  String get explore_noFocusRecordsToday;

  /// No description provided for @explore_noFocusRecordsMonth.
  ///
  /// In en, this message translates to:
  /// **'No focus records in the last 30 days'**
  String get explore_noFocusRecordsMonth;

  /// No description provided for @explore_leaderboard.
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get explore_leaderboard;

  /// No description provided for @explore_noRankingsYet.
  ///
  /// In en, this message translates to:
  /// **'No Rankings Yet'**
  String get explore_noRankingsYet;

  /// No description provided for @explore_noRankingsDesc.
  ///
  /// In en, this message translates to:
  /// **'Be the first to complete a focus session and claim top spot!'**
  String get explore_noRankingsDesc;

  /// No description provided for @explore_you.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get explore_you;

  /// No description provided for @profile_title.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile_title;

  /// No description provided for @profile_myProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get profile_myProfile;

  /// No description provided for @profile_myPoints.
  ///
  /// In en, this message translates to:
  /// **'My Points'**
  String get profile_myPoints;

  /// No description provided for @profile_myActivities.
  ///
  /// In en, this message translates to:
  /// **'My activities'**
  String get profile_myActivities;

  /// No description provided for @profile_completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get profile_completed;

  /// No description provided for @profile_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get profile_failed;

  /// No description provided for @profile_noActivitiesFound.
  ///
  /// In en, this message translates to:
  /// **'No activities found'**
  String get profile_noActivitiesFound;

  /// No description provided for @profile_tryChangingFilters.
  ///
  /// In en, this message translates to:
  /// **'Try changing your filters or start a new focus session.'**
  String get profile_tryChangingFilters;

  /// No description provided for @profile_restoreStreak.
  ///
  /// In en, this message translates to:
  /// **'Restore Streak'**
  String get profile_restoreStreak;

  /// Streak recovery card title
  ///
  /// In en, this message translates to:
  /// **'Save Your {count}-Day Streak!'**
  String profile_saveYourStreak(int count);

  /// No description provided for @profile_recoverStreakDesc.
  ///
  /// In en, this message translates to:
  /// **'Recover your progress using a shield or coins.'**
  String get profile_recoverStreakDesc;

  /// No description provided for @profile_streakFreezeShield.
  ///
  /// In en, this message translates to:
  /// **'Streak Freeze Shield'**
  String get profile_streakFreezeShield;

  /// No description provided for @profile_availableShields.
  ///
  /// In en, this message translates to:
  /// **'Available: {count} shields'**
  String profile_availableShields(int count);

  /// No description provided for @profile_noShields.
  ///
  /// In en, this message translates to:
  /// **'No freeze shields in inventory'**
  String get profile_noShields;

  /// No description provided for @profile_useGoldCoins.
  ///
  /// In en, this message translates to:
  /// **'Use {cost} Gold Coins'**
  String profile_useGoldCoins(int cost);

  /// No description provided for @profile_coinBalance.
  ///
  /// In en, this message translates to:
  /// **'Balance: {balance} coins'**
  String profile_coinBalance(int balance);

  /// No description provided for @profile_needMoreCoinsTip.
  ///
  /// In en, this message translates to:
  /// **'You need more coins to restore. Complete focus sessions to earn Gold Coins!'**
  String get profile_needMoreCoinsTip;

  /// No description provided for @profile_logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get profile_logout;

  /// No description provided for @profile_logoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get profile_logoutConfirm;

  /// No description provided for @profile_displayName.
  ///
  /// In en, this message translates to:
  /// **'Display Name'**
  String get profile_displayName;

  /// No description provided for @profile_username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get profile_username;

  /// No description provided for @profile_countryRegion.
  ///
  /// In en, this message translates to:
  /// **'Country / Region'**
  String get profile_countryRegion;

  /// No description provided for @profile_updatingAvatar.
  ///
  /// In en, this message translates to:
  /// **'Updating avatar...'**
  String get profile_updatingAvatar;

  /// No description provided for @profile_avatarUpdated.
  ///
  /// In en, this message translates to:
  /// **'Avatar updated!'**
  String get profile_avatarUpdated;

  /// No description provided for @profile_uploadingAvatar.
  ///
  /// In en, this message translates to:
  /// **'Uploading avatar...'**
  String get profile_uploadingAvatar;

  /// No description provided for @profile_avatarUploaded.
  ///
  /// In en, this message translates to:
  /// **'Avatar uploaded!'**
  String get profile_avatarUploaded;

  /// No description provided for @profile_failedUpdateAvatar.
  ///
  /// In en, this message translates to:
  /// **'Failed to update avatar'**
  String get profile_failedUpdateAvatar;

  /// No description provided for @profile_failedUploadAvatar.
  ///
  /// In en, this message translates to:
  /// **'Failed to upload avatar'**
  String get profile_failedUploadAvatar;

  /// No description provided for @profile_profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated!'**
  String get profile_profileUpdated;

  /// No description provided for @profile_failedUpdateProfile.
  ///
  /// In en, this message translates to:
  /// **'Failed to update profile'**
  String get profile_failedUpdateProfile;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
