# Kế hoạch phát triển app Lorofy (Updated: Java Backend + PostgreSQL)
### Flutter + Java (Spring Boot) + PostgreSQL — Chia theo Phase

---

## 1. Tech Stack tổng quan

| Hạng mục | Công nghệ | Ghi chú |
|---|---|---|
| Framework | Flutter (kênh stable mới nhất) | Dart 3.x, null-safety, sound null-safety bắt buộc |
| Backend | **Java (Spring Boot)** | Framework chuẩn doanh nghiệp, tin cậy, bảo mật và hiệu năng cao |
| Database | **PostgreSQL** | Neon.tech (Serverless) / Supabase Postgres (Dùng làm DB) |
| State management | **Riverpod 2.x/3.x** (code-gen: `riverpod_generator`) | Quản lý state mạnh mẽ, hỗ trợ Dependency Injection |
| Routing | **go_router** | Chuẩn định tuyến declarative routing |
| Local DB / cache | **Drift** (SQLite) hoặc **Hive** | Lưu session offline, cache token, lịch sử chặn |
| Networking | **Dio** (HTTP Client) | Thay thế cho Supabase SDK, hỗ trợ Interceptor, retry, logging |
| DI / codegen | `riverpod_generator`, `freezed`, `json_serializable` | Giảm boilerplate, bảo toàn an toàn kiểu dữ liệu |
| Push notification | Firebase Cloud Messaging (FCM) | Tích hợp thư viện Java FCM Admin SDK phía Backend |
| App blocking (Android) | `usage_stats` + `flutter_foreground_task` + Native Platform Channel | Dùng `UsageStatsManager` kết hợp Foreground Service |
| App blocking (iOS) | Apple **Screen Time API** | Dùng native Swift qua Platform Channel (`FamilyControls`, `DeviceActivity`) |
| Development Server | Local / Koyeb / Render / Railway | Deploy thử nghiệm Java Jar & DB PostgreSQL miễn phí |

---

## 2. UI System: Cupertino Theme + Atomic Design

### 2.1 Vì sao Cupertino thay vì Material

Để app "mượt như iOS" trên cả 2 nền tảng, không dùng `MaterialApp` mặc định mà build layer adaptive riêng:

- Dùng `CupertinoApp.router` làm gốc kết hợp với `go_router`
- Toàn bộ widget cơ bản dùng `Cupertino*` (CupertinoButton, CupertinoTextField, CupertinoSwitch...)
- Transition mặc định dùng `CupertinoPageRoute` (hiệu ứng vuốt-đẩy ngang chuẩn iOS)
- Font: Chọn font tương đồng Cupertino như `Inter` cấu hình trong `CupertinoThemeData.textTheme`

```dart
CupertinoApp.router(
  theme: const CupertinoThemeData(
    primaryColor: AppColors.primary,
    brightness: Brightness.light,
    textTheme: CupertinoTextThemeData(...),
  ),
  routerConfig: appRouter,
)
```

Design tokens tách riêng thành file `core/theme/design_tokens.dart` — đây sẽ là nguồn duy nhất mọi atom tham chiếu tới.

### 2.2 Cấu trúc theo Atomic Design & Feature-First

Tổ chức theo **feature-first** — mỗi feature tự chứa đủ 3 tầng `data/domain/presentation` của riêng nó:

```
lib/
├── core/
│   ├── theme/
│   │   ├── design_tokens.dart      # màu, spacing, radius, typography scale
│   │   └── cupertino_theme.dart
│   ├── router/
│   │   └── app_router.dart         # Cấu hình định tuyến
│   ├── network/
│   │   ├── dio_client.dart         # HTTP Client với Interceptors (gắn JWT)
│   │   └── api_endpoints.dart      # Đường dẫn endpoint API Java
│   ├── constants/
│   ├── utils/
│   └── errors/
├── design_system/                   # ATOMIC DESIGN UI
│   ├── atoms/                       # app_button, app_text_field, app_badge...
│   ├── molecules/                   # search_bar, stat_chip, timer_control...
│   ├── organisms/                   # focus_session_card, leaderboard_row_list...
│   └── templates/                   # dashboard_template, form_page_template...
├── features/                        # Lắp ráp UI & Logic nghiệp vụ
│   ├── auth/
│   │   ├── data/
│   │   │   ├── datasources/           # Gọi REST API qua DioClient
│   │   │   ├── models/                # Request/Response DTO
│   │   │   └── repositories/          # Implement repository interface
│   │   ├── domain/
│   │   │   ├── entities/              # Thực thể User
│   │   │   ├── repositories/          # Interface hợp đồng (contract)
│   │   │   └── usecases/              # Logic nghiệp vụ độc lập UI
│   │   └── presentation/
│   │       ├── providers/             # Notifier cho state auth (JWT handling)
│   │       └── pages/                 # Giao diện chính
│   ├── focus_session/
│   ├── blocking/
│   ├── scheduled/
│   ├── leaderboard/
│   ├── profile/
│   └── gamification/
└── main.dart
```

---

## 3. Database Schema (PostgreSQL - v1)

```sql
-- profiles / users
create table profiles (
  id uuid primary key default gen_random_uuid(),
  user_id varchar(255) unique not null, -- Mapped từ User ID của auth system
  username varchar(50) unique not null,
  avatar_url text,
  total_focus_minutes int default 0,
  current_streak int default 0,
  longest_streak int default 0,
  rank_points int default 0,
  created_at timestamptz default now()
);

-- focus_sessions
create table focus_sessions (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid references profiles(id),
  category varchar(50),               -- Học tập / Công việc / Đọc sách...
  block_mode varchar(20),              -- light / medium / strict
  planned_minutes int,
  actual_minutes int,
  status varchar(20),                 -- completed / failed / cancelled
  started_at timestamptz,
  ended_at timestamptz,
  created_at timestamptz default now()
);

-- scheduled_sessions
create table scheduled_sessions (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid references profiles(id),
  title varchar(100),
  template_type varchar(30),          -- custom / pomodoro_classic ...
  recurrence_rule text,               -- RRULE format
  start_time time,
  end_time time,
  is_active bool default true,
  created_at timestamptz default now()
);

-- blocked_apps
create table blocked_apps (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid references profiles(id),
  app_identifier varchar(255) not null, -- bundle id / package name
  app_name varchar(100),
  block_mode varchar(20)
);

-- friendships
create table friendships (
  profile_id uuid references profiles(id),
  friend_id uuid references profiles(id),
  status varchar(20),                 -- pending / accepted
  primary key (profile_id, friend_id)
);
```

---

## 4. Các Phase phát triển

### **Phase 0 — Nền tảng & Setup (1-2 tuần)**
Mục tiêu: Dựng khung dự án cho cả Flutter Client và Java Backend.

*   **Flutter Client:**
    - Khởi tạo dự án, cấu hình Riverpod + go_router + freezed
    - Cài đặt và cấu hình `DioClient` (Xử lý JWT Interceptor, Log interceptor)
    - Thiết lập Design System theo Atomic Design: dựng `CupertinoThemeData` + design tokens + build 4-5 atoms cơ bản (button, text field, badge, avatar)
*   **Java Backend (Spring Boot):**
    - Khởi tạo dự án Spring Boot (Spring Web, Spring Data JPA, Spring Security, Flyway/Liquibase)
    - Thiết lập kết nối PostgreSQL (Neon/Local)
    - Cấu hình Spring Security với JWT (Tạo/Verify token)
*   **Native Prototyping:**
    - Android: Test `UsageStatsManager` nhận diện app foreground.
    - iOS: Test thử nghiệm cấu hình xin quyền `FamilyControls`.

---

### **Phase 1 — Authentication & Onboarding (1 tuần)**
*   **Backend (Java):**
    - API Register, Login, Refresh Token (trả về JWT Access Token & Refresh Token)
    - Tự động tạo bản ghi `profiles` tương ứng khi đăng ký tài khoản thành công
*   **Flutter Client:**
    - Màn hình đăng ký/đăng nhập Cupertino
    - Quản lý token thông qua secure storage và Riverpod
    - Onboarding flow: xin quyền Accessibility (Android) / Screen Time (iOS)

---

### **Phase 2 — Home (Quick Focus) — Core Focus Engine (2 tuần)**
*   **Backend (Java):**
    - API Create & Update `focus_sessions`
*   **Flutter Client:**
    - Giao diện chọn thời lượng, chủ đề phiên, chế độ chặn
    - Timer engine chạy ngầm bằng `flutter_foreground_task`
    - Bật/tắt chặn app native khi bắt đầu/kết thúc phiên tập trung
    - Gọi API Java BE đồng bộ dữ liệu phiên tập trung

---

### **Phase 3 — App/Website Blocking nâng cao (1.5 tuần)**
*   **Backend (Java):**
    - API CRUD danh sách `blocked_apps` theo người dùng
*   **Flutter Client:**
    - Màn hình chọn ứng dụng cần chặn (Android đọc danh sách cài đặt, iOS qua FamilyActivityPicker)
    - Chặn website bằng cách dựng VPN nội bộ (DNS Filter)
    - Cơ chế "Break glass" phạt điểm tích hợp với API Java BE

---

### **Phase 4 — Scheduled + Pomodoro Templates (1.5 tuần)**
*   **Backend (Java):**
    - API CRUD cho `scheduled_sessions` (lưu trữ RRULE và phân tích thời gian chạy)
*   **Flutter Client:**
    - Lập lịch định kỳ bằng package `flutter_local_notifications`
    - Đồng bộ hóa lịch trình bằng `WorkManager` (Android) / `BGTaskScheduler` (iOS) để tự động kích hoạt tính năng chặn đúng giờ

---

### **Phase 5 — Leaderboard & Social (1.5 tuần)**
*   **Backend (Java):**
    - API thống kê bảng xếp hạng hàng tuần theo group/bạn bè (truy vấn SQL tối ưu hóa)
    - Tích hợp WebSockets/STOMP để cập nhật realtime bảng xếp hạng khi có người hoàn thành phiên
*   **Flutter Client:**
    - Kết nối WebSockets nhận thông báo realtime
    - Hiển thị bảng xếp hạng Cupertino mượt mà

---

### **Phase 6 — Profile, Stats & Gamification (1.5 tuần)**
*   **Backend (Java):**
    - API phân tích thống kê (tổng phút, streak) và trả về dữ liệu biểu đồ
    - API quản lý phần thưởng / avatar / shop
*   **Flutter Client:**
    - Vẽ biểu đồ thống kê dùng `fl_chart`
    - Shop đổi điểm thưởng lấy avatar/item

---

### **Phase 7 — Polish, Testing & Release (2 tuần)**
*   **Backend (Java):**
    - Setup CI/CD deploy JAR lên Cloud (Render/Koyeb)
    - Kết nối Firebase Admin SDK để gửi push notification
*   **Flutter Client:**
    - Tích hợp Push notification (FCM)
    - Test tổng thể, tối ưu performance & submit App Store/Play Store

---

## 5. Chiến lược chặn app — Hướng đi tối ưu

*(Giữ nguyên phân tích kỹ thuật của iOS Screen Time Framework & Android UsageStatsManager như bản kế hoạch gốc)*
