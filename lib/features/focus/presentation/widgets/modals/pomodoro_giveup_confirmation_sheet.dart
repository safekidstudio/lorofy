import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lorofy/components/ui/button.dart';
import 'package:lorofy/core/theme/app_theme.dart';
import 'package:lorofy/features/focus/domain/enums/block_mode.dart';
import 'package:lorofy/features/focus/presentation/providers/pomodoro_notifier.dart';
import 'package:lorofy/features/focus/presentation/providers/pomodoro_settings.dart';
import 'package:lorofy/features/settings/presentation/providers/system_settings_provider.dart';

import 'package:lorofy/core/localization/l10n_extension.dart';

class PomodoroGiveupConfirmationSheet extends ConsumerWidget {
  const PomodoroGiveupConfirmationSheet({super.key});

  static const List<String> _roastMessages = [
    'Focusing is literally the easiest thing... and you can\'t even do that?',
    'Your tree believed in you. Look what you\'re about to do to it.',
    'Even a cat has more discipline than this...',
    'Quitting already? That was embarrassingly fast.',
    'Your future self is watching. And judging. Hard.',
    'The phone won. Again. Congrats.',
    'You were SO close to proving you have willpower. Almost.',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final timerState = ref.watch(pomodoroTimerProvider);
    final settings = ref.watch(pomodoroSettingsProvider);
    final systemSettings = ref.watch(systemSettingsProvider);

    final elapsedSeconds =
        timerState.totalSessionSeconds - timerState.countdownSeconds;
    final isGracePeriod = elapsedSeconds < 60;

    final isStrict = settings.blockMode == BlockMode.strict;
    final penaltyPoints = isStrict
        ? systemSettings.penaltyPointsStrict
        : systemSettings.penaltyPointsMedium;

    final roastMessage =
        _roastMessages[Random().nextInt(_roastMessages.length)];

    final cardBgColor = CupertinoDynamicColor.resolve(
      AppColors.background,
      context,
    );

    final cardBorderColor = CupertinoDynamicColor.resolve(
      AppColors.border,
      context,
    );

    final dividerColor = CupertinoDynamicColor.resolve(
      AppColors.border,
      context,
    );

    final iconBgColor = CupertinoDynamicColor.resolve(AppColors.input, context);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppPadding.xl,
        vertical: AppPadding.lg,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: cardBorderColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Kungfu cat GIF
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: Image.asset(
                  'assets/animations/kungfu.gif',
                  width: 130,
                  height: 130,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        color: iconBgColor,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: const Center(
                        child: Text('🐱', style: TextStyle(fontSize: 48)),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              isGracePeriod
                  ? l10n.focus_cancelSessionConfirmTitle
                  : l10n.focus_giveUpConfirmTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: AppTextStyles.titleFontFamily,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.foreground,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 6),

            // Subtitle / Roast
            Text(
              isGracePeriod ? l10n.focus_gracePeriodDesc : roastMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.mutedForeground,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 20),

            // Grouped Details Card (Minimal Black & White Monochrome Style)
            Container(
              decoration: BoxDecoration(
                color: cardBgColor,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: cardBorderColor, width: 1),
              ),
              child: Column(
                children: isGracePeriod
                    ? [
                        _CardRowItem(
                          icon: CupertinoIcons.shield_fill,
                          iconBgColor: iconBgColor,
                          iconColor: AppColors.foreground,
                          title: l10n.focus_gracePeriodProtection,
                          subtitle: l10n.focus_noPointsDeducted,
                          badgeText: '0 pts',
                          badgeBgColor: iconBgColor,
                          badgeTextColor: AppColors.foreground,
                        ),
                        _CardDivider(color: dividerColor),
                        _CardRowItem(
                          icon: CupertinoIcons.arrow_counterclockwise,
                          iconBgColor: iconBgColor,
                          iconColor: AppColors.foreground,
                          title: l10n.focus_sessionProgressReset,
                          subtitle: l10n.focus_sessionNotLogged,
                        ),
                      ]
                    : [
                        _CardRowItem(
                          icon: CupertinoIcons.leaf_arrow_circlepath,
                          iconBgColor: iconBgColor,
                          iconColor: AppColors.foreground,
                          title: l10n.focus_treeWithered,
                          subtitle: l10n.focus_growingTreeWillDie,
                        ),
                        _CardDivider(color: dividerColor),
                        _CardRowItem(
                          icon: CupertinoIcons.minus_circle_fill,
                          iconBgColor: iconBgColor,
                          iconColor: AppColors.foreground,
                          title: l10n.focus_rankPointsDeducted,
                          subtitle: l10n.focus_modePenalty(
                            isStrict
                                ? l10n.focus_strictMode
                                : l10n.focus_mediumMode,
                          ),
                          badgeText: '-$penaltyPoints pts',
                          badgeBgColor: iconBgColor,
                          badgeTextColor: AppColors.foreground,
                        ),
                        _CardDivider(color: dividerColor),
                        _CardRowItem(
                          icon: CupertinoIcons.flame_fill,
                          iconBgColor: iconBgColor,
                          iconColor: AppColors.foreground,
                          title: l10n.focus_dailyStreakRisk,
                          subtitle: l10n.focus_streakResetTip,
                        ),
                      ],
              ),
            ),

            const SizedBox(height: 24),

            // Primary action — Keep Going
            Button.primary(
              text: l10n.focus_keepGoing,
              onPressed: () => Navigator.pop(context, false),
            ),
            const SizedBox(height: 10),
            // Ghost action — Give up / Cancel
            Button.ghost(
              text: isGracePeriod
                  ? l10n.focus_cancelSessionBtn
                  : l10n.focus_giveUpBtn,
              onPressed: () => Navigator.pop(context, true),
              textStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: AppColors.mutedForeground,
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _CardRowItem extends StatelessWidget {
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String? badgeText;
  final Color? badgeBgColor;
  final Color? badgeTextColor;

  const _CardRowItem({
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.badgeText,
    this.badgeBgColor,
    this.badgeTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.foreground,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.mutedForeground,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          if (badgeText != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color:
                    badgeBgColor ??
                    CupertinoDynamicColor.resolve(AppColors.muted, context),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Text(
                badgeText!,
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: badgeTextColor ?? AppColors.foreground,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CardDivider extends StatelessWidget {
  final Color color;

  const _CardDivider({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 14),
      color: color,
    );
  }
}
