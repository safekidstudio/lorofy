import 'package:flutter/cupertino.dart';
import 'package:lorofy/components/layout/app_header.dart';
import 'package:lorofy/components/ui/button.dart';
import 'package:lorofy/components/ui/svg_asset.dart';
import 'package:lorofy/core/theme/app_theme.dart';

class PomodoroGiveupPage extends StatelessWidget {
  final VoidCallback onBackToHome;
  final VoidCallback onRestart;

  const PomodoroGiveupPage({
    super.key,
    required this.onBackToHome,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // AppHeader with lorofy logo and right action placeholder
          AppHeader(
            rightActions: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: onBackToHome,
              child: const Icon(
                CupertinoIcons.multiply,
                color: Color(0xFF232321),
                size: 24,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(),

                  // Dead/withered plant illustration
                  Center(
                    child: const SVG(
                      'assets/illustrations/dead_plant.svg',
                      width: 240,
                      height: 240,
                    ),
                  ),

                  // Subtitle
                  const Text(
                    'Oh no, your plant is dead',
                    textAlign: TextAlign.center,

                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF00160A),
                    ),
                  ),
                  const Spacer(),

                  // Restart Button with reload icon
                  Center(
                    child: SizedBox(
                      width: 180,
                      child: Button.secondary(
                        text: 'Restart',
                        prefix: const Icon(
                          CupertinoIcons.refresh,
                          size: 16,
                          color: Color(0xFF232321),
                        ),
                        onPressed: onRestart,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Back to home Link Button
                  Center(
                    child: Button.ghost(
                      text: 'Back to Home',
                      onPressed: onBackToHome,
                      textStyle: const TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
