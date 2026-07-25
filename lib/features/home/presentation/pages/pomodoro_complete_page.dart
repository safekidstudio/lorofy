import 'package:flutter/cupertino.dart';
import 'package:lorofy/components/ui/app_header.dart';
import 'package:lorofy/components/ui/button.dart';
import 'package:lorofy/components/ui/svg_asset.dart';
import 'package:lorofy/core/theme/app_theme.dart';
import 'package:rive/rive.dart';

class PomodoroCompletePage extends StatelessWidget {
  final VoidCallback onBackToHome;
  final VoidCallback onHaveARest;

  const PomodoroCompletePage({
    super.key,
    required this.onBackToHome,
    required this.onHaveARest,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Rive Confetti falling in the background
        const Positioned.fill(
          child: RiveAnimation.asset(
            'assets/river/confetti.riv',
            fit: BoxFit.cover,
          ),
        ),
        
        // Main content column
        Positioned.fill(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // AppHeader with close button
              AppHeader(
                leftActions: CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: onBackToHome,
                  child: const Icon(
                    CupertinoIcons.xmark,
                    color: Color(0xFF232321),
                    size: 24,
                  ),
                ),
              ),
              const Spacer(),
              
              // Success checkmark illustration
              Center(
                child: const SVG(
                  'assets/illustrations/success_checkmark.svg',
                  width: 220,
                  height: 220,
                ),
              ),
              const SizedBox(height: 48),

              // Subtitle Text
              const Text(
                'Wow!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppTextStyles.titleFontFamily,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF232321),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'The plant has grown up',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF8E8E93),
                ),
              ),
              const Spacer(),

              // Have a Rest Button
              Center(
                child: SizedBox(
                  width: 180,
                  child: Button.secondary(
                    text: 'Have a rest',
                    onPressed: onHaveARest,
                  ),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ],
    );
  }
}
