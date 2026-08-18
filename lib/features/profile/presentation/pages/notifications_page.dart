import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lorofy/components/layout/app_header.dart';
import 'package:lorofy/components/ui/svg_asset.dart';
import 'package:lorofy/core/theme/app_theme.dart';
import 'package:lorofy/features/profile/presentation/widgets/notification_card.dart';
import 'package:lorofy/features/profile/presentation/providers/notifications_provider.dart';

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);

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
              title: 'Notifications',
              rightActions: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () =>
                    ref.read(notificationsProvider.notifier).markAllAsRead(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: const SVG(
                    'assets/icons/checks.svg',
                    width: 24,
                    height: 24,
                    color: Color(0xFF232321),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Notifications List
            Expanded(
              child: notificationsAsync.when(
                loading: () => const Center(
                  child: CupertinoActivityIndicator(),
                ),
                error: (error, stack) => Center(
                  child: Text(
                    'Failed to load notifications: ${error.toString()}',
                    style: const TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      color: Color(0xFF8E8E93),
                    ),
                  ),
                ),
                data: (notifications) {
                  if (notifications.isEmpty) {
                    return const Center(
                      child: Text(
                        'No notifications found',
                        style: TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          color: Color(0xFF8E8E93),
                        ),
                      ),
                    );
                  }
                  return CupertinoScrollbar(
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        final item = notifications[index];
                        return NotificationCard(
                          item: item,
                          onTap: () => ref
                              .read(notificationsProvider.notifier)
                              .toggleRead(item.id),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
