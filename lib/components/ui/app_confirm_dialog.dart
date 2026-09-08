import 'package:flutter/cupertino.dart';
import 'package:lorofy/components/ui/button.dart';
import 'package:lorofy/core/theme/app_theme.dart';

/// A reusable confirm dialog with a clean card style and drawing-style
/// buttons (via [Button] component).
///
/// Usage:
/// ```dart
/// AppConfirmDialog.show(
///   context: context,
///   title: 'Logout',
///   message: 'Are you sure you want to log out?',
///   confirmLabel: 'Logout',
///   isDestructive: true,
///   onConfirm: () { /* your action */ },
/// );
/// ```
class AppConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final bool isDestructive;

  const AppConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.onConfirm,
    this.cancelLabel = 'Cancel',
    this.onCancel,
    this.isDestructive = false,
  });

  /// Convenience static method to show the dialog from any context.
  static Future<void> show({
    required BuildContext context,
    required String title,
    required String message,
    required String confirmLabel,
    required VoidCallback onConfirm,
    String cancelLabel = 'Cancel',
    VoidCallback? onCancel,
    bool isDestructive = false,
  }) {
    return showCupertinoDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => AppConfirmDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        onConfirm: onConfirm,
        onCancel: onCancel,
        isDestructive: isDestructive,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          width: 320,
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          decoration: BoxDecoration(
            color: CupertinoColors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0x26000000),
                blurRadius: 24,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: AppTextStyles.titleFontFamily,
                  fontSize: 22,
                  color: Color(0xFF232321),
                  decoration: TextDecoration.none,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 10),
              // Message
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 14,
                  color: AppColors.mutedForeground,
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(height: 20),
              // Buttons row
              Row(
                children: [
                  Expanded(
                    child: Button.secondary(
                      text: cancelLabel,
                      onPressed: () {
                        Navigator.pop(context);
                        onCancel?.call();
                      },
                      textStyle: const TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: isDestructive
                        ? Button.destructive(
                            text: confirmLabel,
                            onPressed: () {
                              Navigator.pop(context);
                              onConfirm();
                            },
                            textStyle: const TextStyle(
                              fontFamily: AppTextStyles.fontFamily,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        : Button.primary(
                            text: confirmLabel,
                            onPressed: () {
                              Navigator.pop(context);
                              onConfirm();
                            },
                            textStyle: const TextStyle(
                              fontFamily: AppTextStyles.fontFamily,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
