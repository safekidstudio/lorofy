import 'package:flutter/cupertino.dart';
import 'package:lorofy/components/ui/shimmer.dart';

class LeaderboardPageSkeleton extends StatelessWidget {
  const LeaderboardPageSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const ShimmerPlaceholder.circular(size: 80),
                  const SizedBox(height: 12),
                  ShimmerPlaceholder.rectangular(
                    width: 60,
                    height: 14,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 4),
                  ShimmerPlaceholder.rectangular(
                    width: 40,
                    height: 12,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const ShimmerPlaceholder.circular(size: 100),
                  const SizedBox(height: 12),
                  ShimmerPlaceholder.rectangular(
                    width: 80,
                    height: 16,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 4),
                  ShimmerPlaceholder.rectangular(
                    width: 50,
                    height: 12,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const ShimmerPlaceholder.circular(size: 80),
                  const SizedBox(height: 12),
                  ShimmerPlaceholder.rectangular(
                    width: 60,
                    height: 14,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 4),
                  ShimmerPlaceholder.rectangular(
                    width: 40,
                    height: 12,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 40),
        Column(
          children: List.generate(
            5,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: ShimmerPlaceholder.rectangular(
                height: 52,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
