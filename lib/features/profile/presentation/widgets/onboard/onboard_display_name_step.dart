import 'package:flutter/cupertino.dart';
import 'package:lorofy/components/ui/input.dart';
import 'package:lorofy/components/ui/svg_asset.dart';
import 'package:lorofy/core/theme/app_theme.dart';

class OnboardDisplayNameStep extends StatelessWidget {
  final bool isDisabled;

  const OnboardDisplayNameStep({super.key, required this.isDisabled});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Set your Display Name', style: AppTextStyles.titleLarge),
        const SizedBox(height: 8),
        Text(
          'This public name will be displayed on the Leaderboard and focus sessions.',
          style: AppTextStyles.body.copyWith(
            color: AppColors.mutedForeground,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 36),
        Input(
          placeholder: 'Display Name',
          formControlName: 'displayName',
          maxLength: 30,
          disabled: isDisabled,
          prefix: Container(
            padding: const EdgeInsets.all(4),
            child: const SVG(
              'assets/icons/user-square.svg',
              height: 24,
              width: 24,
              color: AppColors.mutedForeground,
            ),
          ),
        ),
      ],
    );
  }
}
