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

Dự án tuân thủ mô hình **Feature-first Clean Architecture** kết hợp với hệ thống UI components dùng chung mượt mà theo Cupertino Design (iOS).

### Cấu trúc thư mục `lib/`

```
lib/
├── core/                           # Cấu hình hệ thống dùng chung toàn ứng dụng
│   ├── config/                     # Đọc cấu hình môi trường qua --dart-define
│   ├── constants/                  # Hằng số toàn cục (AppConstants)
│   ├── errors/                     # Xử lý ngoại lệ & thông điệp lỗi
│   ├── network/                    # Dio HTTP client, Interceptors xử lý auth/token
│   ├── router/                     # Cấu hình go_router định tuyến màn hình
│   ├── storage/                    # Lưu trữ cục bộ (JWT, cache)
│   └── theme/                      # Design tokens, màu sắc & kiểu chữ (AppTheme)
├── components/                     # Hệ thống UI components dùng chung
│   ├── layout/                     # Bố cục trang (AppHeader, PageWrapper)
│   ├── ui/                         # Các widget giao diện cơ bản (Button, Input, AppAvatar...)
│   └── shared/                     # Các widget dùng chung giữa các màn hình
├── features/                       # Quản lý theo từng module tính năng (Feature-first Clean Architecture)
│   ├── auth/                       # Đăng ký, đăng nhập, quên mật khẩu
│   ├── explore/                    # Khám phá các nội dung học tập, nhạc tập trung
│   ├── focus/                      # Quản lý phiên tập trung và chặn ứng dụng
│   ├── home/                       # Màn hình chính của ứng dụng
│   ├── mascot/                     # Chọn lựa và tương tác với thú cưng đồng hành
│   ├── profile/                    # Thông tin cá nhân, biểu đồ thống kê & thông báo
│   └── settings/                   # Cấu hình ứng dụng cài đặt chung
└── main.dart                       # Entry point khởi tạo và chạy ứng dụng
```

Mỗi module trong `features/` được chia thành 3 lớp chuẩn:
1. **Domain:** Chứa entities, repository interfaces đại diện cho nghiệp vụ cốt lõi.
2. **Data:** Chứa datasources (remote/local) và các triển khai cụ thể của repositories.
3. **Presentation:** Chứa UI pages, widgets và Riverpod providers để quản lý trạng thái.

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
- Flutter SDK (phiên bản Stable mới nhất hỗ trợ `--dart-define-from-file`).
- Đã cấu hình đầy đủ Android SDK (Android Studio) / Xcode (macOS).
- Backend Java Spring Boot đã sẵn sàng (ở môi trường cục bộ hoặc trên cloud).

### 2. Thiết lập dự án
```bash
# Cài đặt các thư viện/packages cần thiết
flutter pub get
```

### 3. Sinh mã tự động (Build Runner)
```bash
# Chạy build runner một lần để sinh các provider Riverpod, routes, JSON converters
dart run build_runner build --delete-conflicting-outputs

# Hoặc chạy watcher tự động biên dịch khi file thay đổi trong lúc code
dart run build_runner watch --delete-conflicting-outputs
```

### 4. Môi trường & Khởi chạy ứng dụng
Dự án sử dụng file cấu hình JSON được định nghĩa tại thư mục `configs/` để phân tách giữa môi trường Phát triển (**Development**) và Sản xuất (**Production**).

#### 🔹 Môi trường Phát triển (Development)
Sử dụng file cấu hình: [env.dev.json](configs/env.dev.json) (kết nối Backend cục bộ tại localhost).

* **Khởi chạy (Run):**
  ```bash
  flutter run --dart-define-from-file=configs/env.dev.json
  ```
* **Build (Android Debug APK):**
  ```bash
  flutter build apk --debug --dart-define-from-file=configs/env.dev.json
  ```
* **Build (iOS Simulator/Debug):**
  ```bash
  flutter build ios --debug --dart-define-from-file=configs/env.dev.json
  ```

#### 🔸 Môi trường Sản xuất (Production)
Sử dụng file cấu hình: [env.json](configs/env.json) (kết nối Backend chính thức tại cloud).

* **Khởi chạy (Run Release):**
  ```bash
  flutter run --release --dart-define-from-file=configs/env.json
  ```
* **Build Android APK (Release):**
  ```bash
  flutter build apk --release --dart-define-from-file=configs/env.json
  ```
* **Build Android App Bundle (Release - dùng tải lên CH Play):**
  ```bash
  flutter build appbundle --release --dart-define-from-file=configs/env.json
  ```
* **Build iOS IPA (Release - dùng tải lên App Store):**
  ```bash
  flutter build ipa --release --dart-define-from-file=configs/env.json
  ```
```