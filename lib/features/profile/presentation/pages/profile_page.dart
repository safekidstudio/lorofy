import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lorofy/components/layout/app_header.dart';
import 'package:lorofy/components/shared/drawing_container.dart';
import 'package:lorofy/components/ui/app_confirm_dialog.dart';
import 'package:lorofy/components/ui/svg_asset.dart';
import 'package:lorofy/components/ui/toast.dart';
import 'package:lorofy/core/theme/app_theme.dart';
import 'package:lorofy/features/auth/presentation/providers/auth_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authStatus = ref.watch(authProvider);
    final String displayName = authStatus.displayName ?? 'James';
    final String username = authStatus.displayName != null
        ? authStatus.displayName!.toLowerCase().replaceAll(' ', '')
        : 'james';

    // The premium avatar URL representing James
    const String avatarUrl =
        'https://res.cloudinary.com/ikupgdru/image/upload/v1784619376/64_d4fo1k_wnebqr.png';

    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            AppHeader(
              leftActions: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE4E4E6),
                    shape: BoxShape.circle,
                  ),
                  child: const SVG(
                    'assets/icons/chevron-left.svg',
                    width: 24,
                    height: 24,
                  ),
                ),
              ),
              title: 'Profile',
              rightActions: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  AppToast.show(
                    context,
                    message: "Settings coming soon!",
                    type: ToastType.info,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: const SVG(
                    'assets/icons/settings_drawing.svg',
                    width: 24,
                    height: 24,
                  ),
                ),
              ),
            ),

            // Settings options list
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  const SizedBox(height: 16),
                  // Profile info
                  Column(
                    children: [
                      // Blob Avatar Outline
                      DrawingContainer(
                        shape: DrawingShape.blob,
                        width: 100,
                        height: 100,
                        borderColor: const Color(0xFF072013),
                        borderWidth: 4.0,
                        fillColor: CupertinoColors.transparent,
                        child: Image.network(
                          avatarUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                color: const Color(0xFFE5E5EA),
                                child: const Icon(
                                  CupertinoIcons.person_fill,
                                  size: 60,
                                  color: Color(0xFF8E8E93),
                                ),
                              ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Display Name
                      Text(
                        displayName,
                        style: const TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      // Handle/Username
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SVG(
                            'icons/at-symbol.svg',
                            width: 16,
                            height: 16,
                            color: AppColors.secondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            username,
                            style: const TextStyle(
                              fontFamily: AppTextStyles.fontFamily,
                              fontSize: 16,
                              color: AppColors.secondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  _buildMenuItem(
                    context: context,
                    title: 'My Profile',
                    onTap: () => _showComingSoon(context, 'My Profile'),
                  ),
                  const SizedBox(height: 8),
                  _buildMenuItem(
                    context: context,
                    title: 'Activities',
                    onTap: () => _showComingSoon(context, 'Activities'),
                  ),
                  const SizedBox(height: 8),
                  _buildMenuItem(
                    context: context,
                    title: 'Notifications',
                    onTap: () => _showComingSoon(context, 'Notifications'),
                  ),
                  const SizedBox(height: 8),
                  _buildMenuItem(
                    context: context,
                    title: 'Help Center',
                    onTap: () => _showComingSoon(context, 'Help Center'),
                  ),
                  const SizedBox(height: 8),
                  _buildMenuItem(
                    context: context,
                    title: 'Terms & Policies',
                    onTap: () => _showComingSoon(context, 'Terms & Policies'),
                  ),
                  const SizedBox(height: 8),
                  _buildMenuItem(
                    context: context,
                    title: 'Report',
                    onTap: () => _showComingSoon(context, 'Report'),
                  ),
                  const SizedBox(height: 8),
                  _buildMenuItem(
                    context: context,
                    title: 'Logout',
                    isDestructive: true,
                    onTap: () => _showLogoutConfirmationDialog(context, ref),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context, WidgetRef ref) {
    AppConfirmDialog.show(
      context: context,
      title: 'Logout',
      message: 'Are you sure you want to log out of Lorofy? 🌿',
      confirmLabel: 'Logout',
      isDestructive: true,
      onConfirm: () {
        ref.read(authProvider.notifier).logout();
        Navigator.pop(context); // Pop profile page after logout
      },
    );
  }

  void _showComingSoon(BuildContext context, String featureName) {
    AppToast.show(
      context,
      message: '$featureName coming soon in the next update!',
      type: ToastType.info,
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final Color textColor = isDestructive
        ? AppColors.destructive
        : AppColors.primary;

    final Color iconColor = isDestructive
        ? AppColors.destructive
        : AppColors.secondary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
            SVG(
              'icons/chevron-right.svg',
              width: 16,
              height: 16,
              color: iconColor,
            ),
          ],
        ),
      ),
    );
  }
}
