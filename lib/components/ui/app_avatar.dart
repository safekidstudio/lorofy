import 'package:flutter/cupertino.dart';
import 'package:lorofy/components/ui/app_image.dart';
import 'package:lorofy/components/ui/shimmer.dart';

class AppAvatar extends StatelessWidget {
  final String? path;
  final double size;
  final bool isLoading;
  final Color? borderColor;
  final double borderWidth;

  const AppAvatar({
    super.key,
    this.path,
    this.size = 52.0,
    this.isLoading = false,
    this.borderColor,
    this.borderWidth = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: borderColor != null && borderWidth > 0
              ? Border.all(color: borderColor!, width: borderWidth)
              : null,
        ),
        child: ClipOval(
          child: ShimmerPlaceholder.circular(size: size),
        ),
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
      child: ClipOval(
        child: avatarContent,
      ),
    );
  }

  Widget _buildFallback() {
    return Container(
      width: size,
      height: size,
      color: const Color(0xFFE4E4E6),
      alignment: Alignment.center,
      child: Icon(
        CupertinoIcons.person_alt,
        size: size * 0.5,
        color: const Color(0xFF8E8E93),
      ),
    );
  }
}
