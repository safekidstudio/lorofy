import 'package:intl/intl.dart';

class AppDateFormatter {
  /// Parses ISO 8601 string or returns null if invalid
  static DateTime? parse(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;
    try {
      return DateTime.parse(dateStr).toLocal();
    } catch (_) {
      return null;
    }
  }

  /// Formats Date & Time: dd/MM/yyyy - hh:mm a (e.g. 12/09/2026 - 11:45 PM)
  static String formatDateTime(dynamic input, {String locale = 'en'}) {
    final dt = input is String ? parse(input) : (input is DateTime ? input.toLocal() : null);
    if (dt == null) return '';
    return DateFormat('dd/MM/yyyy - hh:mm a', locale).format(dt);
  }

  /// Formats Date only: dd/MM/yyyy (e.g. 12/09/2026)
  static String formatDate(dynamic input, {String locale = 'en'}) {
    final dt = input is String ? parse(input) : (input is DateTime ? input.toLocal() : null);
    if (dt == null) return '';
    return DateFormat('dd/MM/yyyy', locale).format(dt);
  }

  /// Formats Date readable: Sep 12, 2026
  static String formatDateMedium(dynamic input, {String locale = 'en'}) {
    final dt = input is String ? parse(input) : (input is DateTime ? input.toLocal() : null);
    if (dt == null) return '';
    return DateFormat.yMMMd(locale).format(dt);
  }

  /// Formats Time only: 11:45 PM
  static String formatTime(dynamic input, {String locale = 'en'}) {
    final dt = input is String ? parse(input) : (input is DateTime ? input.toLocal() : null);
    if (dt == null) return '';
    return DateFormat.jm(locale).format(dt);
  }

  /// Formats relative time: Just now, 5m ago, 2h ago, 3d ago
  static String formatRelative(dynamic input) {
    final dt = input is String ? parse(input) : (input is DateTime ? input.toLocal() : null);
    if (dt == null) return '';

    final now = DateTime.now();
    final difference = now.difference(dt);

    if (difference.inSeconds < 60) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    return formatDateMedium(dt);
  }
}
