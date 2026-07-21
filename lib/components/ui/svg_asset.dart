import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SVG extends StatelessWidget {
  final String path;
  final double? width;
  final double? height;
  final Color? color;
  final BoxFit fit;
  final Alignment alignment;
  final WidgetBuilder? placeholderBuilder;

  const SVG(
    this.path, {
    super.key,
    this.width,
    this.height,
    this.color,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.placeholderBuilder,
  });

  static Future<void> precache(BuildContext context, String path) async {
    final isNetwork = path.startsWith('http://') || path.startsWith('https://');
    if (isNetwork) {
      final loader = SvgNetworkLoader(path);
      await svg.cache.putIfAbsent(
        loader.cacheKey(null),
        () => loader.loadBytes(null),
      );
    } else {
      final loader = SvgAssetLoader(path);
      await svg.cache.putIfAbsent(
        loader.cacheKey(null),
        () => loader.loadBytes(null),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isNetwork = path.startsWith('http://') || path.startsWith('https://');

    // Color filter logic
    final colorFilter = color != null
        ? ColorFilter.mode(color!, BlendMode.srcIn)
        : null;

    if (isNetwork) {
      return SvgPicture.network(
        path,
        width: width,
        height: height,
        fit: fit,
        alignment: alignment,
        colorFilter: colorFilter,
        placeholderBuilder: placeholderBuilder ??
            (_) => const CupertinoActivityIndicator(radius: 8),
      );
    } else {
      return SvgPicture.asset(
        path,
        width: width,
        height: height,
        fit: fit,
        alignment: alignment,
        colorFilter: colorFilter,
        placeholderBuilder: placeholderBuilder,
      );
    }
  }
}

