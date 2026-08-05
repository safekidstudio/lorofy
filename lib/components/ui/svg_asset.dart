import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SVG extends StatelessWidget {
  final String path;
  final double? width;
  final double? height;
  final Color? color;
  final BoxFit fit;
  final Alignment alignment;
  final WidgetBuilder? placeholderBuilder;
  final double? strokeWidth;

  const SVG(
    this.path, {
    super.key,
    this.width,
    this.height,
    this.color,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.placeholderBuilder,
    this.strokeWidth,
  });

  static final Map<String, String> _svgCache = {};

  Future<String> _loadAssetSvg(String path) async {
    if (_svgCache.containsKey(path)) {
      return _svgCache[path]!;
    }
    final data = await rootBundle.loadString(path);
    _svgCache[path] = data;
    return data;
  }

  Future<String> _fetchNetworkSvg(String url) async {
    if (_svgCache.containsKey(url)) {
      return _svgCache[url]!;
    }
    final client = HttpClient();
    final request = await client.getUrl(Uri.parse(url));
    final response = await request.close();
    final data = await response.transform(utf8.decoder).join();
    _svgCache[url] = data;
    return data;
  }

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

    if (strokeWidth != null) {
      return FutureBuilder<String>(
        future: isNetwork ? _fetchNetworkSvg(path) : _loadAssetSvg(path),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            String processed = snapshot.data!.replaceAll(
              RegExp(r'stroke-width="[^"]*"'),
              'stroke-width="$strokeWidth"',
            );
            return SvgPicture.string(
              processed,
              width: width,
              height: height,
              fit: fit,
              alignment: alignment,
              colorFilter: colorFilter,
            );
          }
          return placeholderBuilder?.call(context) ??
              SizedBox(width: width, height: height);
        },
      );
    }

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

