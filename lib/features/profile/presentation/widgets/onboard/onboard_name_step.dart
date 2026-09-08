import 'package:flutter/cupertino.dart';
import 'package:lorofy/components/ui/input.dart';
import 'package:lorofy/components/ui/svg_asset.dart';
import 'package:lorofy/core/theme/app_theme.dart';

class OnboardNameStep extends StatelessWidget {
  final bool isDisabled;

  const OnboardNameStep({
    super.key,
    required this.isDisabled,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Text('Create your username', style: AppTextStyles.titleLarge),
        const SizedBox(height: 8),
        Text(
          'Choose a unique display name for your profile',
          style: AppTextStyles.body.copyWith(
            color: AppColors.mutedForeground,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 48),
        Input(
          placeholder: 'user.example',
          formControlName: 'displayName',
          disabled: isDisabled,
          prefix: Container(
            padding: const EdgeInsets.all(4),
            child: const SVG(
              'assets/icons/at-symbol.svg',
              height: 24,
              width: 24,
            ),
          ),
        ),
      ],
    );
  }
}
