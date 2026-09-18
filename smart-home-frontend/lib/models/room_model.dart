class DeviceItem {
  final int maThietBi;
  final String tenThietBi;
  final String loaiThietBi;
  String trangThai; // "Bat" hoặc "Tat"
  final int? maPhong;
  final String? tenPhong;
  final String? ngayTao;

  DeviceItem({
    required this.maThietBi,
    required this.tenThietBi,
    required this.loaiThietBi,
    this.trangThai = 'Tat',
    this.maPhong,
    this.tenPhong,
    this.ngayTao,
  });

  bool get isOn =>
      trangThai.toLowerCase() == 'bat' || trangThai.toLowerCase() == 'on';

  void toggleStatus() {
    trangThai = isOn ? 'Tat' : 'Bat';
  }

  DeviceItem copyWith({
    int? maThietBi,
    String? tenThietBi,
    String? loaiThietBi,
    String? trangThai,
    int? maPhong,
    String? tenPhong,
    String? ngayTao,
  }) {
    return DeviceItem(
      maThietBi: maThietBi ?? this.maThietBi,
      tenThietBi: tenThietBi ?? this.tenThietBi,
      loaiThietBi: loaiThietBi ?? this.loaiThietBi,
      trangThai: trangThai ?? this.trangThai,
      maPhong: maPhong ?? this.maPhong,
      tenPhong: tenPhong ?? this.tenPhong,
      ngayTao: ngayTao ?? this.ngayTao,
    );
  }

  factory DeviceItem.fromJson(Map<String, dynamic> json) {
    return DeviceItem(
      maThietBi: json['maThietBi'] as int,
      tenThietBi: (json['tenThietBi'] ?? 'Thiết bị') as String,
      loaiThietBi: (json['loaiThietBi'] ?? 'Khac') as String,
      trangThai: (json['trangThai'] ?? 'Tat') as String,
      maPhong: json['maPhong'] as int?,
      tenPhong: json['tenPhong'] as String?,
      ngayTao: json['ngayTao'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'maThietBi': maThietBi,
      'tenThietBi': tenThietBi,
      'loaiThietBi': loaiThietBi,
      'trangThai': trangThai,
      if (maPhong != null) 'maPhong': maPhong,
      if (ngayTao != null) 'ngayTao': ngayTao,
    };
  }
}

class Room {
  final int maPhong;
  final String tenPhong;
  final int? maNha;
  final List<DeviceItem> danhSachThietBi;

  Room({
    required this.maPhong,
    required this.tenPhong,
    this.maNha,
    List<DeviceItem>? danhSachThietBi,
  }) : danhSachThietBi = danhSachThietBi ?? [];

  int get soLuongThietBi => danhSachThietBi.length;

  Room copyWith({
    int? maPhong,
    String? tenPhong,
    int? maNha,
    List<DeviceItem>? danhSachThietBi,
  }) {
    return Room(
      maPhong: maPhong ?? this.maPhong,
      tenPhong: tenPhong ?? this.tenPhong,
      maNha: maNha ?? this.maNha,
      danhSachThietBi: danhSachThietBi ?? List.from(this.danhSachThietBi),
    );
  }

  factory Room.fromJson(Map<String, dynamic> json) {
    var list = <DeviceItem>[];
    if (json['danhSachThietBi'] != null && json['danhSachThietBi'] is List) {
      list = (json['danhSachThietBi'] as List)
          .map((item) => DeviceItem.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return Room(
      maPhong: json['maPhong'] as int,
      tenPhong: (json['tenPhong'] ?? 'Phòng') as String,
      maNha: json['maNha'] as int?,
      danhSachThietBi: list,
    );
  }
}

class SensorItem {
  final int maCamBien;
  final String loaiCamBien;
  final int maPhong;
  final String? tenPhong;
  final int? maThietBi;
  final String? ngayTao;

  SensorItem({
    required this.maCamBien,
    required this.loaiCamBien,
    required this.maPhong,
    this.tenPhong,
    this.maThietBi,
    this.ngayTao,
  });

  String get tenLoaiHienThi {
    switch (loaiCamBien) {
      case 'NhietDo':
        return 'Nhiệt độ';
      case 'DoAm':
        return 'Độ ẩm';
      case 'ChuyenDong':
        return 'Chuyển động';
      case 'Cua':
        return 'Cửa';
      case 'Khoi':
        return 'Khói / Cháy';
      case 'RoRiNuoc':
        return 'Rò rỉ nước';
      default:
        return loaiCamBien;
    }
  }

  factory SensorItem.fromJson(Map<String, dynamic> json) {
    return SensorItem(
      maCamBien: json['maCamBien'] as int,
      loaiCamBien: (json['loaiCamBien'] ?? 'NhietDo') as String,
      maPhong: (json['maPhong'] ?? 0) as int,
      tenPhong: json['tenPhong'] as String?,
      maThietBi: json['maThietBi'] as int?,
      ngayTao: json['ngayTao'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'maCamBien': maCamBien,
      'loaiCamBien': loaiCamBien,
      'maPhong': maPhong,
      if (maThietBi != null) 'maThietBi': maThietBi,
      if (ngayTao != null) 'ngayTao': ngayTao,
    };
  }
}

class SensorReading {
  final double giaTri;
  final DateTime? thoiGianGhiNhan;

  SensorReading({required this.giaTri, this.thoiGianGhiNhan});

  String formatValue(String loaiCamBien) {
    switch (loaiCamBien) {
      case 'NhietDo':
        return '${giaTri.toStringAsFixed(1)}°C';
      case 'DoAm':
        return '${giaTri.toStringAsFixed(0)}%';
      case 'ChuyenDong':
        return giaTri > 0 ? 'Có chuyển động' : 'Không có';
      case 'Cua':
        return giaTri > 0 ? 'Đang mở' : 'Đang đóng';
      case 'Khoi':
        return giaTri > 0 ? 'CẢNH BÁO KHÓI' : 'An toàn';
      case 'RoRiNuoc':
        return giaTri > 0 ? 'RÒ RỈ NƯỚC' : 'Bình thường';
      default:
        return giaTri.toStringAsFixed(1);
    }
  }

  factory SensorReading.fromJson(Map<String, dynamic> json) {
    return SensorReading(
      giaTri: (json['giaTri'] as num).toDouble(),
      thoiGianGhiNhan: json['thoiGianGhiNhan'] != null
          ? DateTime.tryParse(json['thoiGianGhiNhan'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'giaTri': giaTri,
      if (thoiGianGhiNhan != null)
        'thoiGianGhiNhan': thoiGianGhiNhan!.toIso8601String(),
    };
  }
}
