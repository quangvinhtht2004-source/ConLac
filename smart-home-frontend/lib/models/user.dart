class User {
  final int maNguoiDung;
  final String hoTen;
  final String vaiTro;
  final String token;

  User({
    required this.maNguoiDung,
    required this.hoTen,
    required this.vaiTro,
    required this.token,
  });

  /// Parse từ JSON response của API login
  factory User.fromLoginResponse(Map<String, dynamic> json) {
    return User(
      maNguoiDung: json['maNguoiDung'] as int,
      hoTen: json['hoTen'] as String,
      vaiTro: json['vaiTro'] as String,
      token: json['token'] as String,
    );
  }
}

