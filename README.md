# Hệ Thống Nhà Thông Minh Tự Động Hóa (Smart Home)

Hệ sinh thái Nhà Thông Minh kết hợp Vi điều khiển IoT, Backend API, Cơ sở dữ liệu và Ứng dụng điều khiển (Mobile/Web), cho phép người dùng giám sát, quản lý và điều khiển thiết bị trong nhà theo thời gian thực, đồng thời tự động hóa các hành động dựa trên dữ liệu cảm biến.

---

## 1. Kiến trúc hệ thống

```
[ Cảm biến / Thiết bị IoT ]
          │
          ▼
[ Vi điều khiển (ESP32/ESP8266) ] ─── gửi dữ liệu (X-Device-Key) / nhận lệnh ───┐
          │                                                                       │
          ▼                                                                       ▼
[ Backend API (Spring Boot) ] ◄────────────────────────────────────────► [ Cơ sở dữ liệu MySQL ]
          │
          ▼
[ Giao diện người dùng (Flutter Web / Mobile App) ]
          │
          ▼
     Người dùng
```

- **Vi điều khiển (IoT)**: Thu thập dữ liệu cảm biến và đẩy lên Backend qua API Ingest; nhận lệnh điều khiển thiết bị.
- **Backend API**: Xử lý xác thực người dùng (JWT), quản lý phòng/thiết bị/cảm biến, ghi nhận lịch sử hoạt động, tự động hóa với Flyway migration và dotenv.
- **MySQL Database**: Lưu trữ dữ liệu tài khoản, phân quyền, trạng thái nhà, thiết bị, chỉ số cảm biến và nhật ký hoạt động.
- **Frontend App**: Xây dựng bằng Flutter (chạy được trên Web, Android, iOS), hỗ trợ quản lý nhà, phòng, thiết bị trực quan.

---

## 2. Công nghệ sử dụng

| Tầng | Công nghệ / Thư viện chính | Chi tiết |
| --- | --- | --- |
| **Backend** | Java 17, Spring Boot 3 | Spring Security, JWT, Spring Data JPA / Hibernate, Flyway Migration, Spring Dotenv |
| **Cơ sở dữ liệu** | MySQL 8+ | 13 bảng chuẩn hóa quan hệ, tự động migration qua Flyway |
| **Frontend** | Dart, Flutter 3+ | Hỗ trợ Flutter Web (port 3000) và Mobile App (Android/iOS), Provider, HTTP |
| **IoT & Phần cứng** | C / C++ (PlatformIO / Arduino) | ESP32 / ESP8266, kết nối HTTP Ingest với API Key bảo mật (`X-Device-Key`) |
| **Tự động hóa & Script** | Batch Script (Windows) | `run-backend.bat` (quản lý port, build, restart), `run-frontend.bat` (chạy Flutter Web) |

---

## 3. Cấu trúc thư mục dự án

```
QLNTM/
├── smart-home-backend/             # Mã nguồn Backend (Spring Boot 3, Java 17)
│   ├── src/main/java/              # Kiến trúc phân tầng: Controller, Service, Entity, DTO, Security
│   ├── src/main/resources/
│   │   ├── application.properties  # Cấu hình Spring Boot (Datasource, JWT, Flyway...)
│   │   └── db_migration/           # Script migration tự động Flyway (V1__init_schema.sql, ...)
│   ├── .env.example                # File mẫu cấu hình biến môi trường
│   ├── .env                        # File biến môi trường thực tế (chứa mật khẩu, key bí mật - không commit)
│   ├── mvnw, mvnw.cmd              # Maven Wrapper
│   └── pom.xml                     # Quản lý dependencies Maven
├── smart-home-frontend/            # Mã nguồn Giao diện (Flutter đa nền tảng)
│   ├── lib/
│   │   ├── config/                 # Cấu hình Base URL API (Web / Emulator / Mobile thật)
│   │   ├── models/                 # Model dữ liệu (Room, Device, User...)
│   │   ├── screens/                # Giao diện: Auth (Login/Register), Dashboard, Room detail...
│   │   └── services/               # Gọi API Backend (AuthService, RoomService...)
│   ├── web/, android/, ios/...     # Source cho từng nền tảng đích
│   └── pubspec.yaml                # Quản lý dependencies Flutter
├── QLNhaThongMinh_MySQL.sql        # Script tạo CSDL MySQL gốc (13 bảng)
├── run-backend.bat                 # Script chạy Backend (kiểm tra JDK, port 8080, restart, clean & build)
├── run-frontend.bat                # Script chạy nhanh Flutter Web tại port 3000
└── Readme.md                       # Tài liệu kiến trúc, hướng dẫn và tiến độ dự án
```

---

## 4. Cơ sở dữ liệu

Cơ sở dữ liệu MySQL mang tên `QLNhaThongMinh`, gồm 13 bảng quan hệ:
1. `NguoiDung`: Tài khoản người dùng, mật khẩu mã hóa BCrypt, vai trò (`Admin`, `ThanhVien`).
2. `Nha`: Quản lý thông tin nhà ở, trạng thái nhà (`ONha`, `VangNha`).
3. `NguoiDung_Nha`: Bảng liên kết phân quyền thành viên trong nhà.
4. `Phong`: Danh sách phòng trong từng ngôi nhà.
5. `ThietBi`: Danh sách thiết bị điện trong phòng, trạng thái (`Bat`, `Tat`).
6. `CamBien`: Cảm biến gắn trong phòng hoặc gắn kèm thiết bị (`NhietDo`, `DoAm`, `ChuyenDong`, `Cua`, `Khoi`, `RoRiNuoc`).
7. `LichSuCamBien`: Nhật ký lưu trữ chỉ số đo đạc theo dòng thời gian.
8. `KichBan`: Ngữ cảnh hoạt động của ngôi nhà (Về nhà, Đi ngủ, Đi vắng...).
9. `KichBan_HanhDong`: Các thao tác thiết bị cần thực hiện trong kịch bản.
10. `QuyTacTuDong`: Tập luật tự động hóa dạng IF-THEN theo điều kiện cảm biến.
11. `LichHenGio`: Đặt lịch bật/tắt thiết bị theo khung giờ và ngày trong tuần.
12. `CanhBao`: Lưu vết sự cố và cảnh báo khẩn cấp (cháy, rò rỉ nước, cửa mở...).
13. `LichSuHoatDong`: Nhật ký ghi lại mọi thao tác điều khiển thiết bị (ai điều khiển, hành động gì, nguồn nào).

> **Quản lý Migration:** Dự án tích hợp Flyway trong `smart-home-backend`. Khi khởi động Backend, Flyway sẽ tự động kiểm tra và thực thi script từ thư mục `smart-home-backend/src/main/resources/db_migration/V1__init_schema.sql`.

---

## 5. Trạng thái & Tiến độ hiện tại

### 5.1. Backend (Spring Boot API)
- [x] **Xác thực & Phân quyền (Auth)**:
  - Đăng ký tài khoản mới (`Admin` / `ThanhVien`) kèm mã hóa mật khẩu BCrypt.
  - Đăng nhập và tạo JWT token xác thực.
  - Phân quyền API theo Role (`ADMIN`, `USER`).
- [x] **Quản lý Phòng (Rooms)**:
  - Lấy danh sách phòng theo nhà.
  - Lấy chi tiết thông tin phòng kèm danh sách thiết bị.
  - Thêm, sửa, xóa phòng (dành riêng cho Admin).
- [x] **Quản lý Thiết bị (Devices)**:
  - Lấy danh sách thiết bị theo phòng.
  - Thêm, sửa, xóa thiết bị (dành riêng cho Admin).
- [x] **Điều khiển Thiết bị**:
  - API điều khiển thiết bị (`PATCH /api/thiet-bi/{maThietBi}/dieu-khien`) hỗ trợ bật/tắt (`BAT` / `TAT`).
- [x] **Nhật ký Hoạt động**:
  - Tự động lưu vết vào bảng `LichSuHoatDong` mỗi khi có hành động điều khiển thiết bị (ghi nhận người dùng thao tác, thời gian, hành động).
- [x] **Quản lý Cảm biến & Ingest Dữ liệu IoT**:
  - Thêm mới cảm biến (`POST /api/cam-bien` - Admin).
  - Lấy danh sách cảm biến theo phòng hoặc theo loại (`GET /api/cam-bien`).
  - Lấy chỉ số mới nhất của cảm biến (`GET /api/cam-bien/{maCamBien}/hien-tai`).
  - Truy vấn lịch sử dữ liệu cảm biến theo khoảng thời gian (`GET /api/cam-bien/{maCamBien}/lich-su`).
  - API Ingest dành cho phần cứng/vi điều khiển IoT gửi dữ liệu lên (`POST /api/cam-bien/ingest`), xác thực an toàn qua Header `X-Device-Key`.
- [x] **Cấu hình & Bảo mật**:
  - Đã tách toàn bộ thông tin nhạy cảm (mật khẩu DB, JWT secret, API key) sang file `.env` qua thư viện `spring-dotenv`.
  - Tự động chạy migration cơ sở dữ liệu qua Flyway.
- [ ] **Tính năng tiếp theo**:
  - [ ] Bộ luật tự động hóa IF-THEN (Rule Engine tự động kích hoạt thiết bị khi vượt ngưỡng cảm biến).
  - [ ] Kịch bản ngữ cảnh (Thực thi hàng loạt hành động theo kịch bản).
  - [ ] Lập lịch hẹn giờ định kỳ.
  - [ ] Hệ thống thông báo cảnh báo sự cố thời gian thực (WebSocket / SSE / Notification).
  - [ ] Thống kê dữ liệu tiêu thụ.
  - [ ] Tích hợp trợ lý ảo điều khiển bằng giọng nói.

### 5.2. Frontend (Flutter Web & Mobile)
- [x] **Khởi tạo & Cấu hình nền tảng**:
  - Cấu hình Flutter hỗ trợ Web, Android, iOS, Windows.
  - Cấu hình linh hoạt Base URL (`ApiConfig`) cho cả Web localhost, máy ảo Android Emulator và điện thoại thật.
- [x] **Xác thực người dùng**:
  - Giao diện Đăng nhập & Đăng ký tài khoản hiện đại.
  - Lưu trữ JWT token và trạng thái phiên đăng nhập.
- [x] **Quản lý Nhà & Phòng (Dashboard)**:
  - Màn hình Dashboard hiển thị danh sách các phòng.
  - Thêm phòng mới, sửa tên phòng, xóa phòng theo quyền hạn.
- [x] **Chi tiết Phòng & Quản lý Thiết bị**:
  - Xem danh sách thiết bị bên trong từng phòng.
  - Thêm thiết bị mới, chỉnh sửa thông tin hoặc xóa thiết bị.
- [ ] **Tính năng tiếp theo**:
  - [ ] Nút Switch bật/tắt thiết bị trực tiếp trên giao diện (gọi API điều khiển `PATCH /api/thiet-bi/{id}/dieu-khien`).
  - [ ] Thẻ hiển thị thông số cảm biến (nhiệt độ, độ ẩm, trạng thái cửa) và biểu đồ đo đạc.
  - [ ] Màn hình kích hoạt kịch bản và cài đặt hẹn giờ.
  - [ ] Màn hình xem nhật ký hoạt động và cảnh báo an ninh.

---

## 6. Danh sách API hiện có

| Nhóm | Phương thức | Endpoint | Mô tả | Phân quyền |
| --- | --- | --- | --- | --- |
| **Xác thực** | `POST` | `/api/auth/register` | Đăng ký tài khoản mới | Công khai |
| **Xác thực** | `POST` | `/api/auth/login` | Đăng nhập và nhận JWT token | Công khai |
| **Người dùng** | `GET` | `/api/user/me` | Lấy thông tin & quyền tài khoản hiện tại | Đã đăng nhập |
| **Người dùng** | `GET` | `/api/admin/ping` | Kiểm tra kết nối phân quyền Admin | Admin |
| **Phòng** | `GET` | `/api/phong?maNha={id}` | Lấy danh sách phòng theo nhà | Đã đăng nhập |
| **Phòng** | `GET` | `/api/phong/{id}` | Lấy chi tiết phòng & danh sách thiết bị | Đã đăng nhập |
| **Phòng** | `POST` | `/api/phong` | Thêm phòng mới | Admin |
| **Phòng** | `PUT` | `/api/phong/{id}` | Cập nhật thông tin phòng | Admin |
| **Phòng** | `DELETE` | `/api/phong/{id}` | Xóa phòng | Admin |
| **Thiết bị** | `GET` | `/api/thiet-bi?maPhong={id}` | Lấy danh sách thiết bị theo phòng | Đã đăng nhập |
| **Thiết bị** | `GET` | `/api/thiet-bi/{id}` | Lấy chi tiết thiết bị | Đã đăng nhập |
| **Thiết bị** | `POST` | `/api/thiet-bi` | Thêm thiết bị mới | Admin |
| **Thiết bị** | `PUT` | `/api/thiet-bi/{id}` | Cập nhật thông tin thiết bị | Admin |
| **Thiết bị** | `DELETE` | `/api/thiet-bi/{id}` | Xóa thiết bị | Admin |
| **Điều khiển** | `PATCH` | `/api/thiet-bi/{id}/dieu-khien` | Bật/tắt thiết bị & ghi nhận nhật ký | Đã đăng nhập |
| **Cảm biến** | `GET` | `/api/cam-bien?maPhong={id}&loai={type}` | Lấy danh sách cảm biến theo phòng / loại | Đã đăng nhập |
| **Cảm biến** | `POST` | `/api/cam-bien` | Thêm cảm biến mới | Admin |
| **Cảm biến** | `GET` | `/api/cam-bien/{id}/hien-tai` | Lấy giá trị đo đạc mới nhất của cảm biến | Đã đăng nhập |
| **Cảm biến** | `GET` | `/api/cam-bien/{id}/lich-su?tu={t1}&den={t2}` | Lấy lịch sử đo đạc của cảm biến | Đã đăng nhập |
| **IoT Ingest** | `POST` | `/api/cam-bien/ingest` | ESP32/ESP8266 gửi dữ liệu cảm biến | Thiết bị (`X-Device-Key`) |

---

## 7. Hướng dẫn Cài đặt & Khởi chạy

### 7.1. Chuẩn bị Cơ sở dữ liệu
1. Cài đặt MySQL (khuyên dùng MySQL 8.0 trở lên).
2. Tạo database rỗng tên `QLNhaThongMinh`:
   ```sql
   CREATE DATABASE QLNhaThongMinh CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
   ```
   *(Lưu ý: Bảng và dữ liệu mẫu sẽ được Flyway tự động khởi tạo khi Backend chạy lần đầu).*

### 7.2. Cấu hình & Chạy Backend
1. Vào thư mục `smart-home-backend/`.
2. Tạo file `.env` bằng cách copy từ file mẫu `.env.example`:
   ```bash
   cp .env.example .env
   ```
3. Điền thông tin kết nối MySQL và các secret key vào file `.env`:
   ```env
   DB_URL=jdbc:mysql://localhost:3306/QLNhaThongMinh?useSSL=false&serverTimezone=Asia/Ho_Chi_Minh&allowPublicKeyRetrieval=true
   DB_USERNAME=root
   DB_PASSWORD=your_password
   JWT_SECRET=chuoi_khoa_bi_mat_jwt_ngau_nhien_dai_it_nhat_32_ky_tu
   DEVICE_API_KEY=ma_khoa_bi_mat_cho_esp32
   ```
4. **Khởi chạy Backend**:
   - **Cách 1 (Khuyên dùng trên Windows)**: Nhấp đúp hoặc chạy script `run-backend.bat` ở thư mục gốc. Script này sẽ:
     - Tự kiểm tra Java SDK 17 và Maven.
     - Tự kiểm tra file `.env`.
     - Tự động tắt tiến trình khác nếu port 8080 đang bị chiếm dụng.
     - Hỗ trợ menu Restart, Clean Install và giải phóng port nhanh.
   - **Cách 2 (Dòng lệnh thủ công)**:
     ```bash
     cd smart-home-backend
     mvn spring-boot:run
     ```
   - Server backend khởi chạy tại địa chỉ: `http://localhost:8080`.

### 7.3. Khởi chạy Frontend (Flutter)
1. **Khởi chạy nhanh trên Web (Port 3000)**:
   - Nhấp đúp hoặc chạy script `run-frontend.bat` ở thư mục gốc.
   - Mở trình duyệt truy cập: `http://localhost:3000`.
2. **Hoặc chạy dòng lệnh thủ công**:
   ```bash
   cd smart-home-frontend
   flutter pub get
   flutter run -d chrome --web-port=3000
   ```
3. **Chạy trên thiết bị di động (Android / iOS)**:
   - Nếu chạy qua máy ảo Android Emulator hoặc điện thoại thật, mở file `smart-home-frontend/lib/config/api_config.dart` và chỉnh `baseUrl` tương ứng:
     - Android Emulator: `http://10.0.2.2:8080`
     - Điện thoại thật: `http://<IP_MAY_TINH>:8080`
   - Chạy lệnh: `flutter run`
