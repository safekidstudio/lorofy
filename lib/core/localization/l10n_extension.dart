import 'package:flutter/widgets.dart';
import 'package:lorofy/l10n/generated/app_localizations.dart';

/// Extension helper to conveniently access AppLocalizations from BuildContext:
/// Usage: `context.l10n.settings` instead of `AppLocalizations.of(context).settings`
extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
