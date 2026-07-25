import 'package:flutter/cupertino.dart';
import 'package:lorofy/components/ui/button.dart';
import 'package:lorofy/components/ui/svg_asset.dart';
import 'package:lorofy/core/theme/app_theme.dart';

class PomodoroGiveupConfirmationSheet extends StatelessWidget {
  const PomodoroGiveupConfirmationSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min, // Dynamically wrap height around content
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle at the top
            Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E5EA),
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Mockup Title Text
            const Text(
              'Do you want give up\nthis session?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTextStyles.titleFontFamily,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF232321),
                height: 1.2,
              ),
            ),
            const SizedBox(height: 24),

            // Cat knocking over coffee SVG illustration (assets/illustrations/overview.svg)
            Center(
              child: const SVG(
                'assets/illustrations/overview.svg',
                width: 180,
                height: 180,
              ),
            ),
            const SizedBox(height: 32),

            // Actions
            Row(
              children: [
                Expanded(
                  child: Button.primary(
                    text: 'Give up',
                    onPressed: () => Navigator.pop(context, true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Button.secondary(
                    text: 'Cancel',
                    onPressed: () => Navigator.pop(context, false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
