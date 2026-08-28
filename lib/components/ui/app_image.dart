import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:lorofy/core/constants/app_constants.dart';
import 'package:lorofy/components/ui/shimmer.dart';

class AppImage extends StatelessWidget {
  final String path;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius borderRadius;
  final Widget? errorWidget;

  const AppImage({
    super.key,
    required this.path,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = BorderRadius.zero,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    String resolvedPath = path;

    // Check if the path matches a remote default avatar URL and resolve it locally
    if (path.startsWith('http://') || path.startsWith('https://')) {
      for (final avatar in AppConstants.defaultAvatars) {
        if (avatar['remoteUrl'] == path) {
          resolvedPath = avatar['url']!;
          break;
        }
      }
    }

    // Determine the source type of the resolved image path
    final isNetwork = resolvedPath.startsWith('http://') ||
        resolvedPath.startsWith('https://') ||
        resolvedPath.startsWith('blob:') ||
        (kIsWeb && !resolvedPath.startsWith('assets/'));

    final isAsset = resolvedPath.startsWith('assets/');

    Widget imageWidget;

    if (isNetwork) {
      imageWidget = Image.network(
        resolvedPath,
        width: width,
        height: height,
        fit: fit,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded) return child;
          return AnimatedOpacity(
            opacity: frame == null ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            child: child,
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return ShimmerPlaceholder(
            width: width,
            height: height,
            borderRadius: borderRadius,
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return errorWidget ?? _buildErrorWidget();
        },
      );
    } else if (isAsset) {
      imageWidget = Image.asset(
        resolvedPath,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return errorWidget ?? _buildErrorWidget();
        },
      );
    } else {
      imageWidget = Image.file(
        File(resolvedPath),
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return errorWidget ?? _buildErrorWidget();
        },
      );
    }

    if (borderRadius != BorderRadius.zero) {
      return ClipRRect(
        borderRadius: borderRadius,
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  Widget _buildErrorWidget() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE4E4E6),
        borderRadius: borderRadius,
      ),
      alignment: Alignment.center,
      child: const Icon(
        CupertinoIcons.exclamationmark_triangle_fill,
        color: Color(0xFF8E8E93),
        size: 24,
      ),
    );
  }
}
