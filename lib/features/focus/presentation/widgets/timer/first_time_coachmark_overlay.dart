import 'package:flutter/cupertino.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:lorofy/components/ui/button.dart';
import 'package:lorofy/components/ui/svg_asset.dart';
import 'package:lorofy/core/theme/app_theme.dart';

/// Reusable Tooltip Card rendered inside TutorialCoachMark target content
class CoachmarkTooltipCard extends StatelessWidget {
  final String title;
  final String stepText;
  final String stepProgress;
  final String description;
  final String buttonText;
  final VoidCallback onNext;
  final VoidCallback? onSkip;

  const CoachmarkTooltipCard({
    super.key,
    required this.title,
    required this.stepText,
    required this.stepProgress,
    required this.description,
    required this.buttonText,
    required this.onNext,
    this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withValues(alpha: 0.2),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const SVG(
                      'assets/icons/info.svg',
                      width: 14,
                      height: 14,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      stepText,
                      style: const TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Text(
                    stepProgress,
                    style: const TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.mutedForeground,
                    ),
                  ),
                  if (onSkip != null) ...[
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: onSkip,
                      child: const Text(
                        'Skip',
                        style: TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.mutedForeground,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontFamily: AppTextStyles.titleFontFamily,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.foreground,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: const TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 13,
              height: 1.4,
              color: AppColors.mutedForeground,
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: Button.primary(
              text: buttonText,
              onPressed: onNext,
            ),
          ),
        ],
      ),
    );
  }
}

/// Dynamic Coachmark Tour trigger function for Home (QuickStartPage)
void showFirstTimeCoachmarkTour({
  required BuildContext context,
  required GlobalKey settingsKey,
  required GlobalKey startButtonKey,
  required VoidCallback onFinish,
}) {
  late TutorialCoachMark tutorialCoachMark;

  final targets = <TargetFocus>[
    TargetFocus(
      identify: "settings_step",
      keyTarget: settingsKey,
      alignSkip: Alignment.topRight,
      shape: ShapeLightFocus.Circle,
      radius: 10,
      contents: [
        TargetContent(
          align: ContentAlign.bottom,
          builder: (context, controller) {
            return CoachmarkTooltipCard(
              title: 'Customize Session ⚙️',
              stepText: 'STEP 1',
              stepProgress: '1 / 2',
              description:
                  'Tap the Gear icon to set Timer duration, Ambient Sounds, and Strict Mode.',
              buttonText: 'Next ➜',
              onNext: () => controller.next(),
              onSkip: () => controller.skip(),
            );
          },
        ),
      ],
    ),
    TargetFocus(
      identify: "start_step",
      keyTarget: startButtonKey,
      alignSkip: Alignment.topRight,
      shape: ShapeLightFocus.RRect,
      radius: 16,
      contents: [
        TargetContent(
          align: ContentAlign.top,
          builder: (context, controller) {
            return CoachmarkTooltipCard(
              title: 'Ready to Focus? 🚀',
              stepText: 'STEP 2',
              stepProgress: '2 / 2',
              description:
                  'Tap START to launch your first session, earn coins, and level up Lorofy!',
              buttonText: 'Get Started 🚀',
              onNext: () => controller.next(),
              onSkip: () => controller.skip(),
            );
          },
        ),
      ],
    ),
  ];

  tutorialCoachMark = TutorialCoachMark(
    targets: targets,
    colorShadow: CupertinoColors.black,
    opacityShadow: 0.75,
    paddingFocus: 8,
    hideSkip: true,
    onFinish: onFinish,
    onSkip: () {
      onFinish();
      return true;
    },
  );

  tutorialCoachMark.show(context: context);
}

/// Dynamic Coachmark Tour trigger function for Session Settings Page
void showSessionSettingsCoachmarkTour({
  required BuildContext context,
  required GlobalKey pomodoroModeKey,
  required GlobalKey durationKey,
  required GlobalKey tagKey,
  required GlobalKey blockModeKey,
  required VoidCallback onFinish,
}) {
  late TutorialCoachMark tutorialCoachMark;

  final targets = <TargetFocus>[
    // Step 1: Pomodoro Mode
    TargetFocus(
      identify: "pomodoro_mode_step",
      keyTarget: pomodoroModeKey,
      alignSkip: Alignment.topRight,
      shape: ShapeLightFocus.RRect,
      radius: 16,
      contents: [
        TargetContent(
          align: ContentAlign.bottom,
          builder: (context, controller) {
            return CoachmarkTooltipCard(
              title: 'Pomodoro Mode ⏳',
              stepText: 'STEP 1',
              stepProgress: '1 / 4',
              description:
                  'Enable Pomodoro mode to divide study sessions into focus rounds & rest breaks.',
              buttonText: 'Next ➜',
              onNext: () => controller.next(),
              onSkip: () => controller.skip(),
            );
          },
        ),
      ],
    ),
    // Step 2: Time Duration Slider
    TargetFocus(
      identify: "duration_step",
      keyTarget: durationKey,
      alignSkip: Alignment.topRight,
      shape: ShapeLightFocus.RRect,
      radius: 16,
      contents: [
        TargetContent(
          align: ContentAlign.bottom,
          builder: (context, controller) {
            return CoachmarkTooltipCard(
              title: 'Focus Duration ⏱️',
              stepText: 'STEP 2',
              stepProgress: '2 / 4',
              description:
                  'Drag the slider to adjust your focus time per session (e.g. 25m or 50m).',
              buttonText: 'Next ➜',
              onNext: () => controller.next(),
              onSkip: () => controller.skip(),
            );
          },
        ),
      ],
    ),
    // Step 3: Tag / Category
    TargetFocus(
      identify: "tag_step",
      keyTarget: tagKey,
      alignSkip: Alignment.topRight,
      shape: ShapeLightFocus.RRect,
      radius: 16,
      contents: [
        TargetContent(
          align: ContentAlign.top,
          builder: (context, controller) {
            return CoachmarkTooltipCard(
              title: 'Activity Tag 🏷️',
              stepText: 'STEP 3',
              stepProgress: '3 / 4',
              description:
                  'Select a tag like Study, Work, or Reading to organize your statistics.',
              buttonText: 'Next ➜',
              onNext: () => controller.next(),
              onSkip: () => controller.skip(),
            );
          },
        ),
      ],
    ),
    // Step 4: Block Mode (Strict Mode)
    TargetFocus(
      identify: "block_mode_step",
      keyTarget: blockModeKey,
      alignSkip: Alignment.topRight,
      shape: ShapeLightFocus.RRect,
      radius: 16,
      contents: [
        TargetContent(
          align: ContentAlign.top,
          builder: (context, controller) {
            return CoachmarkTooltipCard(
              title: 'Block Mode 🔒',
              stepText: 'STEP 4',
              stepProgress: '4 / 4',
              description:
                  'Choose Strict Mode or Medium Mode to block distracting apps while focusing.',
              buttonText: 'Got it! 🚀',
              onNext: () => controller.next(),
              onSkip: () => controller.skip(),
            );
          },
        ),
      ],
    ),
  ];

  tutorialCoachMark = TutorialCoachMark(
    targets: targets,
    colorShadow: CupertinoColors.black,
    opacityShadow: 0.75,
    paddingFocus: 8,
    hideSkip: true,
    onFinish: onFinish,
    onSkip: () {
      onFinish();
      return true;
    },
  );

  tutorialCoachMark.show(context: context);
}
