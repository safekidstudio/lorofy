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
/// import 'l10n/app_localizations.dart';
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

  /// The name of the application
  ///
  /// In en, this message translates to:
  /// **'Lorofy'**
  String get appName;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @appPreferences.
  ///
  /// In en, this message translates to:
  /// **'APP PREFERENCES'**
  String get appPreferences;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'NOTIFICATIONS'**
  String get notifications;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageVietnamese.
  ///
  /// In en, this message translates to:
  /// **'Vietnamese'**
  String get languageVietnamese;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get languageSystem;

  /// No description provided for @pomodoroRules.
  ///
  /// In en, this message translates to:
  /// **'Pomodoro Rules'**
  String get pomodoroRules;

  /// No description provided for @appBlockerRules.
  ///
  /// In en, this message translates to:
  /// **'App Blocker Rules'**
  String get appBlockerRules;

  /// No description provided for @focusReminders.
  ///
  /// In en, this message translates to:
  /// **'Focus Reminders'**
  String get focusReminders;

  /// No description provided for @focusRemindersDescription.
  ///
  /// In en, this message translates to:
  /// **'Remind before session starts'**
  String get focusRemindersDescription;

  /// No description provided for @restoreStreak.
  ///
  /// In en, this message translates to:
  /// **'Restore Streak'**
  String get restoreStreak;

  /// Streak restoration title
  ///
  /// In en, this message translates to:
  /// **'Save Your {count}-Day Streak!'**
  String saveYourStreak(int count);

  /// No description provided for @recoverStreakDescription.
  ///
  /// In en, this message translates to:
  /// **'Recover your progress using a shield or coins.'**
  String get recoverStreakDescription;

  /// No description provided for @streakFreezeShield.
  ///
  /// In en, this message translates to:
  /// **'Streak Freeze Shield'**
  String get streakFreezeShield;

  /// No description provided for @availableShields.
  ///
  /// In en, this message translates to:
  /// **'Available: {count} shields'**
  String availableShields(int count);

  /// No description provided for @noShields.
  ///
  /// In en, this message translates to:
  /// **'No freeze shields in inventory'**
  String get noShields;

  /// No description provided for @useGoldCoins.
  ///
  /// In en, this message translates to:
  /// **'Use {cost} Gold Coins'**
  String useGoldCoins(int cost);

  /// No description provided for @coinBalance.
  ///
  /// In en, this message translates to:
  /// **'Balance: {balance} coins'**
  String coinBalance(int balance);

  /// No description provided for @focusNowToEarn.
  ///
  /// In en, this message translates to:
  /// **'Focus Now to Earn Coins 🎯'**
  String get focusNowToEarn;

  /// No description provided for @needMoreCoinsTip.
  ///
  /// In en, this message translates to:
  /// **'You need more coins to restore. Complete focus sessions to earn Gold Coins!'**
  String get needMoreCoinsTip;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @strictMode.
  ///
  /// In en, this message translates to:
  /// **'Strict Mode'**
  String get strictMode;

  /// No description provided for @mediumMode.
  ///
  /// In en, this message translates to:
  /// **'Medium Mode'**
  String get mediumMode;

  /// No description provided for @mediumModeDescription.
  ///
  /// In en, this message translates to:
  /// **'In focus, only whitelisted apps can be opened'**
  String get mediumModeDescription;

  /// No description provided for @strictModeDescription.
  ///
  /// In en, this message translates to:
  /// **'In focus, opening other apps kill the plant'**
  String get strictModeDescription;

  /// No description provided for @selectAllowedApps.
  ///
  /// In en, this message translates to:
  /// **'Select allowed apps'**
  String get selectAllowedApps;

  /// No description provided for @myActivities.
  ///
  /// In en, this message translates to:
  /// **'My activities'**
  String get myActivities;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @week.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get week;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @failed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get failed;

  /// No description provided for @noActivitiesFound.
  ///
  /// In en, this message translates to:
  /// **'No activities found'**
  String get noActivitiesFound;

  /// No description provided for @tryChangingFilters.
  ///
  /// In en, this message translates to:
  /// **'Try changing your filters or start a new focus session.'**
  String get tryChangingFilters;
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
