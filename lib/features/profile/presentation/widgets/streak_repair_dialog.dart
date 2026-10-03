import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smooth_sheets/smooth_sheets.dart';
import 'package:lorofy/components/layout/app_header.dart';
import 'package:lorofy/components/ui/button.dart';
import 'package:lorofy/components/ui/sound_clickable.dart';
import 'package:lorofy/components/ui/svg_asset.dart';
import 'package:lorofy/core/theme/app_theme.dart';
import 'package:lorofy/features/auth/data/models/user_profile.dart';
import 'package:lorofy/features/auth/presentation/providers/auth_provider.dart';
import 'package:lorofy/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:lorofy/features/profile/presentation/pages/streak_celebration_page.dart';

class StreakRepairDialog extends ConsumerStatefulWidget {
  final UserProfile profile;

  const StreakRepairDialog({super.key, required this.profile});

  static Future<void> show(BuildContext context, UserProfile profile) async {
    await Navigator.push(
      context,
      ModalSheetRoute(
        swipeDismissible: true,
        builder: (context) => Sheet(
          decoration: const MaterialSheetDecoration(
            size: SheetSize.fit,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            color: AppColors.background,
          ),
          child: StreakRepairDialog(profile: profile),
        ),
      ),
    );
  }

  @override
  ConsumerState<StreakRepairDialog> createState() => _StreakRepairDialogState();
}

class _StreakRepairDialogState extends ConsumerState<StreakRepairDialog> {
  bool _useFreezeItem = false;
  bool _useCoins = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final freezeCount = widget.profile.streakFreezeCount;
    final goldCoins = widget.profile.goldCoins;
    final costCoins =
        widget.profile.repairCostCoins > 0 ? widget.profile.repairCostCoins : 100;

    final bool canUseFreeze = freezeCount > 0;
    final bool canUseCoins = goldCoins >= costCoins;

    if (canUseFreeze) {
      _useFreezeItem = true;
      _useCoins = false;
    } else if (canUseCoins) {
      _useCoins = true;
      _useFreezeItem = false;
    } else {
      _useFreezeItem = false;
      _useCoins = false;
    }
  }

  Future<void> _handleRepair() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final repository = ref.read(profileRepositoryProvider);
      final updatedProfile = await repository.repairStreak(
        useFreezeItem: _useFreezeItem,
        useCoins: _useCoins,
      );

      await ref.read(authProvider.notifier).refreshProfile();

      if (mounted) {
        Navigator.of(context).pop();

        // Launch full screen Streak Celebration Page with Rive fire animation
        StreakCelebrationPage.show(
          context,
          currentStreak: updatedProfile.currentStreak,
          longestStreak: updatedProfile.longestStreak,
          streakIncreased: true,
          streakFreezeCount: updatedProfile.streakFreezeCount,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.destructive,
            content: Text(
              'Failed to restore streak: $e',
              style: const TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                color: CupertinoColors.white,
              ),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final streakDays = widget.profile.repairableStreak;
    final freezeCount = widget.profile.streakFreezeCount;
    final goldCoins = widget.profile.goldCoins;
    final costCoins =
        widget.profile.repairCostCoins > 0 ? widget.profile.repairCostCoins : 100;

    final bool canUseFreeze = freezeCount > 0;
    final bool canUseCoins = goldCoins >= costCoins;
    final bool hasAnyResource = canUseFreeze || canUseCoins;

    // Strict validation: Only enable button if selected option is actually valid
    final bool isOptionValid =
        (_useFreezeItem && canUseFreeze) || (_useCoins && canUseCoins);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Sheet Header
            AppHeader(
              leftActions: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => Navigator.pop(context),
                child: const SVG(
                  'assets/icons/cancel.svg',
                  width: 20,
                  height: 20,
                ),
              ),
              title: 'Restore Streak',
            ),
            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppPadding.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Hero Header Card (Black & White Primary theme)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: CupertinoColors.black.withValues(alpha: 0.12),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: CupertinoColors.white.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(
                              CupertinoIcons.flame_fill,
                              color: CupertinoColors.white,
                              size: 26,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Save Your $streakDays-Day Streak!',
                                style: const TextStyle(
                                  fontFamily: AppTextStyles.fontFamily,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: CupertinoColors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Recover your progress using a shield or coins.',
                                style: TextStyle(
                                  fontFamily: AppTextStyles.fontFamily,
                                  fontSize: 12,
                                  color: CupertinoColors.white.withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Option 1: Freeze Shield Card
                  _buildOptionCard(
                    title: 'Streak Freeze Shield',
                    subtitle: canUseFreeze
                        ? 'Available: $freezeCount shields'
                        : 'No freeze shields in inventory',
                    icon: CupertinoIcons.snow,
                    iconColor: AppColors.primary,
                    isSelected: _useFreezeItem && canUseFreeze,
                    isEnabled: canUseFreeze,
                    onTap: () {
                      if (canUseFreeze) {
                        setState(() {
                          _useFreezeItem = true;
                          _useCoins = false;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 12),

                  // Option 2: Gold Coins Card
                  _buildOptionCard(
                    title: 'Use $costCoins Gold Coins',
                    subtitle: 'Balance: $goldCoins coins',
                    icon: CupertinoIcons.money_dollar_circle_fill,
                    iconColor: AppColors.primary,
                    isSelected: _useCoins && canUseCoins,
                    isEnabled: canUseCoins,
                    onTap: () {
                      if (canUseCoins) {
                        setState(() {
                          _useCoins = true;
                          _useFreezeItem = false;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // Motivational Tip Card when user lacks resources
                  if (!hasAnyResource) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.muted,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.border,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            CupertinoIcons.lightbulb_fill,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'You need more coins to restore. Complete focus sessions to earn Gold Coins!',
                              style: TextStyle(
                                fontFamily: AppTextStyles.fontFamily,
                                fontSize: 12,
                                color: AppColors.foreground.withValues(alpha: 0.85),
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Smart Action Button
                  if (hasAnyResource)
                    Button.primary(
                      text: 'Restore Streak',
                      isLoading: _isLoading,
                      disabled: _isLoading || !isOptionValid,
                      onPressed: (_isLoading || !isOptionValid) ? null : _handleRepair,
                    )
                  else
                    Button.primary(
                      text: 'Focus Now to Earn Coins 🎯',
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required bool isSelected,
    required bool isEnabled,
    required VoidCallback onTap,
  }) {
    final Color bgColor = isSelected ? AppColors.primary : CupertinoColors.white;
    final Color textColor = isSelected ? CupertinoColors.white : AppColors.foreground;
    final Color subTextColor = isSelected
        ? CupertinoColors.white.withValues(alpha: 0.8)
        : (isEnabled ? AppColors.mutedForeground : AppColors.destructive);

    return Opacity(
      opacity: isEnabled ? 1.0 : 0.5,
      child: CardActionArea(
        onTap: isEnabled ? onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : (isEnabled ? AppColors.border : AppColors.border.withValues(alpha: 0.5)),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? CupertinoColors.white.withValues(alpha: 0.15)
                      : iconColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: isSelected ? CupertinoColors.white : iconColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 12,
                        color: subTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              isSelected
                  ? const SVG(
                      'assets/icons/check.svg',
                      width: 20,
                      height: 20,
                      color: CupertinoColors.white,
                    )
                  : Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.mutedForeground,
                          width: 1.5,
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
