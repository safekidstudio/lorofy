# Lorofy - Ứng dụng tập trung & Chặn ứng dụng gây xao nhãng

Lorofy là ứng dụng giúp tăng hiệu suất làm việc và học tập bằng cách chặn các ứng dụng, website gây xao nhãng theo thời gian thực hoặc theo lịch trình, được xây dựng trên nền tảng **Flutter** và **Java (Spring Boot) Backend + PostgreSQL**.

---

## 🚀 Công nghệ sử dụng (Tech Stack)

| Hạng mục | Công nghệ | Ghi chú |
|---|---|---|
| **Framework** | Flutter (Kênh Stable mới nhất) | Dart 3.x, sound null-safety bắt buộc |
| **Backend** | **Java (Spring Boot)** | JWT Authentication, Spring Security, Spring Data JPA |
| **Database** | **PostgreSQL** | Cơ sở dữ liệu quan hệ lưu trữ phiên tập trung & profiles |
| **State Management** | **Riverpod 2.x/3.x** (`riverpod_generator`) | Quản lý state, Dependency Injection |
| **Routing** | **go_router** | Chuẩn định tuyến của Flutter |
| **Networking** | **Dio** | Gọi HTTP REST APIs tới Java Server |
| **Local DB / Cache** | **Drift** (SQLite) hoặc **Hive** | Lưu session offline, cache token JWT |
| **Push Notification** | Firebase Cloud Messaging (FCM) | Kết nối Firebase Admin SDK từ Backend |
| **App Blocking (Android)** | `UsageStatsManager` + Foreground Service | Chỉ chạy khi phiên active để tiết kiệm pin |
| **App Blocking (iOS)** | Apple **Screen Time API** | `FamilyControls`, `DeviceActivity`, `ManagedSettings` viết bằng Swift native |

---

## 🏗️ Kiến trúc dự án (Architecture)

Dự án tuân thủ mô hình **Feature-first Clean Architecture** kết hợp với hệ thống UI **Atomic Design** sử dụng bộ Cupertino Theme mượt mà như iOS trên cả hai nền tảng.

### Cấu trúc thư mục `lib/`

```
lib/
├── core/                           # Cấu hình dùng chung
│   ├── theme/                      # Design tokens & Cupertino Theme
│   ├── router/                     # Định tuyến go_router
│   ├── network/                    # Dio Client & cấu hình API Interceptor
│   ├── constants/                  # Hằng số toàn cục
│   ├── utils/                      # Công cụ tiện ích
│   ├── errors/                     # Xử lý lỗi hệ thống
│   └── shared_domain/              # Entity/Repository dùng chung giữa >= 2 feature
├── design_system/                  # Hệ thống ATOMIC DESIGN (không chứa logic nghiệp vụ)
│   ├── atoms/                      # AppButton, AppTextField, AppIcon, AppSwitch, AppAvatar...
│   ├── molecules/                  # SearchBar, StatChip, TimerControl...
│   ├── organisms/                  # FocusSessionCard, LeaderboardRowList, StreakCalendar...
│   └── templates/                  # Bố cục khung màn hình (DashboardTemplate...)
├── features/                       # Quản lý theo từng module tính năng
│   ├── auth/                       # Đăng ký, đăng nhập & xử lý JWT
│   ├── focus_session/              # Phiên tập trung nhanh (Home / Quick Focus)
│   ├── blocking/                   # Cấu hình chặn App/Website
│   ├── scheduled/                  # Đặt lịch chặn tự động
│   ├── leaderboard/                # Bảng xếp hạng bạn bè (WebSockets STOMP)
│   ├── profile/                    # Thông tin cá nhân & Thống kê biểu đồ
│   └── gamification/               # Điểm thưởng, mở khóa vật phẩm
└── main.dart                       # Entry point ứng dụng
```

---

## 📊 Database Schema (PostgreSQL)

Hệ thống cơ sở dữ liệu Postgres sử dụng các bảng chính sau:
- **`profiles`**: Lưu thông tin mở rộng của user (username, avatar_url, tổng số phút tập trung, streak hiện tại, điểm rank).
- **`focus_sessions`**: Ghi nhận lịch sử các phiên tập trung và trạng thái hoàn thành (`completed`, `failed`, `cancelled`).
- **`scheduled_sessions`**: Quản lý lịch trình đặt trước định kỳ theo định dạng chuẩn RRULE.
- **`blocked_apps`**: Danh sách cấu hình các ứng dụng cần khóa của từng tài khoản.
- **`friendships`**: Mối quan hệ bạn bè phục vụ cho việc so sánh điểm trên bảng xếp hạng xã hội.

---

## 🛡️ Cơ chế chặn app (Blocking Strategy)

*(Giữ nguyên cơ chế native iOS Screen Time và Android UsageStatsManager)*

---

## 🛠️ Hướng dẫn cài đặt & Khởi chạy (Client)

### 1. Chuẩn bị môi trường
- Flutter SDK (bản Stable mới nhất).
- Đã cài đặt Android SDK / Xcode.
- Backend Java Spring Boot đã chạy (local hoặc deploy lên cloud).

### 2. Thiết lập dự án
```bash
# Clone dự án về máy
git clone <repository_url>
cd lorofy

# Cài đặt các thư viện/packages cần thiết
flutter pub get
```

### 3. Sinh mã tự động (Build Runner)
```bash
dart run build_runner build --delete-conflicting-outputs
```

### 4. Chạy ứng dụng
```bash
flutter run
```