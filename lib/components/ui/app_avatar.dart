import 'package:flutter/cupertino.dart';
import 'package:lorofy/components/shared/drawing_container.dart';
import 'package:lorofy/components/ui/app_image.dart';
import 'package:lorofy/components/ui/shimmer.dart';

class AppAvatar extends StatelessWidget {
  final String? path;
  final double size;
  final bool isLoading;
  final Color? borderColor;
  final double borderWidth;
  final bool isDrawing;

  const AppAvatar({
    super.key,
    this.path,
    this.size = 52.0,
    this.isLoading = false,
    this.borderColor,
    this.borderWidth = 0.0,
    this.isDrawing = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      final shimmerChild = ShimmerPlaceholder(
        width: size,
        height: size,
        shape: BoxShape.rectangle,
      );
      if (isDrawing) {
        return DrawingContainer(
          shape: DrawingShape.blob,
          width: size,
          height: size,
          borderColor: borderColor ?? const Color(0xFF072013),
          borderWidth: borderWidth > 0 ? borderWidth : 4.0,
          fillColor: CupertinoColors.transparent,
          child: shimmerChild,
        );
      }
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: borderColor != null && borderWidth > 0
              ? Border.all(color: borderColor!, width: borderWidth)
              : null,
        ),
        child: ClipOval(child: shimmerChild),
      );
    }

    final hasPath = path != null && path!.isNotEmpty;

    Widget avatarContent;
    if (hasPath) {
      avatarContent = AppImage(
        path: path!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorWidget: _buildFallback(),
      );
    } else {
      avatarContent = _buildFallback();
    }

    if (isDrawing) {
      return DrawingContainer(
        shape: DrawingShape.blob,
        width: size,
        height: size,
        borderColor: borderColor ?? const Color(0xFF072013),
        borderWidth: borderWidth > 0 ? borderWidth : 4.0,
        fillColor: CupertinoColors.transparent,
        child: avatarContent,
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFE4E4E6),
        border: borderColor != null && borderWidth > 0
            ? Border.all(color: borderColor!, width: borderWidth)
            : null,
      ),
      child: ClipOval(child: avatarContent),
    );
  }

  Widget _buildFallback() {
    return Image.asset(
      'assets/logos/lorofy.png',
      width: size,
      height: size,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        width: size,
        height: size,
        color: const Color(0xFFE4E4E6),
      ),
    );
  }
}
