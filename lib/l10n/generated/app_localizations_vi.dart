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
  String get common_month => 'Tháng này';

  @override
  String get common_day => 'Ngày';

  @override
  String get common_update => 'Cập nhật';

  @override
  String get common_retry => 'Thử lại';

  @override
  String get common_viewMore => 'Xem thêm';

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
  String get home_congratulationsTitle => '🎉 Chúc mừng!';

  @override
  String home_sessionCompletedInactive(int minutes) {
    return 'Bạn đã hoàn thành phiên tập trung $minutes phút khi ứng dụng không hoạt động. Điểm và chuỗi của bạn đã được cộng!';
  }

  @override
  String get home_awesome => 'Tuyệt vời';

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
  String get focus_keepGoing => 'Tiếp tục tập trung';

  @override
  String get focus_giveUpConfirmTitle => 'Muốn bỏ cuộc rồi sao?';

  @override
  String get focus_cancelSessionConfirmTitle => 'Hủy phiên tập trung?';

  @override
  String get focus_gracePeriodDesc =>
      'Bạn mới bắt đầu chưa đầy 1 phút. Hủy lúc này sẽ KHÔNG bị trừ điểm.';

  @override
  String get focus_giveUpBtn => 'Tôi bỏ cuộc...';

  @override
  String get focus_cancelSessionBtn => 'Hủy phiên';

  @override
  String get focus_gracePeriodProtection => 'Bảo vệ thời gian đầu';

  @override
  String get focus_noPointsDeducted => 'Không bị trừ điểm';

  @override
  String get focus_sessionProgressReset => 'Đặt lại tiến trình phiên';

  @override
  String get focus_sessionNotLogged => 'Phiên sẽ không được ghi vào thống kê';

  @override
  String get focus_treeWithered => 'Cây tập trung héo khô';

  @override
  String get focus_growingTreeWillDie => 'Cây đang lớn của bạn sẽ bị chết';

  @override
  String get focus_rankPointsDeducted => 'Bị trừ điểm xếp hạng';

  @override
  String focus_modePenalty(String mode) {
    return 'Hình phạt chế độ $mode';
  }

  @override
  String get focus_dailyStreakRisk => 'Nguy cơ mất chuỗi hàng ngày';

  @override
  String get focus_streakResetTip =>
      'Chuỗi sẽ tính lại từ đầu nếu hôm nay không có phiên nào';

  @override
  String get focus_wow => 'Tuyệt vời!';

  @override
  String get focus_plantGrownUp => 'Cây của bạn đã trưởng thành';

  @override
  String focus_dayStreak(int count) {
    return 'Chuỗi $count ngày!';
  }

  @override
  String get focus_plusOneToday => '+1 Hôm nay 🎉';

  @override
  String get focus_haveARest => 'Nghỉ ngơi nào';

  @override
  String get focus_plantDead => 'Ôi không, cây của bạn đã héo rũ';

  @override
  String get focus_restart => 'Bắt đầu lại';

  @override
  String get focus_backToHome => 'Về Trang chủ';

  @override
  String get explore_title => 'Khám phá';

  @override
  String get explore_todayFocus => 'TT Hôm nay';

  @override
  String get explore_allFocus => 'Tổng Tập trung';

  @override
  String get explore_todayKill => 'Thất bại Hôm nay';

  @override
  String get explore_allKill => 'Tổng Thất bại';

  @override
  String get explore_avgFocusTime => 'Thời gian TT\ntrung bình';

  @override
  String get explore_avgKillTime => 'Thời gian héo\ntrung bình';

  @override
  String explore_mins(int count) {
    return '$count phút';
  }

  @override
  String get explore_recentFocus => 'Hoạt động gần đây';

  @override
  String get explore_dailyAverage => 'Trung bình hàng ngày ';

  @override
  String get explore_noFocusDataWeek => 'Chưa có dữ liệu tập trung tuần này 🌿';

  @override
  String get explore_focusRecord => 'Nhật ký tập trung';

  @override
  String get explore_noFocusRecordsToday => 'Chưa có nhật ký tập trung hôm nay';

  @override
  String get explore_noFocusRecordsMonth =>
      'Chưa có nhật ký tập trung trong 30 ngày qua';

  @override
  String get explore_leaderboard => 'Bảng xếp hạng';

  @override
  String get explore_noRankingsYet => 'Chưa có xếp hạng';

  @override
  String get explore_noRankingsDesc =>
      'Hãy là người đầu tiên hoàn thành phiên tập trung để vinh danh!';

  @override
  String get explore_you => 'Bạn';

  @override
  String get profile_title => 'Hồ sơ';

  @override
  String get profile_myProfile => 'Trang cá nhân';

  @override
  String get profile_myPoints => 'Điểm của tôi';

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

  @override
  String get profile_logout => 'Đăng xuất';

  @override
  String get profile_logoutConfirm => 'Bạn có chắc chắn muốn đăng xuất không?';

  @override
  String get profile_displayName => 'Tên hiển thị';

  @override
  String get profile_username => 'Tên người dùng';

  @override
  String get profile_countryRegion => 'Quốc gia / Vùng';

  @override
  String get profile_updatingAvatar => 'Đang cập nhật ảnh đại diện...';

  @override
  String get profile_avatarUpdated => 'Đã cập nhật ảnh đại diện!';

  @override
  String get profile_uploadingAvatar => 'Đang tải lên ảnh đại diện...';

  @override
  String get profile_avatarUploaded => 'Đã tải lên ảnh đại diện!';

  @override
  String get profile_failedUpdateAvatar => 'Cập nhật ảnh đại diện thất bại';

  @override
  String get profile_failedUploadAvatar => 'Tải lên ảnh đại diện thất bại';

  @override
  String get profile_profileUpdated => 'Đã cập nhật thông tin!';

  @override
  String get profile_failedUpdateProfile => 'Cập nhật thông tin thất bại';
}
