import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SVG extends StatelessWidget {
  final String path;
  final double? width;
  final double? height;
  final Color? color;

  const SVG(this.path, {super.key, this.width, this.height, this.color});

  @override
  Widget build(BuildContext context) {
    final isNetwork = path.startsWith('http://') || path.startsWith('https://');

    // Bộ lọc màu nếu có truyền color
    final colorFilter = color != null
        ? ColorFilter.mode(color!, BlendMode.srcIn)
        : null;

    if (isNetwork) {
      return SvgPicture.network(
        path,
        width: width,
        height: height,
        colorFilter: colorFilter,
        placeholderBuilder: (_) => const CupertinoActivityIndicator(radius: 8),
      );
    } else {
      return SvgPicture.asset(
        path,
        width: width,
        height: height,
        colorFilter: colorFilter,
      );
    }
  }
}
