# Database Migration Scripts (Flyway)

Thư mục này được cấu hình tự động với **Flyway Migration** trong Spring Boot. Khi backend khởi động, Flyway sẽ tự động quét và thực thi các script SQL mới tại đây vào MySQL database.

## Quy ước đặt tên file cho Flyway:
Flyway yêu cầu tên file phải tuân theo đúng cú pháp (chú ý có **2 dấu gạch dưới `__`** phân cách giữa version và mô tả):

1. **Versioned Migrations** (chạy đúng 1 lần theo thứ tự version):
   - Cú pháp: `V<Version>__<Mô_tả>.sql`
   - Ví dụ:
     - `V1__init_schema.sql` (Khởi tạo toàn bộ bảng cơ sở dữ liệu)
     - `V2__add_avatar_to_nguoidung.sql`
     - `V3__update_cam_bien_status.sql`

2. **Repeatable Migrations** (chạy lại mỗi khi nội dung file thay đổi - thường dùng cho Views, Functions, Stored Procedures):
   - Cú pháp: `R__<Mô_tả>.sql`
   - Ví dụ: `R__create_view_device_summary.sql`

## Cách hoạt động:
- Khi backend khởi động, Flyway tự động tạo bảng quản lý `flyway_schema_history` trong cơ sở dữ liệu.
- Flyway sẽ đối chiếu các file `V...` đã chạy và chỉ thực thi các file có version mới hơn.
- Cấu hình Flyway nằm tại: `smart-home-backend/src/main/resources/application.properties`.
