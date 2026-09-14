import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lorofy/core/theme/app_theme.dart';
import 'package:lorofy/features/auth/data/models/user_profile.dart';
import 'package:lorofy/features/auth/presentation/providers/auth_provider.dart';
import 'package:lorofy/features/profile/data/repositories/profile_repository_impl.dart';

class StreakRepairDialog extends ConsumerStatefulWidget {
  final UserProfile profile;

  const StreakRepairDialog({super.key, required this.profile});

  static Future<void> show(BuildContext context, UserProfile profile) async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => StreakRepairDialog(profile: profile),
    );
  }

  @override
  ConsumerState<StreakRepairDialog> createState() => _StreakRepairDialogState();
}

class _StreakRepairDialogState extends ConsumerState<StreakRepairDialog> {
  bool _useFreezeItem = false;
  bool _useCoins = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.profile.streakFreezeCount > 0) {
      _useFreezeItem = true;
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: CupertinoColors.systemGreen,
            content: Text(
              '🎉 Successfully restored your ${updatedProfile.currentStreak}-day streak!',
              style: const TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                color: CupertinoColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
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
    final costCoins = widget.profile.repairCostCoins > 0 ? widget.profile.repairCostCoins : 100;

    const brandAccent = CupertinoColors.activeOrange;
    const itemHighlight = CupertinoColors.activeBlue;

    return Dialog(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
      child: Padding(
        padding: const EdgeInsets.all(AppPadding.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppPadding.lg),
              decoration: BoxDecoration(
                color: brandAccent.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                CupertinoIcons.flame_fill,
                color: brandAccent,
                size: 40,
              ),
            ),
            const SizedBox(height: AppPadding.lg),
            const Text(
              'Restore Streak!',
              style: AppTextStyles.titleMedium,
            ),
            const SizedBox(height: AppPadding.sm),
            Text(
              'You can restore your lost $streakDays-day streak using one of the options below:',
              textAlign: TextAlign.center,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.mutedForeground,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: AppPadding.xl),

            // Option 1: Freeze Item
            GestureDetector(
              onTap: freezeCount > 0
                  ? () {
                      setState(() {
                        _useFreezeItem = true;
                        _useCoins = false;
                      });
                    }
                  : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(AppPadding.md),
                decoration: BoxDecoration(
                  color: _useFreezeItem
                      ? itemHighlight.withValues(alpha: 0.15)
                      : AppColors.muted,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: _useFreezeItem ? itemHighlight : AppColors.border,
                    width: _useFreezeItem ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      CupertinoIcons.snow,
                      color: CupertinoColors.systemTeal,
                      size: 24,
                    ),
                    const SizedBox(width: AppPadding.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Streak Freeze Shield',
                            style: AppTextStyles.body,
                          ),
                          Text(
                            freezeCount > 0
                                ? 'Available: $freezeCount items'
                                : 'Item not available',
                            style: AppTextStyles.caption.copyWith(
                              color: freezeCount > 0
                                  ? AppColors.mutedForeground
                                  : AppColors.destructive,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      _useFreezeItem
                          ? CupertinoIcons.checkmark_circle_fill
                          : CupertinoIcons.circle,
                      color: _useFreezeItem ? itemHighlight : AppColors.mutedForeground,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppPadding.md),

            // Option 2: Gold Coins
            GestureDetector(
              onTap: goldCoins >= costCoins
                  ? () {
                      setState(() {
                        _useCoins = true;
                        _useFreezeItem = false;
                      });
                    }
                  : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(AppPadding.md),
                decoration: BoxDecoration(
                  color: _useCoins
                      ? itemHighlight.withValues(alpha: 0.15)
                      : AppColors.muted,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: _useCoins ? itemHighlight : AppColors.border,
                    width: _useCoins ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      CupertinoIcons.money_dollar_circle_fill,
                      color: CupertinoColors.systemYellow,
                      size: 24,
                    ),
                    const SizedBox(width: AppPadding.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Use $costCoins Gold Coins',
                            style: AppTextStyles.body,
                          ),
                          Text(
                            'Balance: $goldCoins coins',
                            style: AppTextStyles.caption.copyWith(
                              color: goldCoins >= costCoins
                                  ? AppColors.mutedForeground
                                  : AppColors.destructive,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      _useCoins
                          ? CupertinoIcons.checkmark_circle_fill
                          : CupertinoIcons.circle,
                      color: _useCoins ? itemHighlight : AppColors.mutedForeground,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppPadding.xl),

            Row(
              children: [
                Expanded(
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(vertical: AppPadding.md),
                    onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                    child: Text(
                      'Cancel',
                      style: AppTextStyles.buttonText.copyWith(
                        color: AppColors.mutedForeground,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppPadding.md),
                Expanded(
                  child: CupertinoButton.filled(
                    padding: const EdgeInsets.symmetric(vertical: AppPadding.md),
                    onPressed:
                        _isLoading || (!_useFreezeItem && !_useCoins) ? null : _handleRepair,
                    child: _isLoading
                        ? const CupertinoActivityIndicator()
                        : Text(
                            'Restore',
                            style: AppTextStyles.buttonText.copyWith(
                              color: CupertinoColors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
