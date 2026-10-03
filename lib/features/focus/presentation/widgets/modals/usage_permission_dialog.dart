import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:lorofy/core/services/foreground_app_service.dart';
import 'package:lorofy/core/services/ios_family_controls_service.dart';
import 'package:lorofy/core/theme/app_theme.dart';

/// Shows a user-friendly dialog explaining why permission is needed
/// before requesting Android Usage Access or iOS Screen Time Permission.
Future<bool> showUsagePermissionDialog(BuildContext context) async {
  final isIOS = defaultTargetPlatform == TargetPlatform.iOS;

  final result = await showCupertinoDialog<bool>(
    context: context,
    builder: (context) => CupertinoAlertDialog(
      title: Padding(
        padding: const EdgeInsets.only(bottom: 6.0),
        child: Text(
          isIOS ? 'Screen Time Access Required 🌿' : 'Usage Access Required 🌿',
          style: const TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      content: Text(
        isIOS
            ? 'To allow Whitelisted apps during focus sessions and shield unallowed apps, Lorofy needs Screen Time permission on iOS.'
            : 'To recognize when you enter your Whitelisted apps (e.g. Dictionary, Music) without failing your focus session, Lorofy needs Usage Access permission in Android Settings.',
        style: const TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          fontSize: 13,
          height: 1.35,
        ),
      ),
      actions: [
        CupertinoDialogAction(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        CupertinoDialogAction(
          isDefaultAction: true,
          onPressed: () async {
            if (isIOS) {
              final granted = await IOSFamilyControlsService().requestAuthorization();
              if (context.mounted) {
                Navigator.pop(context, granted);
              }
            } else {
              await ForegroundAppService().requestUsagePermission();
              if (context.mounted) {
                Navigator.pop(context, true);
              }
            }
          },
          child: const Text('Grant Access'),
        ),
      ],
    ),
  );

  return result ?? false;
}
