import 'package:flutter/cupertino.dart';
import 'package:lorofy/components/layout/app_header.dart';
import 'package:lorofy/components/ui/svg_asset.dart';
import 'package:lorofy/core/theme/app_theme.dart';

class NotificationItem {
  final String id;
  final String sender;
  final String action;
  final String topic;
  final String timeAgo;
  final bool isUnread;

  NotificationItem({
    required this.id,
    required this.sender,
    required this.action,
    required this.topic,
    required this.timeAgo,
    required this.isUnread,
  });

  NotificationItem copyWith({bool? isUnread}) {
    return NotificationItem(
      id: id,
      sender: sender,
      action: action,
      topic: topic,
      timeAgo: timeAgo,
      isUnread: isUnread ?? this.isUnread,
    );
  }
}

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final List<NotificationItem> _notifications = [
    NotificationItem(
      id: '1',
      sender: 'Lorofy',
      action: 'shared the meeting',
      topic: 'Boctamp Online Course',
      timeAgo: '3 hours ago',
      isUnread: true,
    ),
    NotificationItem(
      id: '2',
      sender: 'Lorofy',
      action: 'shared the meeting',
      topic: 'Boctamp Online Course',
      timeAgo: '3 hours ago',
      isUnread: false,
    ),
    NotificationItem(
      id: '3',
      sender: 'Lorofy',
      action: 'shared the meeting',
      topic: 'Boctamp Online Course',
      timeAgo: '3 hours ago',
      isUnread: false,
    ),
    NotificationItem(
      id: '4',
      sender: 'Lorofy',
      action: 'shared the meeting',
      topic: 'Boctamp Online Course',
      timeAgo: '3 hours ago',
      isUnread: false,
    ),
    NotificationItem(
      id: '5',
      sender: 'Lorofy',
      action: 'shared the meeting',
      topic: 'Boctamp Online Course',
      timeAgo: '3 hours ago',
      isUnread: false,
    ),
    NotificationItem(
      id: '6',
      sender: 'Lorofy',
      action: 'shared the meeting',
      topic: 'Boctamp Online Course',
      timeAgo: '3 hours ago',
      isUnread: false,
    ),
    NotificationItem(
      id: '7',
      sender: 'Lorofy',
      action: 'shared the meeting',
      topic: 'Boctamp Online Course',
      timeAgo: '3 hours ago',
      isUnread: false,
    ),
  ];

  void _markAllAsRead() {
    setState(() {
      for (int i = 0; i < _notifications.length; i++) {
        _notifications[i] = _notifications[i].copyWith(isUnread: false);
      }
    });
  }

  void _toggleNotificationRead(int index) {
    setState(() {
      _notifications[index] = _notifications[index].copyWith(
        isUnread: !_notifications[index].isUnread,
      );
    });
  }

  Widget _buildNotificationCard(int index) {
    final item = _notifications[index];

    return GestureDetector(
      onTap: () => _toggleNotificationRead(index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Card Content
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: CupertinoColors.white,
                borderRadius: BorderRadius.circular(AppRadius.md),
                boxShadow: [
                  BoxShadow(
                    color: CupertinoColors.systemGrey.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF071B12), // Brand dark green
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Icon(
                        CupertinoIcons.lightbulb, // Studying / Lamp icon equivalent
                        color: CupertinoColors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Texts
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '${item.sender} ',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF232321),
                                ),
                              ),
                              TextSpan(
                                text: '${item.action} ',
                                style: const TextStyle(
                                  color: Color(0xFF555555),
                                ),
                              ),
                              TextSpan(
                                text: item.topic,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF232321),
                                ),
                              ),
                            ],
                            style: const TextStyle(
                              fontFamily: AppTextStyles.fontFamily,
                              fontSize: 14,
                              height: 1.3,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item.timeAgo,
                          style: const TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 12,
                            color: Color(0xFF8E8E93),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Unread indicator dot
            if (item.isUnread)
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Color(0xFF000000), // Black dot as in screenshot
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                onPressed: _markAllAsRead,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: Stack(
                      children: [
                        Positioned(
                          left: 0,
                          top: 2,
                          child: Icon(
                            CupertinoIcons.checkmark,
                            color: const Color(0xFF232321),
                            size: 18,
                          ),
                        ),
                        Positioned(
                          left: 6,
                          top: 2,
                          child: Icon(
                            CupertinoIcons.checkmark,
                            color: const Color(0xFF232321),
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Notifications List
            Expanded(
              child: CupertinoScrollbar(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: _notifications.length,
                  itemBuilder: (context, index) => _buildNotificationCard(index),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
