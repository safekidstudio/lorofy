# Lorofy - Zen UI Focus Timer & Audio Space

Một ứng dụng di động giúp người dùng tập trung hiệu suất cao dựa trên phương pháp Pomodoro/Chrono, kết hợp không gian âm thanh (Lofi, Tiếng ồn trắng) chạy ngầm và phong cách thiết kế phẳng tối giản (Zen UI / Minimalist Flat Design).

---

## 🛠️ TECH STACK & PROVIDERS

*   **Frontend:** Flutter (Tối ưu hiệu năng render animation phẳng)
*   **State Management:** BLoC (Quản lý trạng thái Timer và Audio chặt chẽ)
*   **Local Database:** Isar Database (Hỗ trợ cấu trúc lưu trữ offline tốc độ cao)
*   **Audio Core:** `just_audio` + `audio_service` (Xử lý phát đa luồng ngầm trên iOS/Android)
*   **Backend & Auth:** Supabase (Gói Free - Quản lý Auth và đồng bộ PostgreSQL)
*   **Cloud Storage:** Supabase Storage hoặc Cloudflare R2 (Lưu trữ asset âm thanh/ảnh nền)
*   **Log & Bug Tracking:** Sentry (Giám sát lỗi runtime của background process)
*   **Product Analytics:** Mixpanel (Ghi vết hành vi người dùng)

---

## 📋 CÁC GIAI ĐOẠN TRIỂN KHAI (PHASES)

### 🚀 GIAI ĐOẠN 1: PHASE MVP (Cốt lõi & 100% Offline)
*Mục tiêu: Hoàn thiện trải nghiệm tập trung cốt lõi dưới local với chi phí vận hành bằng $0.*

*   **UI/UX Setup:** 
    *   Dựng layout phẳng tối giản theo 3 tone màu chủ đạo Zen (Xanh rêu, Cam đất, Be).
    *   Thiết kế giao diện thoáng, lột bỏ hoàn toàn các khung hộp (box/card).
*   **Pomodoro & Chrono Timer:** 
    *   Bộ đếm ngược 25p/5p (Pomodoro) và bộ đếm tiến (Chrono).
    *   Tự động lưu mốc thời gian xuống Local DB để không bị lệch giây khi thoát/mở lại app.
*   **Zen Animation:** 
    *   Hiệu ứng các vòng tròn đồng tâm phẳng co giãn chậm rãi theo giây xung quanh chữ trạng thái.
*   **Background Audio:** 
    *   Phát các luồng âm thanh thiên nhiên cơ bản (Mưa, Chim hót) chạy ngầm mượt mà khi khóa màn hình.
*   **Flat Sound Mixer:** 
    *   Giao diện thanh trượt phẳng (Flat Sliders) tối giản để tự trộn volume các luồng âm thanh song song.
*   **Local Focus Log:** 
    *   Tự động ghi lại lịch sử phiên học (Số giây tập trung, trạng thái Hoàn thành/Hủy) trực tiếp trên máy của user.

### 📈 GIAI ĐOẠN 2: PHASE ADVANCED (Custom & Cloud Sync)
*Mục tiêu: Nâng cấp trải nghiệm cá nhân hóa và đồng bộ Cloud bảo vệ dữ liệu.*

*   **Custom Background:** 
    *   Cho phép user đổi màu nền phẳng hoặc up ảnh từ máy lên (phủ thêm lớp màu mờ/blur để chữ trắng không bị chìm).
*   **1-Tap Authentication:** 
    *   Đăng nhập ẩn danh (Guest) khi mới tải app. Cho phép liên kết tài khoản Google/Apple bằng 1 chạm để lên tài khoản thật.
*   **Lazy Data Migration:** 
    *   Tự động gom toàn bộ Log lịch sử từ lúc xài Guest đẩy thẳng lên PostgreSQL của Supabase sau khi đăng nhập thành công.
*   **Queue Syncing Engine:** 
    *   Cơ chế tự động xếp hàng dữ liệu, âm thầm đẩy log từ máy lên Cloud khi có mạng (hoạt động ngầm không làm lag app).
*   **Flat Analytics Screen:** 
    *   Màn hình lấy dữ liệu Local vẽ thành biểu đồ cột phẳng (Flat Bar Chart) thống kê theo tuần, tính Streak ngày liên tục.

### 🪵 GIAI ĐOẠN 3: PHASE PRODUCTION (Tracking & Optimization)
*Mục tiêu: Ghi vết hệ thống để tối ưu hiệu năng, sửa lỗi và phân tích hành vi.*

*   **Crash & Bug Logging (Sentry):** 
    *   Tự động bắt và gửi báo cáo lỗi nếu luồng audio chạy ngầm bị hệ điều hành "kill" hoặc lỗi mất mạng khi tải nhạc.
*   **Behavior Tracking (Mixpanel):** 
    *   Track các sự kiện user bấm Start, Abandoned (Hủy giữa chừng) hoặc loại âm thanh nào được trộn nhiều nhất để tối ưu sản phẩm.
*   **Performance Optimization:** 
    *   Tối ưu hóa các widget animation vòng tròn đồng tâm để đảm bảo app chạy mượt tuyệt đối, không gây nóng máy hay tốn pin.
