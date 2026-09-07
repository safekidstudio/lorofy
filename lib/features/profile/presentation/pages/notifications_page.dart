import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lorofy/components/layout/app_header.dart';
import 'package:lorofy/components/ui/svg_asset.dart';
import 'package:lorofy/core/theme/app_theme.dart';
import 'package:lorofy/features/profile/presentation/widgets/notification_card.dart';
import 'package:lorofy/features/profile/presentation/providers/notifications_provider.dart';

class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                    color: AppColors.secondary,
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
                    color: AppColors.foreground,
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
                      color: AppColors.mutedForeground,
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
                          color: AppColors.mutedForeground,
                        ),
                      ),
                    );
                  }
                  return CupertinoScrollbar(
                    controller: _scrollController,
                    child: ListView.builder(
                      controller: _scrollController,
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
