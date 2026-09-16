import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null;
  String? get errorMessage => _errorMessage;

  /// Kiểm tra token đã lưu khi mở app (auto-login)
  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final hoTen = prefs.getString('hoTen');
    final vaiTro = prefs.getString('vaiTro');
    final maNguoiDung = prefs.getInt('maNguoiDung');

    if (token != null && hoTen != null && vaiTro != null && maNguoiDung != null) {
      _user = User(
        maNguoiDung: maNguoiDung,
        hoTen: hoTen,
        vaiTro: vaiTro,
        token: token,
      );
      notifyListeners();
    }
  }

  /// Đăng nhập
  Future<bool> login(String tenDangNhap, String matKhau) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _authService.login(tenDangNhap, matKhau);
      _user = user;

      // Lưu token và thông tin user vào SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', user.token);
      await prefs.setString('hoTen', user.hoTen);
      await prefs.setString('vaiTro', user.vaiTro);
      await prefs.setInt('maNguoiDung', user.maNguoiDung);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Đăng ký
  Future<bool> register({
    required String tenDangNhap,
    required String matKhau,
    required String hoTen,
    required String email,
    String? soDienThoai,
    required String vaiTro,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.register(
        tenDangNhap: tenDangNhap,
        matKhau: matKhau,
        hoTen: hoTen,
        email: email,
        soDienThoai: soDienThoai,
        vaiTro: vaiTro,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Đăng xuất
  Future<void> logout() async {
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }

  /// Xóa lỗi
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

