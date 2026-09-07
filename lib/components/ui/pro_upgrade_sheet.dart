import 'package:flutter/cupertino.dart';
import 'package:lorofy/components/ui/button.dart';
import 'package:lorofy/core/theme/app_theme.dart';

class SubscriptionPlan {
  final String code;
  final String name;
  final String priceText;
  final String durationText;
  final String? badge;

  const SubscriptionPlan({
    required this.code,
    required this.name,
    required this.priceText,
    required this.durationText,
    this.badge,
  });
}

class ProUpgradeSheet extends StatefulWidget {
  final VoidCallback? onUpgradeSuccess;

  const ProUpgradeSheet({super.key, this.onUpgradeSuccess});

  static void show(BuildContext context, {VoidCallback? onUpgradeSuccess}) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => ProUpgradeSheet(onUpgradeSuccess: onUpgradeSuccess),
    );
  }

  @override
  State<ProUpgradeSheet> createState() => _ProUpgradeSheetState();
}

class _ProUpgradeSheetState extends State<ProUpgradeSheet> {
  int _selectedPlanIndex = 1; // Default to Yearly (Best Value)

  final List<SubscriptionPlan> _plans = const [
    SubscriptionPlan(
      code: 'PRO_MONTHLY',
      name: 'Monthly',
      priceText: '49.000đ',
      durationText: '/ month',
    ),
    SubscriptionPlan(
      code: 'PRO_YEARLY',
      name: 'Yearly',
      priceText: '399.000đ',
      durationText: '/ year',
      badge: 'Best Value',
    ),
    SubscriptionPlan(
      code: 'PRO_LIFETIME',
      name: 'Lifetime',
      priceText: '999.000đ',
      durationText: 'one-time',
      badge: 'Save Big',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Pro Icon
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFF9E6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    CupertinoIcons.star_fill,
                    color: Color(0xFFFFB800),
                    size: 40,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Title
              const Text(
                'Upgrade to Lorofy Pro',
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  decoration: TextDecoration.none,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              // Description
              const Text(
                'Unlock all premium features including Spotify integration, all ambient sounds, unlimited deep focus, and advanced statistics.',
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.secondary,
                  decoration: TextDecoration.none,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // Features list
              _buildFeatureItem(CupertinoIcons.music_note_2, 'Spotify Integration & Premium Playlists'),
              const SizedBox(height: 12),
              _buildFeatureItem(CupertinoIcons.waveform_path, 'All Ambient Sound Libraries'),
              const SizedBox(height: 12),
              _buildFeatureItem(CupertinoIcons.shield_fill, 'Strict Deep Focus & App Blocker'),
              const SizedBox(height: 28),
              
              // Pricing Plans List
              Column(
                children: List.generate(_plans.length, (index) {
                  final plan = _plans[index];
                  final isSelected = _selectedPlanIndex == index;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedPlanIndex = index;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.05)
                            : AppColors.background,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.border,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.secondary,
                                width: 2,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: isSelected
                                ? Container(
                                    width: 10,
                                    height: 10,
                                    decoration: const BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      plan.name,
                                      style: const TextStyle(
                                        fontFamily: AppTextStyles.fontFamily,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primary,
                                        decoration: TextDecoration.none,
                                      ),
                                    ),
                                    if (plan.badge != null) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFFB800),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          plan.badge!,
                                          style: const TextStyle(
                                            fontFamily: AppTextStyles.fontFamily,
                                            fontSize: 9,
                                            fontWeight: FontWeight.w700,
                                            color: CupertinoColors.white,
                                            decoration: TextDecoration.none,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                plan.priceText,
                                style: const TextStyle(
                                  fontFamily: AppTextStyles.fontFamily,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                              Text(
                                plan.durationText,
                                style: const TextStyle(
                                  fontFamily: AppTextStyles.fontFamily,
                                  fontSize: 11,
                                  color: AppColors.secondary,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),
              
              // Upgrade Button
              Button.primary(
                text: 'Upgrade Now',
                onPressed: () {
                  Navigator.pop(context);
                  if (widget.onUpgradeSuccess != null) {
                    widget.onUpgradeSuccess!();
                  }
                  showCupertinoDialog(
                    context: context,
                    builder: (context) => CupertinoAlertDialog(
                      title: const Text('Thank you!'),
                      content: Text(
                        'Thank you for upgrading to the ${_plans[_selectedPlanIndex].name} plan! Demo transaction completed successfully.',
                      ),
                      actions: [
                        CupertinoDialogAction(
                          child: const Text('OK'),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              // Cancel button
              Button.secondary(
                text: 'Maybe Later',
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFFFB800), size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.primary,
              decoration: TextDecoration.none,
            ),
          ),
        ),
      ],
    );
  }
}
