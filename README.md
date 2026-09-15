# Hệ Thống Nhà Thông Minh Tự Động Hóa

Mô hình ứng dụng di động (Mobile App) kết hợp Vi điều khiển IoT, Backend và Cơ sở dữ liệu, cho phép người dùng giám sát và điều khiển thiết bị trong nhà theo thời gian thực, đồng thời tự động hóa các hành động dựa trên dữ liệu cảm biến.

## 1. Kiến trúc hệ thống

```
[ Cảm biến / Thiết bị IoT ]
          |
          v
[ Vi điều khiển (ESP32/ESP8266) ] --- gửi dữ liệu / nhận lệnh --->
          |
          v
[ Backend API ] <----> [ Cơ sở dữ liệu MySQL ]
          |
          v
[ Mobile App (Flutter) ]
          |
          v
      Người dùng
```

Vi điều khiển thu thập dữ liệu cảm biến và gửi lên Backend; Backend xử lý logic tự động hóa (rule engine), lưu trữ vào MySQL, và cung cấp API cho Mobile App. Mobile App hiển thị trạng thái, gửi lệnh điều khiển, và nhận thông báo/cảnh báo.

## 2. Công nghệ sử dụng

| Tầng | Ngôn ngữ chính | Framework / Nền tảng |
| --- | --- | --- |
| Vi điều khiển & Phần cứng (IoT) | C / C++ | Arduino / PlatformIO (ESP32, ESP8266) |
| Backend & Logic tự động hóa | Java | Spring Boot |
| Cơ sở dữ liệu | SQL | MySQL |
| Giao diện người dùng (Mobile App) | Dart | Flutter (Android & iOS) |
| Trợ lý Giọng nói (nâng cao) | Python | Whisper / FastAPI |

## 3. Cấu trúc thư mục dự án

```
smart-home-project/
├── backend/          Spring Boot API (đang phát triển)
├── database/         Script MySQL, sơ đồ ERD
├── mobile-app/        Flutter app (chưa triển khai trong repo này)
├── iot-firmware/       Firmware ESP32/ESP8266 (chưa triển khai)
└── README.md
```

> Repo/thư mục hiện tại chỉ chứa phần **backend** và **database**; phần mobile app và firmware IoT nằm ngoài phạm vi công việc hiện tại.

## 4. Cơ sở dữ liệu

Cơ sở dữ liệu MySQL tên `QLNhaThongMinh`, gồm 14 bảng: `NguoiDung`, `Nha`, `NguoiDung_Nha`, `Phong`, `ThietBi`, `CamBien`, `LichSuCamBien`, `KichBan`, `KichBan_HanhDong`, `QuyTacTuDong`, `LichHenGio`, `CanhBao`, `LichSuHoatDong`.

- Script tạo CSDL: `database/QLNhaThongMinh_MySQL.sql`
- Sơ đồ ERD: `database/ERD_NhaThongMinh.mermaid`

## 5. Danh sách tính năng

| Nhóm | Tính năng | Mức ưu tiên |
| --- | --- | --- |
| Tài khoản | Đăng nhập & phân quyền | Cao |
| Quản lý nhà | Quản lý phòng | Cao |
| Quản lý thiết bị | Quản lý thiết bị | Cao |
| Điều khiển | Điều khiển thiết bị | Cao |
| Cảm biến | Theo dõi nhiệt độ | Cao |
| Cảm biến | Theo dõi độ ẩm | Trung bình |
| Cảm biến | Phát hiện chuyển động | Cao |
| Tự động hóa | Tự động bật/tắt đèn | Cao |
| Tự động hóa | Tự động điều hòa theo nhiệt độ | Cao |
| Tự động hóa | Phát hiện xâm nhập trái phép | Cao |
| Tự động hóa | Tạo kịch bản | Cao |
| Lập lịch | Hẹn giờ thiết bị | Trung bình |
| An ninh | Cảnh báo cửa mở | Cao |
| An ninh | Cảnh báo cháy/khói | Cao |
| An ninh | Cảnh báo rò rỉ nước | Trung bình |
| Thông báo | Thông báo sự cố | Cao |
| Lịch sử | Lịch sử hoạt động | Trung bình |
| Thống kê | Thống kê sử dụng | Thấp |
| Điều khiển | Điều khiển từ xa | Cao |
| Nâng cao | Điều khiển bằng giọng nói | Thấp |

## 6. Tiến độ Backend

Đã hoàn thành:

- [x] Đăng nhập & phân quyền (JWT, phân quyền Admin / ThanhVien)
- [x] Quản lý phòng (CRUD, xem thiết bị theo phòng)
- [x] Quản lý thiết bị (CRUD, theo dõi trạng thái)

Chưa làm:

- [ ] Điều khiển thiết bị
- [ ] Cảm biến (nhiệt độ, độ ẩm, chuyển động)
- [ ] Tự động hóa (rule engine IF-THEN)
- [ ] Kịch bản (Đi ngủ / Rời nhà / Về nhà)
- [ ] Lập lịch thiết bị
- [ ] Cảnh báo an ninh (cửa mở, cháy/khói, rò rỉ nước)
- [ ] Thông báo
- [ ] Lịch sử hoạt động
- [ ] Thống kê sử dụng
- [ ] Điều khiển bằng giọng nói

### API hiện có

| Method | Endpoint | Mô tả | Quyền |
| --- | --- | --- | --- |
| POST | `/api/auth/register` | Tạo tài khoản | Công khai |
| POST | `/api/auth/login` | Đăng nhập, nhận JWT | Công khai |
| GET | `/api/user/me` | Xem thông tin/quyền hiện tại | Đã đăng nhập |
| GET | `/api/admin/ping` | Endpoint mẫu chỉ Admin | Admin |
| GET | `/api/phong?maNha=` | Danh sách phòng theo nhà | Đã đăng nhập |
| GET | `/api/phong/{id}` | Chi tiết phòng + thiết bị trong phòng | Đã đăng nhập |
| POST | `/api/phong` | Tạo phòng | Admin |
| PUT | `/api/phong/{id}` | Sửa phòng | Admin |
| DELETE | `/api/phong/{id}` | Xóa phòng | Admin |
| GET | `/api/thiet-bi?maPhong=` | Danh sách thiết bị theo phòng | Đã đăng nhập |
| GET | `/api/thiet-bi/{id}` | Chi tiết thiết bị | Đã đăng nhập |
| POST | `/api/thiet-bi` | Thêm thiết bị | Admin |
| PUT | `/api/thiet-bi/{id}` | Sửa thiết bị | Admin |
| DELETE | `/api/thiet-bi/{id}` | Xóa thiết bị | Admin |

## 7. Cài đặt & chạy Backend

1. Cài MySQL, tạo CSDL bằng `database/QLNhaThongMinh_MySQL.sql`
2. Mở `backend/src/main/resources/application.properties`, sửa `spring.datasource.username`, `spring.datasource.password` theo MySQL của bạn, đổi `jwt.secret` thành chuỗi riêng
3. Chạy `mvn spring-boot:run` trong thư mục `backend/`
4. Gọi `POST /api/auth/register` để tạo tài khoản Admin đầu tiên
5. Gọi `POST /api/auth/login` để lấy JWT, dùng token này trong header `Authorization: Bearer <token>` cho các API còn lại
