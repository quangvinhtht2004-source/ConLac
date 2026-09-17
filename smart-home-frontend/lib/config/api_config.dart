class ApiConfig {
  // === CẤU HÌNH BASE URL ===
  // Chọn 1 trong 3 dòng phù hợp với thiết bị bạn dùng để test:

  // 1. Máy ảo Android (Emulator):
  // static const String baseUrl = 'http://10.0.2.2:8080';

  // 2. Điện thoại thật (cùng mạng Wi-Fi):
  // static const String baseUrl = 'http://192.168.123.5:8080';

  // 3. Chạy trên Web (Chrome/Edge):
  static const String baseUrl = 'http://localhost:8080';

  // === ENDPOINTS ===
  static const String loginEndpoint = '$baseUrl/api/auth/login';
  static const String registerEndpoint = '$baseUrl/api/auth/register';
  static const String currentUserEndpoint = '$baseUrl/api/user/me';
  static const String adminPingEndpoint = '$baseUrl/api/admin/ping';
  static const String roomsEndpoint = '$baseUrl/api/phong';
  static const String devicesEndpoint = '$baseUrl/api/thiet-bi';
}
