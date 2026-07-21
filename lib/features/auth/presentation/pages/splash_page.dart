import 'package:flutter/cupertino.dart';
import 'package:lorofy/components/ui/loader.dart';
import 'package:lorofy/components/ui/logo.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFF9F9FB), // Matches the new onboarding light premium background
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(), // Pushes the center group to the middle
            // Animated Logo & App Title
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.scale(
                    scale: 0.9 + (value * 0.1), // Subtle scale-up from 0.9x to 1.0x
                    child: child,
                  ),
                );
              },
              child: const Logo(fontSize: 54),
            ),
            const Spacer(), // Pushes the loader towards the bottom area
            // Rotating brand SVG loader component
            const Loader(
              size: 24,
              color: Color(0xFF232321),
            ),
            const SizedBox(
              height: 60,
            ), // Safe area distance from bottom edge
          ],
        ),
      ),
    );
  }
}
