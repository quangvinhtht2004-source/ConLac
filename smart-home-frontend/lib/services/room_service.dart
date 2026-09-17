import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/room_model.dart';

class RoomService {
  /// Lấy danh sách phòng theo nhà: GET /api/phong?maNha=1
  Future<List<Room>> getRooms(String token, {int maNha = 1}) async {
    final url = Uri.parse('${ApiConfig.roomsEndpoint}?maNha=$maNha');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return data
          .map((json) => Room.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Không thể tải danh sách phòng: ${response.statusCode}');
    }
  }

  /// Lấy chi tiết phòng (bao gồm danh sách thiết bị): GET /api/phong/{maPhong}
  Future<Room> getRoomDetail(int maPhong, String token) async {
    final url = Uri.parse('${ApiConfig.roomsEndpoint}/$maPhong');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(
        utf8.decode(response.bodyBytes),
      );
      return Room.fromJson(data);
    } else {
      throw Exception('Không thể tải chi tiết phòng: ${response.statusCode}');
    }
  }

  /// Tạo phòng mới (Admin): POST /api/phong
  Future<Room> createRoom(
    String tenPhong,
    String token, {
    int maNha = 1,
  }) async {
    final url = Uri.parse(ApiConfig.roomsEndpoint);
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'tenPhong': tenPhong, 'maNha': maNha}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> data = jsonDecode(
        utf8.decode(response.bodyBytes),
      );
      return Room.fromJson(data);
    } else {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      final msg = data['message'] ?? 'Thêm phòng thất bại';
      throw Exception(msg);
    }
  }

  /// Xóa phòng (Admin): DELETE /api/phong/{maPhong}
  Future<void> deleteRoom(int maPhong, String token) async {
    final url = Uri.parse('${ApiConfig.roomsEndpoint}/$maPhong');
    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Xóa phòng thất bại');
    }
  }

  /// Cập nhật phòng (Admin): PUT /api/phong/{maPhong}
  Future<Room> updateRoom(
    int maPhong,
    String tenPhong,
    String token, {
    int maNha = 1,
  }) async {
    final url = Uri.parse('${ApiConfig.roomsEndpoint}/$maPhong');
    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'tenPhong': tenPhong, 'maNha': maNha}),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(
        utf8.decode(response.bodyBytes),
      );
      return Room.fromJson(data);
    } else {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      final msg = data['message'] ?? 'Cập nhật phòng thất bại';
      throw Exception(msg);
    }
  }

  /// Lấy danh sách thiết bị theo phòng: GET /api/thiet-bi?maPhong={maPhong}
  Future<List<DeviceItem>> getDevicesByRoom(int maPhong, String token) async {
    final url = Uri.parse('${ApiConfig.devicesEndpoint}?maPhong=$maPhong');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return data
          .map((json) => DeviceItem.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception(
        'Không thể tải danh sách thiết bị: ${response.statusCode}',
      );
    }
  }

  /// Tạo thiết bị mới (Admin): POST /api/thiet-bi
  Future<DeviceItem> createDevice({
    required String tenThietBi,
    required String loaiThietBi,
    required int maPhong,
    required String token,
  }) async {
    final url = Uri.parse(ApiConfig.devicesEndpoint);
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'tenThietBi': tenThietBi,
        'loaiThietBi': loaiThietBi,
        'maPhong': maPhong,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> data = jsonDecode(
        utf8.decode(response.bodyBytes),
      );
      return DeviceItem.fromJson(data);
    } else {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      final msg = data['message'] ?? 'Thêm thiết bị thất bại';
      throw Exception(msg);
    }
  }

  /// Xóa thiết bị (Admin): DELETE /api/thiet-bi/{maThietBi}
  Future<void> deleteDevice(int maThietBi, String token) async {
    final url = Uri.parse('${ApiConfig.devicesEndpoint}/$maThietBi');
    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Xóa thiết bị thất bại');
    }
  }

  /// Lấy chi tiết thiết bị đơn lẻ: GET /api/thiet-bi/{maThietBi}
  Future<DeviceItem> getDeviceDetail(int maThietBi, String token) async {
    final url = Uri.parse('${ApiConfig.devicesEndpoint}/$maThietBi');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(
        utf8.decode(response.bodyBytes),
      );
      return DeviceItem.fromJson(data);
    } else {
      throw Exception(
        'Không thể tải chi tiết thiết bị: ${response.statusCode}',
      );
    }
  }

  /// Cập nhật thiết bị (Admin): PUT /api/thiet-bi/{maThietBi}
  Future<DeviceItem> updateDevice({
    required int maThietBi,
    required String tenThietBi,
    required String loaiThietBi,
    required int maPhong,
    required String token,
  }) async {
    final url = Uri.parse('${ApiConfig.devicesEndpoint}/$maThietBi');
    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'tenThietBi': tenThietBi,
        'loaiThietBi': loaiThietBi,
        'maPhong': maPhong,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(
        utf8.decode(response.bodyBytes),
      );
      return DeviceItem.fromJson(data);
    } else {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      final msg = data['message'] ?? 'Cập nhật thiết bị thất bại';
      throw Exception(msg);
    }
  }
}
