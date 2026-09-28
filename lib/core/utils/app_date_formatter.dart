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
  static String formatDateTime(dynamic input) {
    final dt = input is String ? parse(input) : (input is DateTime ? input.toLocal() : null);
    if (dt == null) return '';
    try {
      return DateFormat('dd/MM/yyyy - hh:mm a').format(dt);
    } catch (_) {
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    }
  }

  /// Formats Date only: dd/MM/yyyy (e.g. 12/09/2026)
  static String formatDate(dynamic input) {
    final dt = input is String ? parse(input) : (input is DateTime ? input.toLocal() : null);
    if (dt == null) return '';
    try {
      return DateFormat('dd/MM/yyyy').format(dt);
    } catch (_) {
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    }
  }

  /// Formats Date with dots: dd.MM.yyyy (e.g. 20.09.2026)
  static String formatDotDate(dynamic input) {
    final dt = input is String ? parse(input) : (input is DateTime ? input.toLocal() : null);
    if (dt == null) return '';
    try {
      return DateFormat('dd.MM.yyyy').format(dt);
    } catch (_) {
      return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
    }
  }

  /// Formats Date & Time with dots: dd.MM.yyyy • HH:mm (e.g. 20.09.2026 • 14:30)
  static String formatDotDateTime(dynamic input) {
    final dt = input is String ? parse(input) : (input is DateTime ? input.toLocal() : null);
    if (dt == null) return '';
    try {
      return DateFormat('dd.MM.yyyy • HH:mm').format(dt);
    } catch (_) {
      final hourStr = dt.hour.toString().padLeft(2, '0');
      final minStr = dt.minute.toString().padLeft(2, '0');
      return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year} • $hourStr:$minStr';
    }
  }

  /// Formats Date readable: Sep 12, 2026
  static String formatDateMedium(dynamic input) {
    final dt = input is String ? parse(input) : (input is DateTime ? input.toLocal() : null);
    if (dt == null) return '';
    try {
      return DateFormat.yMMMd().format(dt);
    } catch (_) {
      return formatDate(dt);
    }
  }

  /// Formats Time only: 11:45 PM
  static String formatTime(dynamic input) {
    final dt = input is String ? parse(input) : (input is DateTime ? input.toLocal() : null);
    if (dt == null) return '';
    try {
      return DateFormat.jm().format(dt);
    } catch (_) {
      final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final period = dt.hour >= 12 ? 'PM' : 'AM';
      return '$hour:${dt.minute.toString().padLeft(2, '0')} $period';
    }
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
