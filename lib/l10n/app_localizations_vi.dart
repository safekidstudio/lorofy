// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appName => 'Lorofy';

  @override
  String get settings => 'Cài đặt';

  @override
  String get appPreferences => 'TÙY CHỌN ỨNG DỤNG';

  @override
  String get notifications => 'THÔNG BÁO';

  @override
  String get language => 'Ngôn ngữ';

  @override
  String get languageEnglish => 'Tiếng Anh';

  @override
  String get languageVietnamese => 'Tiếng Việt';

  @override
  String get languageSystem => 'Theo hệ thống';

  @override
  String get pomodoroRules => 'Quy tắc Pomodoro';

  @override
  String get appBlockerRules => 'Quy tắc Chặn ứng dụng';

  @override
  String get focusReminders => 'Nhắc nhở Tập trung';

  @override
  String get focusRemindersDescription =>
      'Nhắc nhở trước khi phiên tập trung bắt đầu';

  @override
  String get restoreStreak => 'Khôi phục Chuỗi';

  @override
  String saveYourStreak(int count) {
    return 'Cứu chuỗi $count ngày của bạn!';
  }

  @override
  String get recoverStreakDescription =>
      'Khôi phục tiến trình bằng khiên bảo vệ hoặc tiền vàng.';

  @override
  String get streakFreezeShield => 'Khiên Đóng băng Chuỗi';

  @override
  String availableShields(int count) {
    return 'Hiện có: $count khiên';
  }

  @override
  String get noShields => 'Chưa có khiên đóng băng trong kho';

  @override
  String useGoldCoins(int cost) {
    return 'Dùng $cost Tiền vàng';
  }

  @override
  String coinBalance(int balance) {
    return 'Số dư: $balance xu';
  }

  @override
  String get focusNowToEarn => 'Tập trung ngay để kiếm Xu 🎯';

  @override
  String get needMoreCoinsTip =>
      'Bạn cần thêm xu để khôi phục. Hãy hoàn thành các phiên tập trung để kiếm Tiền vàng!';

  @override
  String get cancel => 'Hủy';

  @override
  String get save => 'Lưu';

  @override
  String get confirm => 'Xác nhận';

  @override
  String get strictMode => 'Chế độ Nghiêm khắc';

  @override
  String get mediumMode => 'Chế độ Vừa phải';

  @override
  String get mediumModeDescription =>
      'Khi tập trung, chỉ ứng dụng được phép mới có thể mở';

  @override
  String get strictModeDescription =>
      'Khi tập trung, mở ứng dụng khác sẽ làm héo cây';

  @override
  String get selectAllowedApps => 'Chọn ứng dụng được phép';

  @override
  String get myActivities => 'Lịch sử hoạt động';

  @override
  String get all => 'Tất cả';

  @override
  String get today => 'Hôm nay';

  @override
  String get week => 'Tuần này';

  @override
  String get completed => 'Hoàn thành';

  @override
  String get failed => 'Thất bại';

  @override
  String get noActivitiesFound => 'Không tìm thấy hoạt động nào';

  @override
  String get tryChangingFilters =>
      'Thử thay đổi bộ lọc hoặc bắt đầu một phiên tập trung mới.';
}
