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
      body: jsonEncode({'tenDangNhap': tenDangNhap, 'matKhau': matKhau}),
    );

    if (response.statusCode == 200) {
      final data =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return User.fromLoginResponse(data);
    } else if (response.statusCode == 401) {
      throw Exception('Sai tên đăng nhập hoặc mật khẩu');
    } else {
      if (response.body.isEmpty) {
        throw Exception('Máy chủ phản hồi lỗi (${response.statusCode})');
      }
      try {
        final data =
            jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        final message =
            data['message'] ?? 'Đăng nhập thất bại (${response.statusCode})';
        throw Exception(message);
      } catch (e) {
        if (e is Exception) rethrow;
        throw Exception('Lỗi máy chủ (${response.statusCode})');
      }
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
      final data =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return data['message'] as String;
    } else {
      if (response.body.isEmpty) {
        throw Exception('Máy chủ phản hồi lỗi (${response.statusCode})');
      }
      try {
        final data =
            jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        final message =
            data['message'] ?? data.values.first ?? 'Đăng ký thất bại';
        throw Exception(message.toString());
      } catch (e) {
        if (e is Exception) rethrow;
        throw Exception('Lỗi máy chủ (${response.statusCode})');
      }
    }
  }

  /// Lấy thông tin user hiện tại từ token: GET /api/user/me
  Future<Map<String, dynamic>> getCurrentUser(String token) async {
    final url = Uri.parse(ApiConfig.currentUserEndpoint);
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes))
          as Map<String, dynamic>;
    } else if (response.statusCode == 401) {
      throw Exception('Phiên đăng nhập đã hết hạn');
    } else {
      throw Exception(
        'Không thể tải thông tin tài khoản (${response.statusCode})',
      );
    }
  }

  /// Kiểm tra quyền Admin mẫu từ backend: GET /api/admin/ping
  Future<String> pingAdmin(String token) async {
    final url = Uri.parse(ApiConfig.adminPingEndpoint);
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return (data['message'] ?? 'Thành công') as String;
    } else if (response.statusCode == 403) {
      throw Exception('403 Forbidden: Tài khoản này không có quyền Admin');
    } else if (response.statusCode == 401) {
      throw Exception('401 Unauthorized: Chưa xác thực hoặc token hết hạn');
    } else {
      throw Exception('Lỗi kiểm tra quyền Admin (${response.statusCode})');
    }
  }
}
