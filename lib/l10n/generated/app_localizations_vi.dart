// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get common_appName => 'Lorofy';

  @override
  String get common_cancel => 'Hủy';

  @override
  String get common_save => 'Lưu';

  @override
  String get common_confirm => 'Xác nhận';

  @override
  String get common_all => 'Tất cả';

  @override
  String get common_today => 'Hôm nay';

  @override
  String get common_week => 'Tuần này';

  @override
  String get settings_title => 'Cài đặt';

  @override
  String get settings_appPreferences => 'TÙY CHỌN ỨNG DỤNG';

  @override
  String get settings_notifications => 'THÔNG BÁO';

  @override
  String get settings_language => 'Ngôn ngữ';

  @override
  String get settings_languageEnglish => 'Tiếng Anh';

  @override
  String get settings_languageVietnamese => 'Tiếng Việt';

  @override
  String get settings_languageSystem => 'Theo hệ thống';

  @override
  String get settings_pomodoroRules => 'Quy tắc Pomodoro';

  @override
  String get settings_appBlockerRules => 'Quy tắc Chặn ứng dụng';

  @override
  String get settings_focusReminders => 'Nhắc nhở Tập trung';

  @override
  String get settings_focusRemindersDesc =>
      'Nhắc nhở trước khi phiên tập trung bắt đầu';

  @override
  String get focus_strictMode => 'Chế độ Nghiêm khắc';

  @override
  String get focus_strictModeDesc =>
      'Khi tập trung, mở ứng dụng khác sẽ làm héo cây';

  @override
  String get focus_mediumMode => 'Chế độ Vừa phải';

  @override
  String get focus_mediumModeDesc =>
      'Khi tập trung, chỉ ứng dụng được phép mới có thể mở';

  @override
  String get focus_selectAllowedApps => 'Chọn ứng dụng được phép';

  @override
  String get focus_nowToEarn => 'Tập trung ngay để kiếm Xu 🎯';

  @override
  String get profile_myActivities => 'Lịch sử hoạt động';

  @override
  String get profile_completed => 'Hoàn thành';

  @override
  String get profile_failed => 'Thất bại';

  @override
  String get profile_noActivitiesFound => 'Không tìm thấy hoạt động nào';

  @override
  String get profile_tryChangingFilters =>
      'Thử thay đổi bộ lọc hoặc bắt đầu một phiên tập trung mới.';

  @override
  String get profile_restoreStreak => 'Khôi phục Chuỗi';

  @override
  String profile_saveYourStreak(int count) {
    return 'Cứu chuỗi $count ngày của bạn!';
  }

  @override
  String get profile_recoverStreakDesc =>
      'Khôi phục tiến trình bằng khiên bảo vệ hoặc tiền vàng.';

  @override
  String get profile_streakFreezeShield => 'Khiên Đóng băng Chuỗi';

  @override
  String profile_availableShields(int count) {
    return 'Hiện có: $count khiên';
  }

  @override
  String get profile_noShields => 'Chưa có khiên đóng băng trong kho';

  @override
  String profile_useGoldCoins(int cost) {
    return 'Dùng $cost Tiền vàng';
  }

  @override
  String profile_coinBalance(int balance) {
    return 'Số dư: $balance xu';
  }

  @override
  String get profile_needMoreCoinsTip =>
      'Bạn cần thêm xu để khôi phục. Hãy hoàn thành các phiên tập trung để kiếm Tiền vàng!';
}
