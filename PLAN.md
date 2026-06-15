🛠️ TECH STACK & PROVIDERS
Frontend: Flutter

State Management: Bloc (hoặc Riverpod)

Local Database: Isar Database (hoặc Hive)

Audio Core: just_audio + audio_service

Backend & Auth: Supabase (Gói Free)

Cloud Storage: Supabase Storage (hoặc Cloudflare R2)

Log & Bug Tracking: Sentry (hoặc Firebase Crashlytics)

Product Analytics: Mixpanel

📋 CÁC GIAI ĐOẠN TRIỂN KHAI (PHASES)
🚀 GIAI ĐOẠN 1: PHASE MVP (Cốt lõi & 100% Offline)
Tập trung vào trải nghiệm cốt lõi của việc đếm giờ và phát nhạc, chưa cần server.

UI/UX Setup: Dựng layout phẳng tối giản theo 3 tone màu chủ đạo từ ảnh mẫu (Xanh rêu, Cam đất, Be), thiết kế thoáng, lột bỏ hoàn toàn các khung hộp (box/card).

Pomodoro & Chrono Timer: Bộ đếm ngược 25p/5p và bộ đếm tiến. Tự lưu mốc thời gian xuống Local DB để tránh lệch giây khi thoát app.

Zen Animation: Hiệu ứng các vòng tròn đồng tâm phẳng co giãn chậm rãi theo giây xung quanh chữ trạng thái.

Background Audio: Phát các luồng âm thanh thiên nhiên cơ bản (Mưa, Chim hót) chạy ngầm mượt mà khi khóa màn hình.

Flat Sound Mixer: Giao diện thanh trượt phẳng (Flat Sliders) tối giản để tự trộn volume các luồng âm thanh.

Local Focus Log: Tự động ghi lại lịch sử phiên học (Số giây tập trung, trạng thái Hoàn thành/Hủy) trực tiếp trên máy user.

📈 GIAI ĐOẠN 2: PHASE ADVANCED (Custom & Cloud Sync)
Nâng cấp trải nghiệm cá nhân hóa và bắt đầu kết nối Cloud để bảo vệ dữ liệu.

Custom Background: Cho phép user đổi màu nền phẳng hoặc up ảnh từ máy lên (phủ thêm lớp màu mờ/blur để chữ trắng không bị chìm).

1-Tap Authentication: Đăng nhập ẩn danh (Guest) khi mới tải app, cho phép liên kết tài khoản Google/Apple bằng 1 chạm để lên tài khoản thật.

Lazy Data Migration: Tự động gom toàn bộ Log lịch sử từ lúc xài Guest đẩy thẳng lên PostgreSQL của Supabase sau khi user đăng nhập.

Queue Syncing Engine: Cơ chế tự động xếp hàng dữ liệu, âm thầm đẩy log từ máy lên Cloud khi có mạng (hoạt động ngầm không làm lag app).

Flat Analytics Screen: Màn hình lấy dữ liệu Local vẽ thành biểu đồ cột phẳng (Flat Bar Chart) thống kê theo tuần, tính Streak ngày liên tục.

🪵 GIAI ĐOẠN 3: PHASE PRODUCTION (Tracking & Optimization)
Ghi vết hệ thống để tối ưu hiệu năng, sửa lỗi và phân tích hành vi.

Crash & Bug Logging (Sentry): Tự động bắt và gửi báo cáo lỗi nếu luồng audio chạy ngầm bị hệ điều hành "kill" hoặc lỗi mất mạng khi tải nhạc.

Behavior Tracking (Mixpanel): Track các sự kiện user bấm Start, Abandoned (Hủy giữa chừng) hoặc loại âm thanh nào được trộn nhiều nhất để tối ưu sản phẩm.

Performance Optimization: Tối ưu hóa các widget animation vòng tròn đồng tâm để đảm bảo app chạy mượt tuyệt đối, không gây nóng máy hay tốn pin.

Mọi thứ đã nằm tập trung trong một bảng này rồi đó ông. Cứ bám theo bộ khung này là có thể bắt tay vào setup project và code được luôn rồi!
