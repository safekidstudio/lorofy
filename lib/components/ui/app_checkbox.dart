import 'package:flutter/cupertino.dart';
import 'package:lorofy/components/ui/svg_asset.dart';
import 'package:lorofy/core/theme/app_theme.dart';

class AppCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final double size;

  const AppCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.size = 22,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: value ? AppColors.primary : CupertinoColors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: value ? AppColors.primary : const Color(0xFFD1D1D6),
            width: 2,
          ),
        ),
        child: value
            ? const Align(
                alignment: Alignment.center,
                child: SVG(
                  'assets/icons/check.svg',
                  width: 16,
                  height: 16,
                  strokeWidth: 2.5,
                  color: CupertinoColors.white,
                ),
              )
            : null,
      ),
    );
  }
}
