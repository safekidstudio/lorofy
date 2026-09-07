import 'package:flutter/cupertino.dart';
import 'package:lorofy/components/ui/svg_asset.dart';
import 'package:lorofy/core/theme/app_theme.dart';

class StatusSelectSheet extends StatelessWidget {
  final String currentStatus;
  final ValueChanged<String> onSelect;

  const StatusSelectSheet({
    super.key,
    required this.currentStatus,
    required this.onSelect,
  });

  Widget _buildOption(
    BuildContext context, {
    required String label,
    required String value,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        onSelect(value);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : CupertinoColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? CupertinoColors.white : AppColors.foreground,
              ),
            ),
            if (isSelected)
              const SVG(
                'assets/icons/check.svg',
                width: 16,
                height: 16,
                color: CupertinoColors.white,
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Pull bar / Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Title
            const Text(
              'Select Status',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTextStyles.titleFontFamily,
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: AppColors.foreground,
                letterSpacing: -0.5,
                decoration: TextDecoration.none,
              ),
            ),
            const SizedBox(height: 24),
            _buildOption(
              context,
              label: 'All',
              value: 'ALL',
              isSelected: currentStatus == 'ALL',
            ),
            _buildOption(
              context,
              label: 'Completed',
              value: 'COMPLETED',
              isSelected: currentStatus == 'COMPLETED',
            ),
            _buildOption(
              context,
              label: 'Failed',
              value: 'FAILED',
              isSelected: currentStatus == 'FAILED',
            ),
          ],
        ),
      ),
    );
  }
}
