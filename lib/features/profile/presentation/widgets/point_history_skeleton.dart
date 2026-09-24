import 'package:flutter/cupertino.dart';
import 'package:lorofy/components/ui/shimmer.dart';
import 'package:lorofy/core/theme/app_theme.dart';

/// Skeleton loading placeholder for Point History screen.
class PointHistorySkeleton extends StatelessWidget {
  const PointHistorySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppPadding.lg),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 6,
      separatorBuilder: (context, index) => const SizedBox(height: AppPadding.md),
      itemBuilder: (context, index) {
        return const ShimmerPlaceholder.rectangular(
          height: 72,
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.md)),
        );
      },
    );
  }
}
