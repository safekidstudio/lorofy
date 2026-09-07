import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lorofy/components/ui/sound_clickable.dart';
import 'package:lorofy/core/theme/app_theme.dart';
import 'package:lorofy/features/mascot/domain/models/mascot.dart';
import 'package:lorofy/features/mascot/domain/models/mascot_stage.dart';
import 'package:lorofy/features/mascot/domain/models/mascot_type.dart';
import 'package:lorofy/features/mascot/presentation/providers/mascot_notifier.dart';

class MascotSelectorSheet extends ConsumerWidget {
  const MascotSelectorSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mascotState = ref.watch(mascotProvider);
    final activeMascot = mascotState.activeMascot;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              // Header Drag Handle
              Center(
                child: Container(
                  width: 36,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E5EA),
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title and Points
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Mascot Collection',
                    style: AppTextStyles.titleLarge,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E5EA),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Text('⭐️ ', style: TextStyle(fontSize: 14)),
                        Text(
                          '${mascotState.userPoints} pts',
                          style: const TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF232321),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Mascot List
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: mascotState.mascots.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final mascot = mascotState.mascots[index];
                    final isActive = mascot.id == activeMascot?.id;

                    return _buildMascotCard(
                      context,
                      ref,
                      mascot,
                      isActive,
                      mascotState.userPoints,
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMascotCard(
    BuildContext context,
    WidgetRef ref,
    Mascot mascot,
    bool isActive,
    int userPoints,
  ) {
    final notifier = ref.read(mascotProvider.notifier);
    final stage = mascot.currentStage;
    final stageName = stage.getDisplayName(mascot.type);
    final progress = mascot.stageProgressRatio;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: isActive ? const Color(0xFF232321) : AppColors.border,
          width: isActive ? 2.0 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000000).withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Graphic Placeholder Icon
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                mascot.type == MascotType.tree ? '🌱' : '🐥',
                style: const TextStyle(fontSize: 32),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mascot.name,
                  style: const TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF232321),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Stage: $stageName',
                  style: const TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 13,
                    color: AppColors.secondary,
                  ),
                ),
                if (mascot.isUnlocked) ...[
                  const SizedBox(height: 8),
                  // Progress Bar for growth within stage
                  Stack(
                    children: [
                      Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5E5EA),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: progress,
                        child: Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: const Color(0xFF232321),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Points: ${mascot.currentPoints}',
                        style: const TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 11,
                          color: AppColors.secondary,
                        ),
                      ),
                      if (stage != MascotStage.level3)
                        Text(
                          'Next stage: ${stage == MascotStage.level1 ? mascot.pointsToLevel2 : mascot.pointsToLevel3} pts',
                          style: const TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 11,
                            color: AppColors.secondary,
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 16),

          // Action Button
          _buildActionButton(context, notifier, mascot, isActive, userPoints),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    MascotNotifier notifier,
    Mascot mascot,
    bool isActive,
    int userPoints,
  ) {
    if (!mascot.isUnlocked) {
      final canUnlock = userPoints >= mascot.unlockCostPoints;
      return SoundClickable(
        onTap: canUnlock ? () => notifier.unlockMascot(mascot.id) : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: canUnlock
                ? const Color(0xFF232321)
                : const Color(0xFFE5E5EA),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'Unlock\n${mascot.unlockCostPoints} pts',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: canUnlock
                  ? CupertinoColors.white
                  : const Color(0xFF8E8E93),
            ),
          ),
        ),
      );
    }

    if (isActive) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFE5E5EA),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'Active',
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Color(0xFF8E8E93),
          ),
        ),
      );
    }

    return SoundClickable(
      onTap: () => notifier.selectActiveMascot(mascot.id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF232321),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'Select',
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: CupertinoColors.white,
          ),
        ),
      ),
    );
  }
}
