# Kế hoạch phát triển app Lorofy
### Flutter + Supabase — Chia theo Phase

---

## 1. Tech Stack tổng quan

| Hạng mục | Công nghệ | Ghi chú |
|---|---|---|
| Framework | Flutter (kênh stable mới nhất) | Dart 3.x, null-safety, sound null-safety bắt buộc |
| Backend | **Supabase** | Auth, Postgres DB, Realtime, Storage, Edge Functions |
| State management | **Riverpod 2.x** (code-gen: `riverpod_generator`) | Chuẩn hiện đại, testable, tránh Provider cũ/BLoC nặng nề cho scope này |
| Routing | **go_router** | Chuẩn declarative routing của Flutter team |
| Local DB / cache | **Drift** (SQLite) hoặc **Hive** | Lưu session offline, cache leaderboard, lịch sử chặn |
| Networking | `supabase_flutter` SDK (đã bọc sẵn http/realtime) | Không cần thêm Dio trừ khi gọi API ngoài |
| DI / codegen | `riverpod_generator`, `freezed`, `json_serializable` | Model an toàn kiểu, giảm boilerplate |
| Push notification | Supabase + Firebase Cloud Messaging (FCM) | Supabase không tự có push, cần FCM song song |
| App blocking (Android) | `usage_stats`, native `UsageStatsManager` qua Platform Channel, `flutter_foreground_task` | Cần Accessibility Service hoặc VPN-based blocking (tham khảo cách Forest/Opal làm) |
| App blocking (iOS) | Apple **Screen Time API** (`FamilyControls`, `DeviceActivity`, `ManagedSettings`) qua Platform Channel | Bắt buộc, Flutter không có package chính thức đủ tốt — phải viết native Swift |
| Analytics | Supabase logs + PostHog (self-host được, tôn trọng privacy) | Có thể hoãn tới Phase cuối |
| CI/CD | Codemagic hoặc GitHub Actions + Fastlane | Build/deploy tự động cho iOS & Android |
| Design system | **Cupertino** (adaptive, mượt như iOS) + custom design tokens, cấu trúc theo **Atomic Design** | Xem chi tiết mục 2 & 7 |

> ⚠️ **Lưu ý kỹ thuật quan trọng:** Việc "chặn app khác" trên iOS/Android **không** làm được bằng Flutter thuần. Đây là phần native bắt buộc (Swift cho iOS dùng Screen Time API, Kotlin cho Android dùng UsageStatsManager/AccessibilityService hoặc VPN-based DNS blocking). Cần lên kế hoạch riêng cho phần này ngay từ Phase 0.

---

## 2. UI System: Cupertino Theme + Atomic Design

### 2.1 Vì sao Cupertino thay vì Material

Để app "mượt như iOS" trên cả 2 nền tảng, không dùng `MaterialApp` mặc định mà build layer adaptive riêng:

- Dùng `CupertinoApp` làm gốc (hoặc `CupertinoApp.router` với go_router) thay vì `MaterialApp`
- Toàn bộ widget cơ bản build lại dựa trên `Cupertino*` (CupertinoButton, CupertinoTextField, CupertinoSwitch, CupertinoActivityIndicator...) thay vì Material tương ứng
- Transition mặc định dùng `CupertinoPageRoute` (hiệu ứng vuốt-đẩy ngang chuẩn iOS) — go_router hỗ trợ custom transition per-route nên set toàn bộ route dùng kiểu này
- Trên Android vẫn giữ được cảm giác native nếu cần — cân nhắc gói `flutter_platform_widgets` để tự động chọn Cupertino/Material theo platform, nhưng vì mục tiêu là "chuẩn hoá 1 style mượt như iOS trên cả 2 nền tảng" nên khuyến nghị **ép toàn bộ app dùng Cupertino look thống nhất**, không rẽ nhánh theo platform — tránh rời rạc UI và giảm effort maintain 2 bộ theme.
- Font: `SF Pro` không được phép nhúng free (Apple license), dùng font thay thế cảm giác tương đồng như `Inter` hoặc `SF Pro Display` nếu có license hợp lệ, cấu hình trong `CupertinoThemeData.textTheme`

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

Design tokens (màu, spacing, radius, shadow, typography scale) tách riêng thành file `core/theme/design_tokens.dart` — đây sẽ là nguồn duy nhất mọi atom tham chiếu tới, không hard-code giá trị trong widget.

### 2.2 Cấu trúc theo Atomic Design

Thay vì gộp UI vào từng feature, tách `shared/widgets` thành 5 tầng chuẩn Atomic Design (Atoms → Molecules → Organisms → Templates → Pages), feature module chỉ chứa logic + lắp ghép:

```
lib/
├── core/
│   ├── theme/
│   │   ├── design_tokens.dart      # màu, spacing, radius, elevation, typography scale
│   │   └── cupertino_theme.dart
│   ├── router/
│   ├── constants/
│   ├── utils/
│   └── errors/
├── design_system/                   # ATOMIC DESIGN sống ở đây, tách biệt hoàn toàn feature
│   ├── atoms/                       # thành phần nhỏ nhất, không tự chứa logic nghiệp vụ
│   │   ├── app_button.dart
│   │   ├── app_text_field.dart
│   │   ├── app_icon.dart
│   │   ├── app_badge.dart
│   │   ├── app_avatar.dart
│   │   └── app_switch.dart
│   ├── molecules/                   # kết hợp 2-3 atom thành 1 cụm có nghĩa
│   │   ├── search_bar.dart          # icon + textfield
│   │   ├── stat_chip.dart           # icon + số liệu
│   │   ├── timer_control.dart       # button + label
│   │   └── list_tile_item.dart
│   ├── organisms/                   # cụm UI hoàn chỉnh, có thể tái dùng nhiều màn
│   │   ├── focus_session_card.dart
│   │   ├── leaderboard_row_list.dart
│   │   ├── app_block_selector.dart
│   │   ├── bottom_nav_bar.dart
│   │   └── streak_calendar.dart
│   └── templates/                   # bố cục khung màn hình, chưa gắn data thật
│       ├── tab_scaffold_template.dart
│       ├── form_page_template.dart
│       └── dashboard_template.dart
├── data/
│   ├── models/
│   ├── repositories/
│   └── datasources/
│       ├── supabase_remote/
│       └── local_cache/
├── domain/
│   ├── entities/
│   └── usecases/
├── features/                        # PAGES — lắp ráp template + organism + gọi provider
│   ├── auth/
│   ├── focus_session/                # Home / Quick Focus
│   ├── blocking/
│   ├── scheduled/
│   ├── leaderboard/
│   ├── profile/
│   └── gamification/
└── main.dart

native/
├── android/   # Kotlin blocking module
└── ios/       # Swift Screen Time module (FamilyControls/ManagedSettings/DeviceActivity)
```

### 2.3 Feature-first Clean Architecture (data/domain nằm TRONG từng feature)

Với ~7 feature khá độc lập (auth, focus_session, blocking, scheduled, leaderboard, profile, gamification), tổ chức theo **feature-first** thay vì layer-first — mỗi feature tự chứa đủ 3 tầng `data/domain/presentation` của riêng nó, dễ maintain/xoá/giao việc theo module hơn:

```
lib/
├── core/
│   ├── theme/
│   │   ├── design_tokens.dart
│   │   └── cupertino_theme.dart
│   ├── router/
│   ├── constants/
│   ├── utils/
│   ├── errors/
│   ├── network/                     # supabase client init, interceptor chung
│   └── shared_domain/                # CHỈ chứa entity/repository interface dùng chung ≥2 feature
│       └── entities/
│           └── user_profile.dart     # vd: auth, profile, leaderboard đều cần
├── design_system/                    # atoms/molecules/organisms/templates — xem mục 2.2
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── models/                # freezed model, DTO map từ Supabase response
│   │   │   ├── datasources/           # gọi supabase_flutter trực tiếp
│   │   │   └── repositories/          # implement interface ở domain/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/          # abstract interface (contract)
│   │   │   └── usecases/              # SignInUseCase, SignUpUseCase...
│   │   └── presentation/
│   │       ├── providers/             # riverpod provider/notifier
│   │       ├── pages/                 # ráp template + organism từ design_system/
│   │       └── widgets/               # widget CHỈ dùng riêng cho auth, không đưa lên design_system
│   ├── focus_session/                 # Home / Quick Focus
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── blocking/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── scheduled/
│   ├── leaderboard/
│   ├── profile/
│   └── gamification/
└── main.dart

native/
├── android/   # Kotlin blocking module
└── ios/       # Swift Screen Time module (FamilyControls/ManagedSettings/DeviceActivity)
```

**Quy tắc phân định "chung" vs "riêng":**
- Entity/repository dùng ở **≥ 2 feature** → đưa vào `core/shared_domain`
- Entity/usecase chỉ phục vụ đúng 1 feature → giữ nguyên trong `features/<tên_feature>/domain`
- Widget tái sử dụng ở nhiều màn/feature khác nhau → đưa lên `design_system` (atoms/molecules/organisms)
- Widget chỉ dùng đúng 1 feature, không có ý định tái sử dụng → giữ trong `features/<tên_feature>/presentation/widgets`

**Chiều phụ thuộc (dependency rule) vẫn giữ nguyên tinh thần Clean Architecture gốc:**
`presentation` → phụ thuộc `domain` (qua interface) → `data` implement lại interface đó. `domain` không bao giờ import ngược lại `data` hay `presentation`. Việc feature-first chỉ thay đổi *vị trí vật lý* của 3 tầng này (nằm chung trong 1 folder feature), không phá vỡ nguyên tắc dependency gốc.

---

## 3. Supabase Schema (bảng chính — v1)

```sql
-- users (Supabase Auth tự tạo bảng auth.users, đây là bảng mở rộng)
create table profiles (
  id uuid references auth.users primary key,
  username text unique not null,
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
  user_id uuid references profiles(id),
  category text,                     -- Học tập / Công việc / Đọc sách...
  block_mode text,                   -- light / medium / strict
  planned_minutes int,
  actual_minutes int,
  status text,                       -- completed / failed / cancelled
  started_at timestamptz,
  ended_at timestamptz,
  created_at timestamptz default now()
);

-- scheduled_sessions
create table scheduled_sessions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references profiles(id),
  title text,
  template_type text,                -- custom / pomodoro_classic / pomodoro_50_10 ...
  recurrence_rule text,               -- RRULE format (theo iCal chuẩn)
  start_time time,
  end_time time,
  is_active bool default true,
  created_at timestamptz default now()
);

-- blocked_apps (cấu hình riêng của mỗi user)
create table blocked_apps (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references profiles(id),
  app_identifier text,               -- bundle id / package name
  app_name text,
  block_mode text                    -- light / medium / strict
);

-- leaderboard tận dụng view thay vì bảng riêng
create view leaderboard_weekly as
select user_id, sum(actual_minutes) as total_minutes
from focus_sessions
where status = 'completed'
  and started_at > now() - interval '7 days'
group by user_id;

-- friendships / groups (cho leaderboard bạn bè)
create table friendships (
  user_id uuid references profiles(id),
  friend_id uuid references profiles(id),
  status text,                       -- pending / accepted
  primary key (user_id, friend_id)
);
```

Row Level Security (RLS) bật cho toàn bộ bảng — mỗi user chỉ đọc/ghi được data của chính mình, còn leaderboard dùng view public read-only.

---

## 4. Các Phase phát triển

### **Phase 0 — Nền tảng & Setup (1-2 tuần)**
Mục tiêu: dựng khung dự án, không có tính năng thật nào chạy nhưng mọi kết nối phải thông suốt.

- Khởi tạo Flutter project, cấu hình Riverpod + go_router + freezed
- Kết nối Supabase (project, `.env`, `supabase_flutter` init)
- Thiết lập schema DB ở trên + bật RLS
- Setup CI/CD cơ bản (build debug tự động khi push)
- Thiết lập Design System theo Atomic Design (mục 2): dựng `CupertinoThemeData` + design tokens trước, sau đó build 5-6 atom cơ bản (button, text field, badge, avatar...) làm nền cho toàn bộ UI sau này
- **Prototype native blocking module** (bước rủi ro cao nhất, nên làm sớm):
  - Android: test thử `UsageStatsManager` để phát hiện app đang mở
  - iOS: test thử xin quyền `FamilyControls` (cần Apple Developer account trả phí + xin entitlement đặc biệt)

**Deliverable:** App chạy được, login/logout giả, kết nối Supabase thành công, có báo cáo khả thi về blocking native.

---

### **Phase 1 — Authentication & Onboarding (1 tuần)**
- Đăng ký/đăng nhập qua Supabase Auth (Email/Password + Google/Apple Sign-In)
- Onboarding flow: hỏi mục tiêu sử dụng (học tập/công việc), xin quyền Accessibility (Android) / Screen Time (iOS)
- Tạo `profiles` row tự động khi user mới đăng ký (Supabase Edge Function hoặc trigger DB)
- Màn hình xin permission chặn app (giải thích lý do cần quyền — bắt buộc cho UX vì đây là quyền nhạy cảm)

**Deliverable:** User đăng ký/đăng nhập được, có profile trong DB, đã cấp quyền cần thiết.

---

### **Phase 2 — Home (Quick Focus) — Core Focus Engine (2 tuần)**
- UI chọn thời lượng, chủ đề phiên, chế độ chặn
- Timer engine (dùng `flutter_foreground_task` để chạy nền, tránh bị hệ điều hành kill khi tắt màn hình)
- Kết nối blocking engine native (bật/tắt chặn khi start/end session)
- Lưu session vào bảng `focus_sessions` (start → Supabase insert `status = in_progress`, end → update)
- Strict Mode: giới hạn số lần thoát, ghi log vi phạm
- Âm thanh nền (lo-fi/white noise) — dùng `just_audio`

**Deliverable:** Có thể bắt đầu 1 phiên tập trung thật, app khác bị chặn thật sự, dữ liệu lưu vào Supabase.

---

### **Phase 3 — App/Website Blocking nâng cao (1.5 tuần)**
- Màn hình chọn app cần chặn (đọc danh sách app cài trên máy — `device_apps` cho Android, entitlement riêng cho iOS)
- 3 preset: Nhẹ / Trung bình / Nghiêm ngặt + custom list
- Chặn web (domain-based) — cân nhắc dùng **local VPN (NEVPNManager trên iOS / VpnService trên Android)** để lọc DNS, đây là cách phổ biến nhất các app như Opal/Freedom dùng
- "Break glass" — cho phép mở khẩn với hình phạt (trừ điểm/mất streak), log vào `focus_sessions` metadata

**Deliverable:** User tuỳ chỉnh được danh sách chặn, có cơ chế chống gian lận cơ bản.

---

### **Phase 4 — Scheduled + Pomodoro Templates (1.5 tuần)**
- CRUD cho `scheduled_sessions`, dùng RRULE để lưu lịch lặp lại
- Template Pomodoro dựng sẵn (Classic 25/5, 50/10, 15/3) — mô tả ở phần trước
- Local notification nhắc trước giờ bắt đầu (`flutter_local_notifications`)
- Auto-start: dùng background task (Android `WorkManager` qua `workmanager` package, iOS `BGTaskScheduler`) để tự kích hoạt blocking đúng giờ dù app không mở
- Đồng bộ Google Calendar (OAuth qua `google_sign_in` + Calendar API) — có thể để P2 nếu ưu tiên thấp

**Deliverable:** User đặt lịch được, app tự bật chặn đúng giờ kể cả khi không mở app.

---

### **Phase 5 — Leaderboard & Social (1.5 tuần)**
- Query từ view `leaderboard_weekly`/`daily`/`monthly` qua Supabase RPC
- Tab bạn bè: gửi/nhận lời mời qua bảng `friendships`
- Group riêng (tạo bảng `groups`, `group_members` nếu đến phase này)
- Supabase Realtime: cập nhật leaderboard live khi có session mới hoàn thành
- Rank badge (Bronze→Diamond) tính từ `rank_points` trong `profiles`

**Deliverable:** Leaderboard hoạt động, cập nhật gần real-time, có thể kết bạn.

---

### **Phase 6 — Profile, Stats & Gamification (1.5 tuần)**
- Dashboard thống kê (biểu đồ dùng `fl_chart`) — tổng giờ, streak, phân bổ theo category
- Cây/avatar mở khoá bằng điểm (đọc từ `rank_points`, lưu inventory trong bảng `user_items`)
- Weekly Recap tự động generate (Supabase Edge Function chạy cron mỗi tuần, tạo ảnh recap hoặc data cho FE render)
- Cài đặt cá nhân (theme, âm thanh mặc định, whitelist app)

**Deliverable:** Đầy đủ tab Profile, gamification loop hoàn chỉnh.

---

### **Phase 7 — Polish, Testing & Release (2 tuần)**
- Push notification qua FCM (nhắc lịch, động viên, streak sắp mất)
- Widget màn hình chính (Android App Widget + iOS WidgetKit — cần code native riêng)
- Test: unit test cho usecases/repositories, widget test cho UI chính, integration test cho luồng focus session
- Tối ưu performance (giảm rebuild không cần thiết, kiểm tra Riverpod provider scope)
- Chuẩn bị App Store / Play Store listing, xin duyệt quyền Screen Time (Apple review khá kỹ phần này, cần giải trình rõ mục đích)
- Beta test qua TestFlight / Play Internal Testing

**Deliverable:** App sẵn sàng release v1.0 lên 2 store.

---

## 5. Chiến lược chặn app — Hướng đi tối ưu (Tiết kiệm pin, tối thiểu background)

Nguyên tắc chung: **để hệ điều hành làm việc nặng, app chỉ cấu hình rồi "ngủ"**. Không tự polling liên tục, không giữ wake lock, không cần service chạy 24/7 nền — tận dụng cơ chế lịch trình native của mỗi OS.

### 5.1 iOS — dùng bộ 3 Screen Time Framework (khuyến nghị chính)

Đây là cách **tiết kiệm pin nhất có thể trên iOS** vì việc enforce block do hệ thống (SpringBoard) xử lý, app của bạn không cần chạy nền:

| Framework | Vai trò | Đặc điểm hiệu năng |
|---|---|---|
| `FamilyControls` | Xin quyền + để user chọn app/category cần chặn qua `FamilyActivityPicker` | Chỉ chạy 1 lần lúc setup, không tốn tài nguyên runtime |
| `ManagedSettings` | Set "shield" (màn chặn) lên app đã chọn | Áp dụng tức thì bởi hệ thống, không cần app chạy |
| `DeviceActivity` | Định nghĩa lịch (`DeviceActivitySchedule`) và 1 **extension riêng** (`DeviceActivityMonitorExtension`) tự động bật/tắt shield đúng giờ | Chạy trong extension riêng biệt do hệ thống trigger theo lịch — **app chính không cần mở, không tốn pin nền** |

**Cách hoạt động:** App chính chỉ cần gọi `startMonitoring()` 1 lần với lịch (schedule) đã định — ví dụ theo phiên Pomodoro hoặc lịch Scheduled. Từ đó hệ thống tự trigger extension tại đúng thời điểm để bật/tắt `ManagedSettingsStore`, hoàn toàn độc lập với vòng đời app chính. Đây chính là cơ chế "không chạy ngầm mà vẫn hiệu năng cao" mà bạn muốn.

**⚠️ 3 giới hạn thực tế cần biết trước khi build (từ báo cáo dev khác gặp phải, tính đến giữa 2026):**
1. `DeviceActivityMonitorExtension` bị giới hạn cứng **6MB bộ nhớ** — extension dễ bị crash nếu logic bên trong quá nặng, nên giữ code trong extension tối giản nhất có thể (chỉ đọc `UserDefaults` app-group rồi set shield, không xử lý gì thêm).
2. `ApplicationToken`/`ActivityCategoryToken` do `FamilyControls` cấp **không đảm bảo ổn định vĩnh viễn** — có thể bị hệ thống cấp lại token mới sau khi update OS/app, cần có cơ chế fallback yêu cầu user chọn lại app nếu decode token cũ thất bại.
3. Entitlement `Family Controls Distribution` phải **xin thủ công từ Apple** (không tự động cấp qua Developer Portal) — thời gian chờ duyệt có thể 1-2 tuần hoặc hơn, nên nộp đơn ngay Phase 0.

### 5.2 Android — kết hợp UsageStatsManager + Foreground Service có giới hạn thời gian (khuyến nghị chính)

Tránh dùng **AccessibilityService** làm phương án chính — nó đòi quyền truy cập nội dung màn hình rất rộng, dễ bị Google Play gắn cảnh báo "sensitive permission", tốn tài nguyên vì phải lắng nghe mọi sự kiện UI hệ thống liên tục.

Hướng tối ưu hơn — mô hình mà các app hàng đầu (One Sec, Screen Stoic) đang dùng:

1. **`UsageStatsManager`** (native, nhẹ) — dùng để đọc app đang foreground. Không cần chạy liên tục nền cả ngày; chỉ **poll với tần suất thấp (1-2 giây/lần) và chỉ trong lúc có phiên tập trung đang active** — tức có giới hạn thời gian sống rõ ràng, không phải service chạy vô hạn 24/7.
2. **Foreground Service có vòng đời gắn với phiên tập trung** — chỉ khởi động khi user bấm Start, tự huỷ khi phiên kết thúc. Không dùng partial wake lock (Google Play từ tháng 3/2026 đã bắt đầu phạt các app giữ wake lock >2 giờ khi tắt màn hình bằng cách gắn cảnh báo trên store listing và loại khỏi trang khám phá) — nên đảm bảo service không giữ CPU khi màn hình tắt, dựa vào `AlarmManager`/`WorkManager` (exact alarm) để đánh thức đúng lúc thay vì busy-loop.
3. **`WorkManager`** cho phần lịch (Scheduled tab) — đặt job tại đúng giờ để tự bật/tắt blocking, hệ thống tự tối ưu theo Doze/App Standby, không cần app tự canh giờ.

**So sánh nhanh:**

| Phương án | Pin | Quyền riêng tư | Độ tin cậy |
|---|---|---|---|
| AccessibilityService (không khuyến nghị làm chính) | Tốn — lắng nghe toàn bộ sự kiện UI | Rất rộng, dễ bị Play Store flag | Cao nhưng rủi ro chính sách |
| UsageStatsManager + Foreground Service theo phiên (khuyến nghị) | Thấp — chỉ chạy khi có phiên active, poll thưa | Trung bình, chỉ đọc tên package đang mở | Cao, ổn định qua nhiều Android version |
| VPN nội bộ (chặn theo domain, dùng cho web-blocking) | Trung bình — service phải sống suốt phiên | Cần giải trình rõ trong Privacy Policy dù không gửi data ra ngoài | Tốt cho chặn website, không chặn được app native |

→ **Kết luận Android:** dùng `UsageStatsManager` + Foreground Service **chỉ trong lúc có phiên tập trung** làm cơ chế chính để chặn app; dùng **local VPN (chỉ lọc DNS, không log/gửi traffic đi đâu)** làm lớp bổ sung riêng cho việc chặn website trong trình duyệt. Không bật cả 2 khi không có phiên nào đang chạy — đây là điểm mấu chốt để không bị coi là "chạy ngầm liên tục".

### 5.3 Nguyên tắc thiết kế chung cho cả 2 nền tảng

- **Không có tiến trình nào chạy khi không có phiên tập trung active** — đây là yêu cầu cứng, giúp pin gần như không bị ảnh hưởng ngoài lúc dùng app.
- Toàn bộ lịch trình (Scheduled/Pomodoro) giao cho hệ thống quản lý (`DeviceActivitySchedule` trên iOS, `WorkManager`/`AlarmManager` trên Android) thay vì tự app canh giờ bằng timer nội bộ.
- Tách phần native blocking thành **module riêng biệt, độc lập với business logic Flutter** (giao tiếp qua Platform Channel/Pigeon) — vì đây là phần thay đổi nhiều nhất qua các bản OS mới, cần dễ update mà không đụng vào phần Dart.
- Nên prototype cả 2 module này ngay từ Phase 0 để phát hiện sớm giới hạn (6MB memory trên iOS, chính sách Play Store trên Android) trước khi đầu tư sâu vào UI.

## 6. Rủi ro cần lưu ý sớm

1. **Apple Screen Time API (FamilyControls)** yêu cầu xin entitlement đặc biệt từ Apple, quá trình duyệt có thể mất 1-2 tuần hoặc hơn — nên nộp đơn xin ngay từ Phase 0.
2. `DeviceActivityMonitorExtension` giới hạn cứng 6MB bộ nhớ, một số dev báo cáo extension bị crash không đoán trước được khi dùng nhiều `ManagedSettingsStore` cùng lúc — cần test kỹ trên thiết bị thật, không chỉ simulator.
3. **Android Accessibility Service** nếu vẫn cần dùng cho tính năng nào đó ngoài blocking, phải có trang giải trình chính sách rõ ràng khi submit Play Store.
4. Google Play (từ 3/2026) bắt đầu phạt app giữ partial wake lock quá 2 giờ khi màn hình tắt — cần review kỹ phần Foreground Service để tránh bị flag "Excessive Partial Wake Lock" trong Android Vitals.
5. Việc chặn bằng VPN nội bộ (local, không gửi data ra ngoài) cần giải thích minh bạch trong Privacy Policy để tránh bị từ chối duyệt app trên cả 2 store.
6. Nên tách riêng phần native blocking thành module độc lập để dễ maintain, vì đây là phần thay đổi nhiều nhất qua các version OS.

---

## 7. Tổng thời gian ước tính

| Phase | Thời gian |
|---|---|
| Phase 0 | 1-2 tuần |
| Phase 1 | 1 tuần |
| Phase 2 | 2 tuần |
| Phase 3 | 1.5 tuần |
| Phase 4 | 1.5 tuần |
| Phase 5 | 1.5 tuần |
| Phase 6 | 1.5 tuần |
| Phase 7 | 2 tuần |
| **Tổng** | **~12-13 tuần** (~3 tháng, 1 dev full-time) |
