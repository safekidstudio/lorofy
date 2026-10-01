import 'package:flutter/cupertino.dart';
import 'package:lorofy/components/ui/shimmer.dart';
import 'package:lorofy/core/theme/app_theme.dart';

/// Skeleton loading placeholder for Point History screen.
class PointHistorySkeleton extends StatelessWidget {
  const PointHistorySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppPadding.lg,
        vertical: AppPadding.sm,
      ),
      child: Column(
        children: List.generate(6, (index) {
          return const Padding(
            padding: EdgeInsets.only(bottom: AppPadding.md),
            child: ShimmerPlaceholder.rectangular(
              height: 72,
              borderRadius: BorderRadius.all(Radius.circular(AppRadius.md)),
            ),
          );
        }),
      ),
    );
  }
}
