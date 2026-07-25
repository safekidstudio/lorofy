import 'package:flutter/cupertino.dart';
import 'package:lorofy/components/ui/app_header.dart';
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
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
            const Spacer(),

            // Dead/withered plant illustration
            Center(
              child: const SVG(
                'assets/illustrations/dead_plant.svg',
                width: 220,
                height: 220,
              ),
            ),
            const SizedBox(height: 48),

            // Subtitle
            const Text(
              'Oh no, your plant is dead',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 16,
                fontWeight: FontWeight.bold,
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
            const SizedBox(height: 16),

            // Back to home Link Button
            Center(
              child: Button.link(
                text: 'Back to home',
                onPressed: onBackToHome,
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
