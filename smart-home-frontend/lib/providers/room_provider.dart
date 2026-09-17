import 'package:flutter/material.dart';

import '../models/room_model.dart';
import '../services/room_service.dart';

class RoomProvider extends ChangeNotifier {
  final RoomService _roomService = RoomService();

  List<Room> _rooms = [];
  Room? _selectedRoom;
  List<DeviceItem> _currentRoomDevices = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Room> get rooms => _rooms;
  Room? get selectedRoom => _selectedRoom;
  List<DeviceItem> get currentRoomDevices => _currentRoomDevices;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Tổng số thiết bị trên toàn bộ các phòng
  int get totalDeviceCount {
    int total = 0;
    for (var r in _rooms) {
      total += r.soLuongThietBi;
    }
    return total;
  }

  // Tổng số thiết bị đang BẬT
  int get activeDeviceCount {
    int active = 0;
    for (var r in _rooms) {
      for (var d in r.danhSachThietBi) {
        if (d.isOn) active++;
      }
    }
    return active;
  }

  /// Khởi tạo dữ liệu mẫu ban đầu nếu backend chưa có
  List<Room> _getFallbackRooms() {
    return [
      Room(
        maPhong: 1,
        tenPhong: 'Phòng Khách',
        maNha: 1,
        danhSachThietBi: [
          DeviceItem(
            maThietBi: 1,
            tenThietBi: 'Đèn trần chính',
            loaiThietBi: 'Den',
            trangThai: 'Bat',
          ),
          DeviceItem(
            maThietBi: 2,
            tenThietBi: 'Đèn cây góc',
            loaiThietBi: 'Den',
            trangThai: 'Tat',
          ),
          DeviceItem(
            maThietBi: 3,
            tenThietBi: 'Máy lạnh Daikin',
            loaiThietBi: 'DieuHoa',
            trangThai: 'Bat',
          ),
          DeviceItem(
            maThietBi: 4,
            tenThietBi: 'Rèm cửa thông minh',
            loaiThietBi: 'Rem',
            trangThai: 'Bat',
          ),
          DeviceItem(
            maThietBi: 5,
            tenThietBi: 'Cửa ban công',
            loaiThietBi: 'Cua',
            trangThai: 'Tat',
          ),
          DeviceItem(
            maThietBi: 6,
            tenThietBi: 'Loa Apple Home',
            loaiThietBi: 'Loa',
            trangThai: 'Bat',
          ),
        ],
      ),
      Room(
        maPhong: 2,
        tenPhong: 'Phòng Ngủ Master',
        maNha: 1,
        danhSachThietBi: [
          DeviceItem(
            maThietBi: 7,
            tenThietBi: 'Đèn ngủ ấm',
            loaiThietBi: 'Den',
            trangThai: 'Bat',
          ),
          DeviceItem(
            maThietBi: 8,
            tenThietBi: 'Điều hòa Panasonic',
            loaiThietBi: 'DieuHoa',
            trangThai: 'Tat',
          ),
          DeviceItem(
            maThietBi: 9,
            tenThietBi: 'Máy lọc không khí',
            loaiThietBi: 'Quat',
            trangThai: 'Bat',
          ),
        ],
      ),
      Room(
        maPhong: 3,
        tenPhong: 'Phòng Bếp',
        maNha: 1,
        danhSachThietBi: [
          DeviceItem(
            maThietBi: 10,
            tenThietBi: 'Đèn bếp đảo',
            loaiThietBi: 'Den',
            trangThai: 'Tat',
          ),
          DeviceItem(
            maThietBi: 11,
            tenThietBi: 'Máy hút mùi',
            loaiThietBi: 'Quat',
            trangThai: 'Tat',
          ),
          DeviceItem(
            maThietBi: 12,
            tenThietBi: 'Cảm biến rò rỉ gas',
            loaiThietBi: 'CamBien',
            trangThai: 'Bat',
          ),
        ],
      ),
      Room(
        maPhong: 4,
        tenPhong: 'Phòng Làm Việc',
        maNha: 1,
        danhSachThietBi: [
          DeviceItem(
            maThietBi: 13,
            tenThietBi: 'Đèn bàn làm việc',
            loaiThietBi: 'Den',
            trangThai: 'Bat',
          ),
          DeviceItem(
            maThietBi: 14,
            tenThietBi: 'Quạt đứng Xiaomi',
            loaiThietBi: 'Quat',
            trangThai: 'Bat',
          ),
        ],
      ),
    ];
  }

  /// Tải danh sách phòng từ Backend
  Future<void> fetchRooms(String? token) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    if (token == null || token.isEmpty) {
      _rooms = _getFallbackRooms();
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      final list = await _roomService.getRooms(token);
      _rooms = list;
    } catch (e) {
      // Chỉ dùng dữ liệu mẫu fallback nếu hoàn toàn không kết nối được backend
      if (_rooms.isEmpty) {
        _rooms = _getFallbackRooms();
      }
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Chọn phòng để xem chi tiết (gọi GET /api/phong/{maPhong})
  Future<void> selectRoom(Room room, String? token) async {
    _selectedRoom = room;
    _currentRoomDevices = List.from(room.danhSachThietBi);
    notifyListeners();

    if (token != null && token.isNotEmpty) {
      try {
        final detail = await _roomService.getRoomDetail(room.maPhong, token);
        _selectedRoom = detail;
        _currentRoomDevices = List.from(detail.danhSachThietBi);

        final idx = _rooms.indexWhere((r) => r.maPhong == room.maPhong);
        if (idx != -1) {
          _rooms[idx] = detail;
        }
        notifyListeners();
      } catch (_) {
        // Fallback: nếu lấy chi tiết phòng lỗi thì thử lấy danh sách thiết bị
        try {
          final devices = await _roomService.getDevicesByRoom(
            room.maPhong,
            token,
          );
          if (devices.isNotEmpty) {
            _currentRoomDevices = devices;
            room.danhSachThietBi.clear();
            room.danhSachThietBi.addAll(devices);
            notifyListeners();
          }
        } catch (_) {}
      }
    }
  }

  /// Tải chi tiết một phòng từ backend: GET /api/phong/{maPhong}
  Future<Room?> fetchRoomDetail(int maPhong, String? token) async {
    if (token == null || token.isEmpty) return _selectedRoom;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final roomDetail = await _roomService.getRoomDetail(maPhong, token);
      _selectedRoom = roomDetail;
      _currentRoomDevices = List.from(roomDetail.danhSachThietBi);

      final index = _rooms.indexWhere((r) => r.maPhong == maPhong);
      if (index != -1) {
        _rooms[index] = roomDetail;
      }
      _isLoading = false;
      notifyListeners();
      return roomDetail;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return _selectedRoom;
    }
  }

  /// Gạt switch BẬT / TẮT thiết bị
  void toggleDevice(DeviceItem device) {
    device.toggleStatus();
    notifyListeners();
  }

  /// Bật hết / Tắt hết thiết bị trong phòng
  void setAllDevicesState(bool turnOn) {
    for (var device in _currentRoomDevices) {
      device.trangThai = turnOn ? 'Bat' : 'Tat';
    }
    notifyListeners();
  }

  /// Tạo phòng mới (Admin)
  Future<bool> createRoom(String tenPhong, String? token) async {
    if (token == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final newRoom = await _roomService.createRoom(tenPhong, token);
      _rooms.add(newRoom);
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

  /// Thêm thiết bị mới vào phòng (Admin)
  Future<bool> createDevice({
    required String tenThietBi,
    required String loaiThietBi,
    required int maPhong,
    required String? token,
  }) async {
    if (token == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final newDevice = await _roomService.createDevice(
        tenThietBi: tenThietBi,
        loaiThietBi: loaiThietBi,
        maPhong: maPhong,
        token: token,
      );
      _currentRoomDevices.add(newDevice);
      _selectedRoom?.danhSachThietBi.add(newDevice);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      // Fallback cục bộ
      final localDevice = DeviceItem(
        maThietBi: DateTime.now().millisecondsSinceEpoch % 10000,
        tenThietBi: tenThietBi,
        loaiThietBi: loaiThietBi,
        trangThai: 'Tat',
        maPhong: maPhong,
      );
      _currentRoomDevices.add(localDevice);
      _selectedRoom?.danhSachThietBi.add(localDevice);
      _isLoading = false;
      notifyListeners();
      return true;
    }
  }

  /// Xóa phòng (Admin)
  Future<bool> deleteRoom(int maPhong, String? token) async {
    if (token == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      await _roomService.deleteRoom(maPhong, token);
    } catch (e) {
      // Nếu phòng không có trên server (dữ liệu mẫu demo), vẫn xóa khỏi giao diện
    }
    _rooms.removeWhere((r) => r.maPhong == maPhong);
    if (_selectedRoom?.maPhong == maPhong) {
      _selectedRoom = null;
      _currentRoomDevices.clear();
    }
    _isLoading = false;
    notifyListeners();
    return true;
  }

  /// Cập nhật thông tin / đổi tên phòng (Admin): PUT /api/phong/{maPhong}
  Future<bool> updateRoom(
    int maPhong,
    String tenPhong,
    String? token, {
    int maNha = 1,
  }) async {
    if (token == null) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedRoom = await _roomService.updateRoom(
        maPhong,
        tenPhong,
        token,
        maNha: maNha,
      );
      final index = _rooms.indexWhere((r) => r.maPhong == maPhong);
      if (index != -1) {
        _rooms[index] = updatedRoom;
      }
      if (_selectedRoom?.maPhong == maPhong) {
        _selectedRoom = updatedRoom;
      }
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

  /// Lấy thông tin chi tiết một thiết bị đơn lẻ: GET /api/thiet-bi/{maThietBi}
  Future<DeviceItem?> fetchDeviceDetail(int maThietBi, String? token) async {
    if (token == null || token.isEmpty) {
      return _currentRoomDevices.firstWhere(
        (d) => d.maThietBi == maThietBi,
        orElse: () => DeviceItem(
          maThietBi: maThietBi,
          tenThietBi: 'Thiết bị',
          loaiThietBi: 'Khac',
        ),
      );
    }

    try {
      final device = await _roomService.getDeviceDetail(maThietBi, token);
      final idx = _currentRoomDevices.indexWhere(
        (d) => d.maThietBi == maThietBi,
      );
      if (idx != -1) {
        _currentRoomDevices[idx] = device;
      }
      return device;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return null;
    }
  }

  /// Cập nhật thiết bị (Admin): PUT /api/thiet-bi/{maThietBi}
  Future<bool> updateDevice({
    required int maThietBi,
    required String tenThietBi,
    required String loaiThietBi,
    required int maPhong,
    required String? token,
  }) async {
    if (token == null) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await _roomService.updateDevice(
        maThietBi: maThietBi,
        tenThietBi: tenThietBi,
        loaiThietBi: loaiThietBi,
        maPhong: maPhong,
        token: token,
      );

      final idx = _currentRoomDevices.indexWhere(
        (d) => d.maThietBi == maThietBi,
      );
      if (idx != -1) {
        _currentRoomDevices[idx] = updated;
      }

      if (_selectedRoom != null) {
        final rIdx = _selectedRoom!.danhSachThietBi.indexWhere(
          (d) => d.maThietBi == maThietBi,
        );
        if (rIdx != -1) {
          _selectedRoom!.danhSachThietBi[rIdx] = updated;
        }
      }

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

  /// Xóa thiết bị
  Future<void> deleteDevice(int maThietBi, String? token) async {
    if (token != null) {
      try {
        await _roomService.deleteDevice(maThietBi, token);
      } catch (_) {}
    }
    _currentRoomDevices.removeWhere((d) => d.maThietBi == maThietBi);
    _selectedRoom?.danhSachThietBi.removeWhere((d) => d.maThietBi == maThietBi);
    notifyListeners();
  }
}
