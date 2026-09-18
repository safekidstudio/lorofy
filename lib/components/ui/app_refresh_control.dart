import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:lorofy/components/ui/loader.dart';
import 'package:lorofy/components/ui/svg_asset.dart';

class AppRefreshControl extends StatelessWidget {
  final Future<void> Function() onRefresh;

  const AppRefreshControl({
    super.key,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoSliverRefreshControl(
      onRefresh: onRefresh,
      builder: (
        BuildContext context,
        RefreshIndicatorMode refreshState,
        double pulledExtent,
        double refreshTriggerPullDistance,
        double refreshIndicatorExtent,
      ) {
        final double percentage =
            (pulledExtent / refreshTriggerPullDistance).clamp(0.0, 1.0);

        return Container(
          height: pulledExtent,
          alignment: Alignment.center,
          child: refreshState == RefreshIndicatorMode.refresh ||
                  refreshState == RefreshIndicatorMode.armed ||
                  refreshState == RefreshIndicatorMode.done
              ? const Loader(size: 24)
              : Opacity(
                  opacity: percentage,
                  child: Transform.rotate(
                    angle: percentage * math.pi * 2,
                    child: const SVG(
                      'assets/icons/loader.svg',
                      width: 24,
                      height: 24,
                      color: Color(0xFF232321),
                    ),
                  ),
                ),
        );
      },
    );
  }
}
