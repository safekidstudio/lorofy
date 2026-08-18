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
