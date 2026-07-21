import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lorofy/components/ui/button.dart';
import 'package:lorofy/components/ui/logo.dart';
import 'package:lorofy/components/ui/page_wrapper.dart';
import 'package:lorofy/core/theme/app_theme.dart';

class OverviewPage extends StatelessWidget {
  const OverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
              // 1. Logo "lorofy." top-left
              const Align(
                alignment: Alignment.centerLeft,
                child: Logo(fontSize: 28),
              ),
              const Spacer(flex: 2),

              // 2. Illustration in the center
              Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.sizeOf(context).height * 0.35,
                  ),
                  child: SvgPicture.asset(
                    'assets/illustrations/overview.svg',
                    fit: BoxFit.contain,
                    placeholderBuilder: (BuildContext context) =>
                        const CupertinoActivityIndicator(),
                  ),
                ),
              ),
              const Spacer(flex: 3),

              // 3. Heading: Welcome to Lorofy
              Text(
                'Welcome to Lorofy',
                style: TextStyle(
                  fontFamily: AppTextStyles.titleFontFamily,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF232321),
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // 4. Subtitle description
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Every second you focus with Lorofy is a step toward growth.',
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF8E8E93),
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const Spacer(flex: 3),

              // 5. Drawing style action buttons
              Button.primary(
                text: 'Login',
                onPressed: () => context.push('/login'),
              ),
              const SizedBox(height: 16),
              Button.secondary(
                text: 'Sign up',
                onPressed: () => context.push('/register'),
              ),
              const SizedBox(height: 12),
            ],
          ),
    );
  }
}
