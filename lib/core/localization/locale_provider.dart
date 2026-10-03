import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lorofy/l10n/generated/app_localizations.dart';

part 'locale_provider.g.dart';

const String _kLocaleKey = 'selected_locale_code';

/// Riverpod provider for active app Locale.
/// Pure and dynamic: 100% driven by Flutter's generated AppLocalizations.supportedLocales!
@Riverpod(keepAlive: true)
class AppLocale extends _$AppLocale {
  @override
  Locale? build() {
    _loadSavedLocale();
    return null; // System default initially
  }

  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_kLocaleKey);
    if (code != null && code.isNotEmpty) {
      final isSupported = AppLocalizations.supportedLocales
          .any((locale) => locale.languageCode == code);
      if (isSupported) {
        state = Locale(code);
        return;
      }
    }
    state = null; // System default fallback
  }

  Future<void> setLocale(Locale? locale) async {
    state = locale;
    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      await prefs.remove(_kLocaleKey);
    } else {
      await prefs.setString(_kLocaleKey, locale.languageCode);
    }
  }
}
