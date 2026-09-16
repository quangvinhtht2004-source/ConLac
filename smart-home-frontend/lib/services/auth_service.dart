import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/user.dart';

class AuthService {
  /// Đăng nhập — gọi POST /api/auth/login
  /// Trả về User nếu thành công, throw Exception nếu thất bại
  Future<User> login(String tenDangNhap, String matKhau) async {
    final url = Uri.parse(ApiConfig.loginEndpoint);

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'tenDangNhap': tenDangNhap,
        'matKhau': matKhau,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return User.fromLoginResponse(data);
    } else if (response.statusCode == 401) {
      throw Exception('Sai tên đăng nhập hoặc mật khẩu');
    } else {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final message = data['message'] ?? 'Đăng nhập thất bại';
      throw Exception(message);
    }
  }

  /// Đăng ký — gọi POST /api/auth/register
  /// Trả về message thành công, throw Exception nếu thất bại
  Future<String> register({
    required String tenDangNhap,
    required String matKhau,
    required String hoTen,
    required String email,
    String? soDienThoai,
    required String vaiTro,
  }) async {
    final url = Uri.parse(ApiConfig.registerEndpoint);

    final body = <String, dynamic>{
      'tenDangNhap': tenDangNhap,
      'matKhau': matKhau,
      'hoTen': hoTen,
      'email': email,
      'vaiTro': vaiTro,
    };

    if (soDienThoai != null && soDienThoai.isNotEmpty) {
      body['soDienThoai'] = soDienThoai;
    }

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['message'] as String;
    } else {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final message = data['message'] ?? data.values.first ?? 'Đăng ký thất bại';
      throw Exception(message.toString());
    }
  }
}

