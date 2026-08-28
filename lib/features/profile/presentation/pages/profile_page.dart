import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lorofy/components/layout/app_header.dart';
import 'package:lorofy/components/ui/app_avatar.dart';
import 'package:lorofy/components/ui/svg_asset.dart';
import 'package:lorofy/components/ui/toast.dart';
import 'package:smooth_sheets/smooth_sheets.dart';
import 'package:lorofy/components/ui/sound_clickable.dart';
import 'package:lorofy/core/theme/app_theme.dart';
import 'package:lorofy/features/auth/presentation/providers/auth_provider.dart';
import 'package:lorofy/features/profile/presentation/widgets/logout_confirm_sheet.dart';
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
              leftActions: AppBackButton(onPressed: () => Navigator.pop(context)),
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
                          color: AppColors.primary,
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
                      const SizedBox(height: 12),
                      CardActionArea(
                        onTap: () => context.push('/my-points'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF2E2E).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFFFF2E2E).withValues(alpha: 0.25),
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
                                  color: Color(0xFFFF2E2E),
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
    Navigator.push(
      context,
      CupertinoModalSheetRoute(
        builder: (context) => Sheet(
          decoration: const MaterialSheetDecoration(
            size: SheetSize.fit,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            color: Color(0xFFF6F6F6),
          ),
          child: LogoutConfirmSheet(
            onConfirm: () {
              ref.read(authProvider.notifier).logout();
              Navigator.pop(context); // Pop profile page after logout
            },
          ),
        ),
      ),
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
