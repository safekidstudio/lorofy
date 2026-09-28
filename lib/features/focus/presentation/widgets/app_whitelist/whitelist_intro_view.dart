import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:lorofy/components/layout/app_header.dart';
import 'package:lorofy/components/ui/button.dart';
import 'package:lorofy/components/ui/svg_asset.dart';
import 'package:lorofy/core/theme/app_theme.dart';

class WhitelistIntroView extends StatelessWidget {
  final VoidCallback onSelectApps;
  final VoidCallback onReset;
  final bool isResetDisabled;
  final VoidCallback onClose;

  const WhitelistIntroView({
    super.key,
    required this.onSelectApps,
    required this.onReset,
    required this.isResetDisabled,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppHeader(
          leftActions: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: onClose,
            child: const SVG(
              'assets/icons/cancel.svg',
              width: 20,
              height: 20,
            ),
          ),
          title: 'Set whitelist apps',
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppPadding.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppPadding.lg),
                Center(
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary,
                      border: Border.all(color: AppColors.card, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: CupertinoColors.black.withValues(alpha: 0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const ClipOval(
                      child: Center(
                        child: Icon(
                          CupertinoIcons.square_grid_2x2_fill,
                          size: 54,
                          color: AppColors.secondary,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                if (defaultTargetPlatform == TargetPlatform.android) ...[
                  const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '• ',
                        style: TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 13,
                          color: AppColors.mutedForeground,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'On Android, Lorofy requires Usage Access permission to recognize when you enter your Whitelisted apps.',
                          style: TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 13,
                            height: 1.4,
                            color: AppColors.mutedForeground,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppPadding.md),
                  const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '• ',
                        style: TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 13,
                          color: AppColors.mutedForeground,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Whitelisted apps (e.g., Dictionary, Music, Work apps) can be opened during focus sessions without failing your session.',
                          style: TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 13,
                            height: 1.4,
                            color: AppColors.mutedForeground,
                          ),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '• ',
                        style: TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 13,
                          color: AppColors.mutedForeground,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Due to iOS system limitations, certain system apps (e.g., Messages, Phone, etc.) cannot be disabled!',
                          style: TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 13,
                            height: 1.4,
                            color: AppColors.mutedForeground,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppPadding.md),
                  const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '• ',
                        style: TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 13,
                          color: AppColors.mutedForeground,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'When choosing apps, it\'s recommended not to exceed 20, and avoid selecting categories (e.g., Social, Entertainment, etc.), as it may lead to disabling failure.',
                          style: TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 13,
                            height: 1.4,
                            color: AppColors.mutedForeground,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 32),
                Button.primary(
                  text: 'Select allow apps',
                  onPressed: onSelectApps,
                ),
                const SizedBox(height: AppPadding.sm),
                Button.secondary(
                  text: 'Reset',
                  disabled: isResetDisabled,
                  onPressed: onReset,
                ),
                const Spacer(),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppPadding.lg,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 13,
                          color: AppColors.mutedForeground,
                        ),
                        children: [
                          TextSpan(text: 'Unsuccessful? Try 👈 '),
                          TextSpan(
                            text: 'manual disable',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.foreground,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppPadding.lg),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
