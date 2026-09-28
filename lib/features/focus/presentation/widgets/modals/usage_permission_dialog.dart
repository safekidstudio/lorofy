import 'package:flutter/cupertino.dart';
import 'package:lorofy/core/services/foreground_app_service.dart';
import 'package:lorofy/core/theme/app_theme.dart';

/// Shows a user-friendly dialog explaining why Usage Access permission is needed
/// before redirecting to Android system settings.
Future<bool> showUsagePermissionDialog(BuildContext context) async {
  final result = await showCupertinoDialog<bool>(
    context: context,
    builder: (context) => CupertinoAlertDialog(
      title: const Padding(
        padding: EdgeInsets.only(bottom: 6.0),
        child: Text(
          'Usage Access Required 🌿',
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      content: const Text(
        'To recognize when you enter your Whitelisted apps (e.g. Dictionary, Music) without failing your focus session, Lorofy needs Usage Access permission in Android Settings.',
        style: TextStyle(
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
          onPressed: () {
            ForegroundAppService().requestUsagePermission();
            Navigator.pop(context, true);
          },
          child: const Text('Grant Access'),
        ),
      ],
    ),
  );

  return result ?? false;
}
