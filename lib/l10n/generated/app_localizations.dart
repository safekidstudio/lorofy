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
