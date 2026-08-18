import 'package:flutter/cupertino.dart';
import 'package:lorofy/components/ui/app_avatar.dart';
import 'package:lorofy/core/constants/app_constants.dart';
import 'package:lorofy/core/theme/app_theme.dart';

class OnboardAvatarStep extends StatelessWidget {
  final bool isDisabled;
  final String? uploadedImagePath;
  final String? selectedAvatarUrl;
  final bool isUploading;
  final int selectedAvatarIndex;
  final PageController pageController;
  final VoidCallback onUploadPressed;
  final ValueChanged<int> onAvatarIndexChanged;

  const OnboardAvatarStep({
    super.key,
    required this.isDisabled,
    required this.uploadedImagePath,
    required this.selectedAvatarUrl,
    required this.isUploading,
    required this.selectedAvatarIndex,
    required this.pageController,
    required this.onUploadPressed,
    required this.onAvatarIndexChanged,
  });

  @override
  Widget build(BuildContext context) {
    const double avatarSize = 130;

    return Column(
      children: [
        const SizedBox(height: 20),
        Center(
          child: Stack(
            children: [
              AppAvatar(
                path: uploadedImagePath ?? selectedAvatarUrl,
                size: avatarSize,
                isLoading: isUploading,
                borderColor: const Color(0xFF232321).withValues(alpha: 0.1),
                borderWidth: 2,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: isDisabled || isUploading ? null : onUploadPressed,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: CupertinoColors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFE4E4E6),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: CupertinoColors.systemGrey.withValues(
                            alpha: 0.2,
                          ),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      CupertinoIcons.camera_fill,
                      size: 18,
                      color: Color(0xFF232321),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Text('Choose your avatar', style: AppTextStyles.titleLarge),
        const SizedBox(height: 8),
        Text(
          'Upload your avatar or using avatar list below',
          style: AppTextStyles.body.copyWith(
            color: AppColors.secondary,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        SizedBox(
          height: 100,
          child: PageView.builder(
            controller: pageController,
            itemCount: 100000,
            onPageChanged: (page) {
              final index = page % AppConstants.defaultAvatars.length;
              onAvatarIndexChanged(index);
            },
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final mappedIndex = index % AppConstants.defaultAvatars.length;
              final avatar = AppConstants.defaultAvatars[mappedIndex];
              final int initialPage =
                  1000 * AppConstants.defaultAvatars.length + selectedAvatarIndex;

              return AnimatedBuilder(
                animation: pageController,
                builder: (context, child) {
                  double distance = 0.0;
                  if (pageController.position.haveDimensions) {
                    distance = (pageController.page! - index).abs();
                  } else {
                    distance = (index - initialPage).abs().toDouble();
                  }

                  double scale = 1.0;
                  double opacity = 1.0;

                  if (distance <= 1.0) {
                    scale = 1.35 - (distance * 0.40);
                    opacity = 1.0 - (distance * 0.30);
                  } else if (distance <= 2.0) {
                    scale = 0.95 - ((distance - 1.0) * 0.25);
                    opacity = 0.70 - ((distance - 1.0) * 0.30);
                  } else {
                    scale = 0.70 - ((distance - 2.0) * 0.20);
                    opacity = 0.40 - ((distance - 2.0) * 0.20);
                    if (scale < 0.5) scale = 0.5;
                    if (opacity < 0.2) opacity = 0.2;
                  }

                  final isSelected = mappedIndex == selectedAvatarIndex;

                  return GestureDetector(
                    onTap: isDisabled
                        ? null
                        : () {
                            pageController.animateToPage(
                              index,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOut,
                            );
                          },
                    child: Center(
                      child: Transform.scale(
                        scale: scale,
                        child: Opacity(
                          opacity: opacity,
                          child: Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: isSelected
                                  ? Border.all(
                                      color: const Color(0xFF232321),
                                      width: 3,
                                    )
                                  : null,
                            ),
                            padding: isSelected
                                ? const EdgeInsets.all(2)
                                : EdgeInsets.zero,
                            child: AppAvatar(path: avatar['url'], size: 52),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
