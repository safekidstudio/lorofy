import 'package:flutter/cupertino.dart';
import 'package:lorofy/components/ui/button.dart';
import 'package:lorofy/core/theme/app_theme.dart';

class AvatarSelectSheet extends StatelessWidget {
  final List<Map<String, String>> defaultAvatars;
  final Function(String id, String url) onSelectPreset;
  final VoidCallback onPickGallery;

  const AvatarSelectSheet({
    super.key,
    required this.defaultAvatars,
    required this.onSelectPreset,
    required this.onPickGallery,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Pull bar / Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE4E4E6),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              'Update Avatar',
              style: TextStyle(
                fontFamily: AppTextStyles.titleFontFamily,
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: AppColors.primary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Upload from Gallery Button
            Button.secondary(
              text: 'Upload from Gallery',
              prefix: const Icon(
                CupertinoIcons.photo_on_rectangle,
                size: 20,
                color: Color(0xFF232321),
              ),
              onPressed: () {
                Navigator.pop(context);
                onPickGallery();
              },
            ),

            const SizedBox(height: 24),

            // Sub-title
            const Text(
              'Or choose a preset avatar:',
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: 12),

            // Preset Avatars Grid
            SizedBox(
              height: 160,
              child: GridView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.0,
                ),
                itemCount: defaultAvatars.length,
                itemBuilder: (context, index) {
                  final avatar = defaultAvatars[index];
                  return GestureDetector(
                    onTap: () {
                      onSelectPreset(avatar['id']!, avatar['url']!);
                      Navigator.pop(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFE4E4E6),
                          width: 1.5,
                        ),
                      ),
                      child: ClipOval(
                        child: Image.network(
                          avatar['url']!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
