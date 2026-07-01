# Lorofy - Ứng dụng tập trung & Chặn ứng dụng gây xao nhãng

Lorofy là ứng dụng giúp tăng hiệu suất làm việc và học tập bằng cách chặn các ứng dụng, website gây xao nhãng theo thời gian thực hoặc theo lịch trình, được xây dựng trên nền tảng **Flutter** và **Supabase**.

---

## 🚀 Công nghệ sử dụng (Tech Stack)

| Hạng mục | Công nghệ | Ghi chú |
|---|---|---|
| **Framework** | Flutter (Kênh Stable mới nhất) | Dart 3.x, sound null-safety bắt buộc |
| **Backend** | **Supabase** | Auth, Postgres DB, Realtime, Storage, Edge Functions |
| **State Management** | **Riverpod 2.x** (`riverpod_generator`) | Chuẩn hiện đại, testable, giảm boilerplate |
| **Routing** | **go_router** | Chuẩn declarative routing của Flutter |
| **Local DB / Cache** | **Drift** (SQLite) hoặc **Hive** | Lưu session offline, cache leaderboard, lịch sử chặn |
| **Push Notification** | Supabase + Firebase Cloud Messaging (FCM) | Gửi thông báo nhắc nhở lịch trình, streak sắp mất |
| **App Blocking (Android)** | `UsageStatsManager` + Foreground Service | Chỉ chạy khi phiên tập trung active, poll thưa để tiết kiệm pin |
| **App Blocking (iOS)** | Apple **Screen Time API** | Gồm `FamilyControls`, `DeviceActivity`, `ManagedSettings` viết native Swift |

---

## 🏗️ Kiến trúc dự án (Architecture)

Dự án tuân thủ mô hình **Feature-first Clean Architecture** kết hợp với hệ thống UI **Atomic Design** sử dụng bộ Cupertino Theme mượt mà như iOS trên cả hai nền tảng.

### Cấu trúc thư mục `lib/`

```
lib/
├── core/                           # Cấu hình dùng chung
│   ├── theme/                      # Design tokens (màu, spacing, radius) & Cupertino Theme
│   ├── router/                     # Định tuyến go_router
│   ├── constants/                  # Hằng số toàn cục
│   ├── utils/                      # Công cụ tiện ích
│   ├── errors/                     # Xử lý lỗi hệ thống
│   └── shared_domain/              # Entity/Repository dùng chung giữa >= 2 feature
├── design_system/                  # Hệ thống ATOMIC DESIGN (không chứa logic nghiệp vụ)
│   ├── atoms/                      # AppButton, AppTextField, AppIcon, AppSwitch, AppAvatar...
│   ├── molecules/                  # SearchBar (icon+field), StatChip (icon+số), TimerControl...
│   ├── organisms/                  # FocusSessionCard, LeaderboardRowList, StreakCalendar...
│   └── templates/                  # Bố cục khung màn hình (TabScaffoldTemplate, DashboardTemplate...)
├── features/                       # Quản lý theo từng module tính năng (Presentation - Domain - Data)
│   ├── auth/                       # Đăng ký, đăng nhập qua Supabase Auth
│   ├── focus_session/              # Phiên tập trung nhanh (Home / Quick Focus)
│   ├── blocking/                   # Cấu hình chặn App/Website
│   ├── scheduled/                  # Đặt lịch chặn tự động (hỗ trợ RRULE)
│   ├── leaderboard/                # Bảng xếp hạng bạn bè & tuần (Realtime Supabase)
│   ├── profile/                    # Thông tin cá nhân & Thống kê biểu đồ (fl_chart)
│   └── gamification/               # Hệ thống điểm thưởng, mở khóa vật phẩm/avatar
└── main.dart                       # Entry point ứng dụng
```

---

## 📊 Supabase Database Schema

Hệ thống cơ sở dữ liệu Postgres sử dụng các bảng và view chính sau:
- **`profiles`**: Lưu thông tin mở rộng của user (username, avatar_url, tổng số phút tập trung, streak hiện tại, điểm rank).
- **`focus_sessions`**: Ghi nhận lịch sử các phiên tập trung và trạng thái hoàn thành (`completed`, `failed`, `cancelled`).
- **`scheduled_sessions`**: Quản lý lịch trình đặt trước định kỳ theo định dạng chuẩn RRULE.
- **`blocked_apps`**: Danh sách cấu hình các ứng dụng cần khóa của từng tài khoản.
- **`friendships`**: Mối quan hệ bạn bè phục vụ cho việc so sánh điểm trên bảng xếp hạng xã hội.
- **`leaderboard_weekly` (View)**: Tổng hợp tự động số phút tập trung của mỗi người dùng trong 7 ngày gần nhất.

---

## 🛡️ Cơ chế chặn app (Blocking Strategy)

Để tối ưu hóa thời lượng pin và tài nguyên thiết bị, Lorofy tuân thủ nguyên tắc: **Để hệ điều hành làm việc nặng, app chỉ cấu hình rồi "ngủ"**.

### 1. iOS (Screen Time Framework)
- Sử dụng `FamilyControls` để cho người dùng chọn ứng dụng/danh mục cần chặn qua giao diện hệ thống.
- Sử dụng `ManagedSettings` để áp dụng "Shield" (màn chắn) ngay lập tức khi bắt đầu phiên mà không cần tiến trình nền.
- Sử dụng `DeviceActivity` (và `DeviceActivityMonitorExtension` riêng biệt giới hạn 6MB RAM) để hệ thống tự động kích hoạt/hủy kích hoạt shield theo lịch trình chính xác.

### 2. Android (UsageStatsManager + Foreground Service ngắn hạn)
- Không dùng `AccessibilityService` làm phương án chính để tránh cảnh báo bảo mật từ Google Play.
- Sử dụng `UsageStatsManager` kết hợp Foreground Service có thời gian sống giới hạn (chỉ chạy trong lúc có phiên tập trung active). Tần suất kiểm tra ứng dụng foreground được tối ưu hóa ở mức 1-2 giây/lần.
- Sử dụng `WorkManager` để hẹn giờ tự động bật/tắt blocking đúng giờ, không duy trì wake lock khi màn hình tắt để tránh hao pin.

---

## 🛠️ Hướng dẫn cài đặt & Khởi chạy

### 1. Chuẩn bị môi trường
- Flutter SDK (bản Stable mới nhất).
- Đã cài đặt Android SDK (cho Android) / Xcode (cho iOS).
- Một dự án Supabase đã khởi tạo sẵn database schema.

### 2. Thiết lập dự án
```bash
# Clone dự án về máy
git clone <repository_url>
cd lorofy

# Cài đặt các thư viện/packages cần thiết
flutter pub get
```

### 3. Sinh mã tự động (Build Runner)
Dự án sử dụng code generator cho Riverpod, Freezed, và Json Serializable. Hãy chạy lệnh dưới đây để sinh code tự động:
```bash
dart run build_runner build --delete-conflicting-outputs
```

### 4. Cấu hình & Tạo App Launcher Icons
Nếu thay đổi logo gốc ở `assets/logos/lorofy.png`, cập nhật lại launcher icon bằng cách chạy:
```bash
dart run flutter_launcher_icons
```

### 5. Chạy ứng dụng
```bash
flutter run
```