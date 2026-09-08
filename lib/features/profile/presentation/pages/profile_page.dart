import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lorofy/components/layout/app_header.dart';
import 'package:lorofy/components/ui/app_avatar.dart';
import 'package:lorofy/components/ui/svg_asset.dart';
// import 'package:lorofy/components/ui/toast.dart';
import 'package:lorofy/components/ui/sound_clickable.dart';
import 'package:lorofy/core/theme/app_theme.dart';
import 'package:lorofy/features/auth/presentation/providers/auth_provider.dart';
import 'package:lorofy/features/profile/presentation/pages/my_profile_page.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authStatus = ref.watch(authProvider);
    final String displayName = authStatus.displayName ?? 'Lorofy User';
    final String username = authStatus.username ?? 'lorofy.user';
    final String? avatarUrl = authStatus.avatarUrl;

    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            AppHeader(
              leftActions: AppBackButton(
                onPressed: () => Navigator.pop(context),
              ),
              title: 'Profile',
              rightActions: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => context.push('/settings'),
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
                      AppAvatar(path: avatarUrl, size: 100, isDrawing: true),
                      const SizedBox(height: 16),
                      // Display Name
                      Text(
                        displayName,
                        style: const TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                          color: AppColors.foreground,
                        ),
                      ),
                      const SizedBox(height: 2),
                      // Handle/Username
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SVG(
                            'assets/icons/at-symbol.svg',
                            width: 16,
                            height: 16,
                            color: AppColors.mutedForeground,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            username,
                            style: const TextStyle(
                              fontFamily: AppTextStyles.fontFamily,
                              fontSize: 16,
                              color: AppColors.mutedForeground,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      CardActionArea(
                        onTap: () => context.push('/my-points'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: CupertinoColors.systemRed.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: CupertinoColors.systemRed.withValues(
                                alpha: 0.25,
                              ),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SVG(
                                'assets/icons/point.svg',
                                width: 16,
                                height: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${authStatus.rankPoints ?? 0} pts',
                                style: const TextStyle(
                                  fontFamily: AppTextStyles.fontFamily,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: CupertinoColors.systemRed,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildMenuItem(
                    context: context,
                    title: 'My Profile',
                    onTap: () => Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => const MyProfilePage(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),
                  _buildMenuItem(
                    context: context,
                    title: 'My Points',
                    onTap: () => context.push('/my-points'),
                  ),
                  const SizedBox(height: 8),
                  _buildMenuItem(
                    context: context,
                    title: 'Activities',
                    onTap: () => context.push('/my-activities'),
                  ),
                  /*
                  const SizedBox(height: 8),
                  _buildMenuItem(
                    context: context,
                    title: 'Notifications',
                    onTap: () => context.push('/notifications'),
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
                  */
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
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Logout'),
            onPressed: () {
              Navigator.pop(context);
              ref.read(authProvider.notifier).logout();
            },
          ),
        ],
      ),
    );
  }

  /*
  void _showComingSoon(BuildContext context, String featureName) {
    AppToast.show(
      context,
      message: '$featureName coming soon in the next update!',
      type: ToastType.info,
    );
  }
  */

  Widget _buildMenuItem({
    required BuildContext context,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final Color textColor = isDestructive
        ? AppColors.destructive
        : AppColors.foreground;

    final Color iconColor = isDestructive
        ? AppColors.destructive
        : AppColors.mutedForeground;

    return CardActionArea(
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
              'assets/icons/chevron-right.svg',
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
