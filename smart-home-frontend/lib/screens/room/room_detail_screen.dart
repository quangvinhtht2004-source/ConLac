import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/room_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/room_provider.dart';

class RoomDetailScreen extends StatefulWidget {
  final Room room;

  const RoomDetailScreen({super.key, required this.room});

  @override
  State<RoomDetailScreen> createState() => _RoomDetailScreenState();
}

class _RoomDetailScreenState extends State<RoomDetailScreen> {
  String _selectedCategory = 'Tất cả';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = context.read<AuthProvider>().user?.token;
      // Gọi GET /api/phong/{maPhong} khi mở màn hình chi tiết phòng
      context.read<RoomProvider>().fetchRoomDetail(widget.room.maPhong, token);
    });
  }

  // Hộp thoại xác nhận xóa phòng này (Admin)
  void _confirmDeleteCurrentRoom(String? token) async {
    final roomProv = context.read<RoomProvider>();
    final currentRoom = roomProv.selectedRoom ?? widget.room;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F36),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
            SizedBox(width: 8),
            Text(
              'Xóa phòng',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
        content: Text(
          'Bạn có chắc chắn muốn xóa phòng "${currentRoom.tenPhong}" và toàn bộ thiết bị trong phòng không?',
          style: const TextStyle(color: Color(0xFF8D8FA1)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Hủy',
              style: TextStyle(color: Color(0xFF8D8FA1)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Xóa phòng',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final ok = await roomProv.deleteRoom(currentRoom.maPhong, token);
      if (!mounted) return;
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã xóa phòng "${currentRoom.tenPhong}" thành công!'),
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context); // Quay về Dashboard
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(roomProv.errorMessage ?? 'Xóa phòng thất bại'),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // Hộp thoại đổi tên phòng (Admin): PUT /api/phong/{maPhong}
  void _showEditRoomDialog(BuildContext context) {
    final roomProv = context.read<RoomProvider>();
    final currentRoom = roomProv.selectedRoom ?? widget.room;
    final token = context.read<AuthProvider>().user?.token;
    final controller = TextEditingController(text: currentRoom.tenPhong);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F36),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.edit_outlined, color: Colors.blueAccent),
            SizedBox(width: 8),
            Text(
              'Đổi tên phòng',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nhập tên phòng mới (gọi PUT /api/phong/{id}):',
              style: TextStyle(color: Color(0xFF8D8FA1), fontSize: 12),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Tên phòng...',
                hintStyle: const TextStyle(color: Color(0xFF8D8FA1)),
                filled: true,
                fillColor: const Color(0xFF0A0E21),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF2A2F46)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.blueAccent),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Hủy',
              style: TextStyle(color: Color(0xFF8D8FA1)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                Navigator.pop(ctx);
                final messenger = ScaffoldMessenger.of(context);
                final ok = await roomProv.updateRoom(
                  currentRoom.maPhong,
                  newName,
                  token,
                  maNha: currentRoom.maNha ?? 1,
                );
                if (mounted) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        ok
                            ? 'Đã đổi tên phòng thành "$newName"!'
                            : (roomProv.errorMessage ??
                                  'Cập nhật phòng thất bại'),
                      ),
                      backgroundColor: ok
                          ? Colors.green.shade700
                          : Colors.red.shade700,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            child: const Text(
              'Lưu thay đổi',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // Hộp thoại xem chi tiết 1 thiết bị đơn lẻ: GET /api/thiet-bi/{maThietBi}
  void _showDeviceDetailDialog(BuildContext context, DeviceItem device) {
    final auth = context.read<AuthProvider>();
    final roomProv = context.read<RoomProvider>();

    showDialog(
      context: context,
      builder: (ctx) => _DeviceDetailDialog(
        device: device,
        token: auth.user?.token,
        roomProv: roomProv,
      ),
    );
  }

  // Hộp thoại chỉnh sửa thông tin thiết bị (Admin): PUT /api/thiet-bi/{maThietBi}
  void _showEditDeviceDialog(BuildContext context, DeviceItem device) {
    final nameController = TextEditingController(text: device.tenThietBi);
    String selectedType = device.loaiThietBi;
    const validTypes = [
      'Den',
      'DieuHoa',
      'Quat',
      'Rem',
      'Loa',
      'Cua',
      'CamBien',
      'Khac',
    ];
    if (!validTypes.contains(selectedType)) {
      selectedType = 'Khac';
    }

    final auth = context.read<AuthProvider>();
    final roomProv = context.read<RoomProvider>();
    final currentRoom = roomProv.selectedRoom ?? widget.room;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1A1F36),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.edit_outlined, color: Colors.blueAccent),
              SizedBox(width: 8),
              Text(
                'Sửa thiết bị',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Cập nhật thông tin (gọi PUT /api/thiet-bi/{id}):',
                style: TextStyle(color: Color(0xFF8D8FA1), fontSize: 12),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nameController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Tên thiết bị',
                  labelStyle: const TextStyle(color: Color(0xFF8D8FA1)),
                  filled: true,
                  fillColor: const Color(0xFF0A0E21),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF2A2F46)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.blueAccent),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A0E21),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF2A2F46)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedType,
                    isExpanded: true,
                    dropdownColor: const Color(0xFF1A1F36),
                    style: const TextStyle(color: Colors.white),
                    items: const [
                      DropdownMenuItem(
                        value: 'Den',
                        child: Text('💡 Đèn chiếu sáng (Den)'),
                      ),
                      DropdownMenuItem(
                        value: 'DieuHoa',
                        child: Text('❄️ Máy lạnh / Điều hòa (DieuHoa)'),
                      ),
                      DropdownMenuItem(
                        value: 'Quat',
                        child: Text('🌀 Quạt / Máy lọc (Quat)'),
                      ),
                      DropdownMenuItem(
                        value: 'Rem',
                        child: Text('🪟 Rèm cửa thông minh (Rem)'),
                      ),
                      DropdownMenuItem(
                        value: 'Loa',
                        child: Text('🔊 Loa thông minh (Loa)'),
                      ),
                      DropdownMenuItem(
                        value: 'Cua',
                        child: Text('🚪 Cửa / Cổng (Cua)'),
                      ),
                      DropdownMenuItem(
                        value: 'CamBien',
                        child: Text('📡 Cảm biến (CamBien)'),
                      ),
                      DropdownMenuItem(
                        value: 'Khac',
                        child: Text('⚡ Khác (Khac)'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() {
                          selectedType = val;
                        });
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'Hủy',
                style: TextStyle(color: Color(0xFF8D8FA1)),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () async {
                final newName = nameController.text.trim();
                if (newName.isNotEmpty) {
                  Navigator.pop(ctx);
                  final messenger = ScaffoldMessenger.of(context);
                  final ok = await roomProv.updateDevice(
                    maThietBi: device.maThietBi,
                    tenThietBi: newName,
                    loaiThietBi: selectedType,
                    maPhong: currentRoom.maPhong,
                    token: auth.user?.token,
                  );
                  if (mounted) {
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(
                          ok
                              ? 'Đã cập nhật thiết bị "$newName"!'
                              : (roomProv.errorMessage ??
                                    'Cập nhật thiết bị thất bại'),
                        ),
                        backgroundColor: ok
                            ? Colors.green.shade700
                            : Colors.red.shade700,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
              },
              child: const Text(
                'Lưu thay đổi',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Hộp thoại thêm thiết bị mới dành cho Admin
  void _showAddDeviceDialog(BuildContext context) {
    final nameController = TextEditingController();
    String selectedType = 'Den';
    final auth = context.read<AuthProvider>();
    final roomProv = context.read<RoomProvider>();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1A1F36),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.add_circle_outline, color: Colors.blueAccent),
              SizedBox(width: 8),
              Text(
                'Thêm thiết bị mới',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tên thiết bị:',
                style: TextStyle(color: Color(0xFF8D8FA1), fontSize: 12),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'VD: Đèn trần, Quạt hút...',
                  hintStyle: const TextStyle(color: Color(0xFF8D8FA1)),
                  filled: true,
                  fillColor: const Color(0xFF0A0E21),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF2A2F46)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF2A2F46)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.blueAccent),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Loại thiết bị:',
                style: TextStyle(color: Color(0xFF8D8FA1), fontSize: 12),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A0E21),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF2A2F46)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedType,
                    isExpanded: true,
                    dropdownColor: const Color(0xFF1A1F36),
                    style: const TextStyle(color: Colors.white),
                    items: const [
                      DropdownMenuItem(
                        value: 'Den',
                        child: Text('💡 Đèn chiếu sáng (Den)'),
                      ),
                      DropdownMenuItem(
                        value: 'Quat',
                        child: Text('🌀 Quạt / Thông gió (Quat)'),
                      ),
                      DropdownMenuItem(
                        value: 'DieuHoa',
                        child: Text('❄️ Điều hòa (DieuHoa)'),
                      ),
                      DropdownMenuItem(
                        value: 'Rem',
                        child: Text('🪟 Rèm cửa thông minh (Rem)'),
                      ),
                      DropdownMenuItem(
                        value: 'Loa',
                        child: Text('🔊 Loa / Âm thanh (Loa)'),
                      ),
                      DropdownMenuItem(
                        value: 'Khac',
                        child: Text('⚡ Thiết bị khác (Khac)'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() {
                          selectedType = val;
                        });
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'Hủy',
                style: TextStyle(color: Color(0xFF8D8FA1)),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isNotEmpty) {
                  Navigator.pop(ctx);
                  if (!mounted) return;
                  final messenger = ScaffoldMessenger.of(context);
                  final ok = await roomProv.createDevice(
                    tenThietBi: name,
                    loaiThietBi: selectedType,
                    maPhong: widget.room.maPhong,
                    token: auth.user?.token,
                  );
                  if (mounted && ok) {
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(
                          'Đã thêm "$name" vào ${widget.room.tenPhong}!',
                        ),
                        backgroundColor: Colors.green.shade700,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
              },
              child: const Text(
                'Thêm thiết bị',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Hộp thoại thêm cảm biến mới vào phòng (Admin): POST /api/cam-bien
  void _showAddSensorDialog(BuildContext context) {
    String selectedType = 'NhietDo';
    int? selectedDeviceId;
    final auth = context.read<AuthProvider>();
    final roomProv = context.read<RoomProvider>();
    final currentRoom = roomProv.selectedRoom ?? widget.room;
    final devices = roomProv.currentRoomDevices;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1A1F36),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.sensors, color: Colors.blueAccent),
              SizedBox(width: 8),
              Text(
                'Thêm cảm biến mới',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Chọn loại cảm biến (gọi POST /api/cam-bien):',
                  style: TextStyle(color: Color(0xFF8D8FA1), fontSize: 12),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A0E21),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF2A2F46)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedType,
                      isExpanded: true,
                      dropdownColor: const Color(0xFF1A1F36),
                      style: const TextStyle(color: Colors.white),
                      items: const [
                        DropdownMenuItem(
                          value: 'NhietDo',
                          child: Text('🌡️ Cảm biến Nhiệt độ (NhietDo)'),
                        ),
                        DropdownMenuItem(
                          value: 'DoAm',
                          child: Text('💧 Cảm biến Độ ẩm (DoAm)'),
                        ),
                        DropdownMenuItem(
                          value: 'ChuyenDong',
                          child: Text('🚶 Cảm biến Chuyển động (ChuyenDong)'),
                        ),
                        DropdownMenuItem(
                          value: 'Cua',
                          child: Text('🚪 Cảm biến Cửa (Cua)'),
                        ),
                        DropdownMenuItem(
                          value: 'Khoi',
                          child: Text('💨 Cảm biến Khói / Cháy (Khoi)'),
                        ),
                        DropdownMenuItem(
                          value: 'RoRiNuoc',
                          child: Text('💦 Cảm biến Rò rỉ nước (RoRiNuoc)'),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() {
                            selectedType = val;
                          });
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Liên kết thiết bị (tùy chọn):',
                  style: TextStyle(color: Color(0xFF8D8FA1), fontSize: 12),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A0E21),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF2A2F46)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int?>(
                      value: selectedDeviceId,
                      isExpanded: true,
                      dropdownColor: const Color(0xFF1A1F36),
                      style: const TextStyle(color: Colors.white),
                      items: [
                        const DropdownMenuItem<int?>(
                          value: null,
                          child: Text('-- Không liên kết thiết bị --'),
                        ),
                        ...devices.map(
                          (d) => DropdownMenuItem<int?>(
                            value: d.maThietBi,
                            child: Text('${d.tenThietBi} (#${d.maThietBi})'),
                          ),
                        ),
                      ],
                      onChanged: (val) {
                        setDialogState(() {
                          selectedDeviceId = val;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Cảm biến sẽ được gán trực tiếp vào ${currentRoom.tenPhong} (Mã phòng: ${currentRoom.maPhong}).',
                  style: const TextStyle(
                    color: Color(0xFF8D8FA1),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'Hủy',
                style: TextStyle(color: Color(0xFF8D8FA1)),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () async {
                Navigator.pop(ctx);
                final messenger = ScaffoldMessenger.of(context);
                final ok = await roomProv.createSensor(
                  loaiCamBien: selectedType,
                  maPhong: currentRoom.maPhong,
                  maThietBi: selectedDeviceId,
                  token: auth.user?.token,
                );
                if (mounted) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        ok
                            ? 'Đã thêm cảm biến thành công vào ${currentRoom.tenPhong}!'
                            : (roomProv.errorMessage ??
                                  'Thêm cảm biến thất bại'),
                      ),
                      backgroundColor: ok
                          ? Colors.green.shade700
                          : Colors.red.shade700,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: const Text(
                'Thêm cảm biến',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final roomProv = context.watch<RoomProvider>();
    final isAdmin = auth.user?.vaiTro == 'Admin';
    final currentRoom = roomProv.selectedRoom ?? widget.room;
    final devices = roomProv.currentRoomDevices;

    // Lọc thiết bị theo danh mục nếu có chọn
    final filteredDevices = devices.where((d) {
      if (_selectedCategory == 'Tất cả') return true;
      if (_selectedCategory == 'Đèn') {
        return d.loaiThietBi.toLowerCase().contains('den');
      }
      if (_selectedCategory == 'Điều hòa') {
        return d.loaiThietBi.toLowerCase().contains('dieuhoa');
      }
      if (_selectedCategory == 'Quạt') {
        return d.loaiThietBi.toLowerCase().contains('quat');
      }
      if (_selectedCategory == 'Rèm') {
        return d.loaiThietBi.toLowerCase().contains('rem');
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0E21),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          currentRoom.tenPhong,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          // Nút làm mới chi tiết phòng (Gọi GET /api/phong/{maPhong})
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white, size: 20),
            tooltip: 'Làm mới chi tiết phòng',
            onPressed: () =>
                roomProv.fetchRoomDetail(widget.room.maPhong, auth.user?.token),
          ),
          // Nút thêm thiết bị nhanh trên App Bar cho Admin
          if (isAdmin) ...[
            TextButton.icon(
              onPressed: () => _showAddDeviceDialog(context),
              icon: const Icon(Icons.add, color: Colors.blueAccent, size: 18),
              label: const Text(
                'Thêm',
                style: TextStyle(
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Nút sửa tên phòng cho Admin (Gọi PUT /api/phong/{maPhong})
            IconButton(
              icon: const Icon(
                Icons.edit_outlined,
                color: Colors.blueAccent,
                size: 20,
              ),
              tooltip: 'Đổi tên phòng này',
              onPressed: () => _showEditRoomDialog(context),
            ),
            // Nút xóa phòng cho Admin (Gọi DELETE /api/phong/{maPhong})
            IconButton(
              icon: const Icon(
                Icons.delete_outline,
                color: Colors.redAccent,
                size: 20,
              ),
              tooltip: 'Xóa phòng này',
              onPressed: () => _confirmDeleteCurrentRoom(auth.user?.token),
            ),
          ],
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () =>
              roomProv.fetchRoomDetail(widget.room.maPhong, auth.user?.token),
          color: Colors.blueAccent,
          backgroundColor: const Color(0xFF1A1F36),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),

                // === HEADER PHÒNG: Tên + Trạng thái + Tầng ===
                _buildRoomHeader(currentRoom.tenPhong, devices.length),
                const SizedBox(height: 20),

                // === MÔI TRƯỜNG PHÒNG (Nhiệt độ, Độ ẩm, kWh) ===
                _buildRoomEnvironment(roomProv),
                const SizedBox(height: 16),

                // === CẢM BIẾN TRONG PHÒNG (GET/POST /api/cam-bien) ===
                _buildRoomSensorsSection(
                  context,
                  roomProv,
                  isAdmin,
                  auth.user?.token,
                ),
                const SizedBox(height: 20),

                // === KỊCH BẢN NHANH (Bật hết, Tắt hết, Thư giãn) ===
                _buildRoomQuickActions(roomProv),
                const SizedBox(height: 20),

                // === FILTER CHIPS (Tất cả, Đèn, Điều hòa, Quạt, Rèm) ===
                _buildFilterChips(devices.length),
                const SizedBox(height: 16),

                // === DANH SÁCH THIẾT BỊ ===
                if (filteredDevices.isEmpty)
                  _buildEmptyDeviceNotice(isAdmin)
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredDevices.length,
                    itemBuilder: (ctx, index) {
                      final device = filteredDevices[index];
                      return _buildDeviceCard(
                        context,
                        device,
                        roomProv,
                        isAdmin,
                        auth.user?.token,
                      );
                    },
                  ),

                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
      // Floating Action Button cho Admin
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              onPressed: () => _showAddDeviceDialog(context),
              backgroundColor: const Color(0xFF3B82F6),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Thêm thiết bị',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
    );
  }

  // ============================
  // WIDGET CON
  // ============================

  Widget _buildRoomHeader(String roomName, int deviceCount) {
    return Row(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFF1A1F36),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF2A2F46)),
          ),
          child: const Icon(
            Icons.weekend_outlined,
            color: Colors.blueAccent,
            size: 30,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF06B6D4),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    roomName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0E3A4B),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Đang mở',
                      style: TextStyle(
                        color: Color(0xFF06B6D4),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Tầng 1 • $deviceCount Thiết bị kết nối',
                style: const TextStyle(color: Color(0xFF8D8FA1), fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRoomEnvironment(RoomProvider roomProv) {
    final hasTemp = roomProv.hasRealTemperature;
    final hasHum = roomProv.hasRealHumidity;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F36),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF2A2F46)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.sensors, color: Colors.blueAccent, size: 16),
              const SizedBox(width: 6),
              const Text(
                'MÔI TRƯỜNG PHÒNG',
                style: TextStyle(
                  color: Color(0xFF8D8FA1),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A0E21),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.circle,
                      color: (hasTemp || hasHum)
                          ? const Color(0xFF10B981)
                          : const Color(0xFF06B6D4),
                      size: 6,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      (hasTemp || hasHum)
                          ? 'Dữ liệu CSDL thời gian thực'
                          : 'Chuyển động (2p trước)',
                      style: const TextStyle(
                        color: Color(0xFF8D8FA1),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              // Nhiệt độ (GET /api/cam-bien/{id}/hien-tai)
              Expanded(
                child: _buildEnvMiniCard(
                  icon: Icons.thermostat,
                  iconColor: Colors.amber,
                  tag: hasTemp ? 'Đo thật CSDL' : 'Lý tưởng',
                  value: roomProv.currentRoomTemperature,
                  label: 'Nhiệt độ',
                ),
              ),
              const SizedBox(width: 8),
              // Độ ẩm (GET /api/cam-bien/{id}/hien-tai)
              Expanded(
                child: _buildEnvMiniCard(
                  icon: Icons.water_drop,
                  iconColor: Colors.lightBlueAccent,
                  tag: hasHum ? 'Đo thật CSDL' : 'Dễ chịu',
                  value: roomProv.currentRoomHumidity,
                  label: 'Độ ẩm',
                ),
              ),
              const SizedBox(width: 8),
              // kWh điện
              Expanded(
                child: _buildEnvMiniCard(
                  icon: Icons.bolt,
                  iconColor: Colors.greenAccent,
                  tag: 'Hôm nay',
                  value: '3.2',
                  label: 'kWh điện',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEnvMiniCard({
    required IconData icon,
    required Color iconColor,
    required String tag,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0E21),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 14),
              const Spacer(),
              Text(
                tag,
                style: TextStyle(
                  color: iconColor,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: Color(0xFF8D8FA1), fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomSensorsSection(
    BuildContext context,
    RoomProvider roomProv,
    bool isAdmin,
    String? token,
  ) {
    final sensors = roomProv.currentRoomSensors;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F36),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF2A2F46)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.sensors, color: Colors.blueAccent, size: 18),
              const SizedBox(width: 8),
              const Text(
                'CẢM BIẾN TRONG PHÒNG',
                style: TextStyle(
                  color: Color(0xFF8D8FA1),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A0E21),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${sensors.length}',
                  style: const TextStyle(
                    color: Colors.blueAccent,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              if (isAdmin)
                InkWell(
                  onTap: () => _showAddSensorDialog(context),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.add, color: Colors.blueAccent, size: 14),
                        SizedBox(width: 4),
                        Text(
                          'Thêm cảm biến',
                          style: TextStyle(
                            color: Colors.blueAccent,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (sensors.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF0A0E21),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Color(0xFF8D8FA1),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Chưa có cảm biến nào trong phòng này.',
                      style: TextStyle(color: Color(0xFF8D8FA1), fontSize: 12),
                    ),
                  ),
                  if (isAdmin)
                    TextButton(
                      onPressed: () => _showAddSensorDialog(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Thêm ngay',
                        style: TextStyle(
                          color: Colors.blueAccent,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: sensors.map((sensor) {
                  return _buildSensorCard(context, sensor, roomProv, token);
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  void _showSensorDetailDialog(
    BuildContext context,
    SensorItem sensor,
    RoomProvider roomProv,
    String? token,
  ) {
    showDialog(
      context: context,
      builder: (ctx) =>
          _SensorDetailDialog(sensor: sensor, roomProv: roomProv, token: token),
    );
  }

  Widget _buildSensorCard(
    BuildContext context,
    SensorItem sensor,
    RoomProvider roomProv,
    String? token,
  ) {
    IconData icon = Icons.sensors;
    Color color = Colors.blueAccent;

    switch (sensor.loaiCamBien) {
      case 'NhietDo':
        icon = Icons.thermostat;
        color = Colors.amber;
        break;
      case 'DoAm':
        icon = Icons.water_drop;
        color = Colors.lightBlueAccent;
        break;
      case 'ChuyenDong':
        icon = Icons.directions_walk;
        color = Colors.cyanAccent;
        break;
      case 'Cua':
        icon = Icons.door_sliding;
        color = Colors.tealAccent;
        break;
      case 'Khoi':
        icon = Icons.local_fire_department;
        color = Colors.redAccent;
        break;
      case 'RoRiNuoc':
        icon = Icons.water_damage;
        color = Colors.indigoAccent;
        break;
    }

    final reading = roomProv.latestSensorReadings[sensor.maCamBien];
    final hasReading = reading != null;
    final displayValue = hasReading
        ? reading.formatValue(sensor.loaiCamBien)
        : 'Chưa có số liệu';

    return InkWell(
      onTap: () => _showSensorDetailDialog(context, sensor, roomProv, token),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 155,
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF0A0E21),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: hasReading
                ? color.withValues(alpha: 0.4)
                : const Color(0xFF2A2F46),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 16),
                ),
                const Spacer(),
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: hasReading
                        ? Colors.greenAccent
                        : const Color(0xFF8D8FA1),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              sensor.tenLoaiHienThi,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              displayValue,
              style: TextStyle(
                color: hasReading ? color : const Color(0xFF8D8FA1),
                fontSize: hasReading ? 15 : 11,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  '#${sensor.maCamBien}',
                  style: const TextStyle(
                    color: Color(0xFF8D8FA1),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.touch_app_outlined,
                  color: Color(0xFF8D8FA1),
                  size: 13,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomQuickActions(RoomProvider roomProv) {
    return Row(
      children: [
        // Bật hết
        Expanded(
          child: InkWell(
            onTap: () {
              roomProv.setAllDevicesState(true);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã bật toàn bộ thiết bị trong phòng'),
                  duration: Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1F36),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF2A2F46)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bolt, color: Colors.amber, size: 18),
                  SizedBox(width: 6),
                  Text(
                    'Bật hết',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Tắt hết
        Expanded(
          child: InkWell(
            onTap: () {
              roomProv.setAllDevicesState(false);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã tắt toàn bộ thiết bị trong phòng'),
                  duration: Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1F36),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF2A2F46)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.power_settings_new,
                    color: Colors.redAccent,
                    size: 18,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Tắt hết',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Thư giãn
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF3B82F6), Color(0xFF06B6D4)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.auto_awesome, color: Colors.white, size: 18),
                SizedBox(width: 6),
                Text(
                  'Thư giãn',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChips(int totalCount) {
    final chips = ['Tất cả', 'Đèn', 'Điều hòa', 'Quạt', 'Rèm'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: chips.map((cat) {
          final isSelected = _selectedCategory == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(cat == 'Tất cả' ? '$cat $totalCount' : cat),
              selected: isSelected,
              onSelected: (_) {
                setState(() {
                  _selectedCategory = cat;
                });
              },
              selectedColor: const Color(0xFF3B82F6),
              backgroundColor: const Color(0xFF1A1F36),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF8D8FA1),
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              side: const BorderSide(color: Color(0xFF2A2F46)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDeviceCard(
    BuildContext context,
    DeviceItem device,
    RoomProvider roomProv,
    bool isAdmin,
    String? token,
  ) {
    // Icon và màu theo loại
    IconData iconData = Icons.lightbulb_outline;
    Color iconColor = Colors.amber;
    if (device.loaiThietBi.toLowerCase().contains('quat')) {
      iconData = Icons.mode_fan_off_outlined;
      iconColor = Colors.lightBlueAccent;
    } else if (device.loaiThietBi.toLowerCase().contains('dieuhoa')) {
      iconData = Icons.ac_unit_outlined;
      iconColor = Colors.cyanAccent;
    } else if (device.loaiThietBi.toLowerCase().contains('rem')) {
      iconData = Icons.blinds_outlined;
      iconColor = Colors.deepPurpleAccent;
    } else if (device.loaiThietBi.toLowerCase().contains('loa')) {
      iconData = Icons.speaker_outlined;
      iconColor = Colors.pinkAccent;
    } else if (device.loaiThietBi.toLowerCase().contains('cua')) {
      iconData = Icons.door_back_door_outlined;
      iconColor = Colors.tealAccent;
    }

    final isOn = device.isOn;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F36),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isOn
              ? const Color(0xFF3B82F6).withValues(alpha: 0.4)
              : const Color(0xFF2A2F46),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Bấm vào icon hoặc tên để xem chi tiết thiết bị: GET /api/thiet-bi/{maThietBi}
              InkWell(
                onTap: () => _showDeviceDetailDialog(context, device),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isOn
                        ? iconColor.withValues(alpha: 0.2)
                        : const Color(0xFF0A0E21),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    iconData,
                    color: isOn ? iconColor : const Color(0xFF8D8FA1),
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Tên & Thông số (bấm để xem chi tiết)
              Expanded(
                child: InkWell(
                  onTap: () => _showDeviceDetailDialog(context, device),
                  borderRadius: BorderRadius.circular(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        device.tenThietBi,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isOn ? 'Đang hoạt động • BẬT' : 'Đang tắt • Chế độ chờ',
                        style: TextStyle(
                          color: isOn
                              ? Colors.greenAccent
                              : const Color(0xFF8D8FA1),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Nút xem chi tiết thiết bị đơn lẻ: GET /api/thiet-bi/{id}
              IconButton(
                icon: const Icon(
                  Icons.info_outline,
                  color: Color(0xFF8D8FA1),
                  size: 18,
                ),
                tooltip: 'Xem chi tiết thiết bị',
                onPressed: () => _showDeviceDetailDialog(context, device),
              ),

              // Nút Switch BẬT / TẮT
              Transform.scale(
                scale: 0.9,
                child: Switch(
                  value: isOn,
                  activeThumbColor: Colors.white,
                  activeTrackColor: const Color(0xFF3B82F6),
                  inactiveThumbColor: const Color(0xFF8D8FA1),
                  inactiveTrackColor: const Color(0xFF0A0E21),
                  onChanged: (_) async {
                    final ok = await roomProv.toggleDevice(device, token);
                    if (!ok && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            roomProv.errorMessage ??
                                'Điều khiển thiết bị thất bại',
                          ),
                          backgroundColor: Colors.red.shade700,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                ),
              ),

              // Nút sửa và xóa thiết bị dành cho Admin
              if (isAdmin) ...[
                IconButton(
                  icon: const Icon(
                    Icons.edit_outlined,
                    color: Colors.blueAccent,
                    size: 18,
                  ),
                  tooltip: 'Sửa thiết bị',
                  onPressed: () => _showEditDeviceDialog(context, device),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                    size: 18,
                  ),
                  tooltip: 'Xóa thiết bị',
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: const Color(0xFF1A1F36),
                        title: const Text(
                          'Xóa thiết bị',
                          style: TextStyle(color: Colors.white),
                        ),
                        content: Text(
                          'Xóa "${device.tenThietBi}" khỏi phòng?',
                          style: const TextStyle(color: Color(0xFF8D8FA1)),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text(
                              'Hủy',
                              style: TextStyle(color: Color(0xFF8D8FA1)),
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text(
                              'Xóa',
                              style: TextStyle(color: Colors.redAccent),
                            ),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      await roomProv.deleteDevice(device.maThietBi, token);
                    }
                  },
                ),
              ],
            ],
          ),

          // Thanh slider độ sáng trang trí cho đèn khi bật
          if (isOn && device.loaiThietBi.toLowerCase().contains('den')) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.wb_sunny_outlined,
                  color: Colors.amber,
                  size: 14,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Độ sáng: 80%',
                  style: TextStyle(color: Color(0xFF8D8FA1), fontSize: 11),
                ),
                const Spacer(),
                const Text(
                  'Màu: Vàng ấm (2700K)',
                  style: TextStyle(color: Color(0xFF8D8FA1), fontSize: 11),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: const LinearProgressIndicator(
                value: 0.8,
                backgroundColor: Color(0xFF0A0E21),
                valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                minHeight: 6,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyDeviceNotice(bool isAdmin) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F36),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2F46)),
      ),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.devices_other, color: Color(0xFF8D8FA1), size: 40),
            const SizedBox(height: 12),
            const Text(
              'Chưa có thiết bị nào trong phòng này',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            if (isAdmin) ...[
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () => _showAddDeviceDialog(context),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Thêm thiết bị đầu tiên'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Hộp thoại chuyên dụng hiển thị chi tiết 1 thiết bị đơn lẻ từ GET /api/thiet-bi/{maThietBi}
class _DeviceDetailDialog extends StatefulWidget {
  final DeviceItem device;
  final String? token;
  final RoomProvider roomProv;

  const _DeviceDetailDialog({
    required this.device,
    required this.token,
    required this.roomProv,
  });

  @override
  State<_DeviceDetailDialog> createState() => _DeviceDetailDialogState();
}

class _DeviceDetailDialogState extends State<_DeviceDetailDialog> {
  late Future<DeviceItem?> _deviceFuture;

  @override
  void initState() {
    super.initState();
    _deviceFuture = widget.roomProv.fetchDeviceDetail(
      widget.device.maThietBi,
      widget.token,
    );
  }

  Widget _buildRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Color(0xFF8D8FA1), fontSize: 13),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                color: valueColor ?? Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1A1F36),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.blueAccent),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Chi tiết: ${widget.device.tenThietBi}',
              style: const TextStyle(color: Colors.white, fontSize: 17),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      content: FutureBuilder<DeviceItem?>(
        future: _deviceFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(
              height: 120,
              child: Center(
                child: CircularProgressIndicator(color: Colors.blueAccent),
              ),
            );
          }

          final item = snapshot.data ?? widget.device;

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Dữ liệu từ GET /api/thiet-bi/{id}:',
                style: TextStyle(color: Color(0xFF8D8FA1), fontSize: 12),
              ),
              const SizedBox(height: 12),
              _buildRow('Mã thiết bị (ID)', '${item.maThietBi}'),
              _buildRow('Tên thiết bị', item.tenThietBi),
              _buildRow('Loại thiết bị', item.loaiThietBi),
              _buildRow(
                'Trạng thái',
                item.isOn ? 'BẬT' : 'TẮT',
                valueColor: item.isOn ? Colors.greenAccent : Colors.redAccent,
              ),
              if (item.maPhong != null)
                _buildRow('Mã phòng (maPhong)', '${item.maPhong}'),
              if (item.ngayTao != null && item.ngayTao!.isNotEmpty)
                _buildRow('Ngày tạo', item.ngayTao!),
            ],
          );
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Đóng', style: TextStyle(color: Color(0xFF8D8FA1))),
        ),
      ],
    );
  }
}

/// Hộp thoại hiển thị chi tiết cảm biến và mô phỏng gửi dữ liệu đo thời gian thực
class _SensorDetailDialog extends StatefulWidget {
  final SensorItem sensor;
  final RoomProvider roomProv;
  final String? token;

  const _SensorDetailDialog({
    required this.sensor,
    required this.roomProv,
    required this.token,
  });

  @override
  State<_SensorDetailDialog> createState() => _SensorDetailDialogState();
}

class _SensorDetailDialogState extends State<_SensorDetailDialog> {
  late TextEditingController _simController;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    final reading =
        widget.roomProv.latestSensorReadings[widget.sensor.maCamBien];
    final defaultVal = reading != null
        ? reading.giaTri.toString()
        : (widget.sensor.loaiCamBien == 'NhietDo'
              ? '28.5'
              : widget.sensor.loaiCamBien == 'DoAm'
              ? '65'
              : '1');
    _simController = TextEditingController(text: defaultVal);
  }

  @override
  void dispose() {
    _simController.dispose();
    super.dispose();
  }

  Widget _buildRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Color(0xFF8D8FA1), fontSize: 13),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                color: valueColor ?? Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendSimulatedValue(double val) async {
    setState(() => _isSending = true);
    final ok = await widget.roomProv.simulateSensorData(
      maCamBien: widget.sensor.maCamBien,
      giaTri: val,
      token: widget.token,
    );
    if (!mounted) return;
    setState(() {
      _isSending = false;
      _simController.text = val.toString();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'Đã ghi nhận giá trị mới ($val) vào CSDL thành công!'
              : 'Ghi nhận thất bại',
        ),
        backgroundColor: ok ? Colors.green.shade700 : Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reading =
        widget.roomProv.latestSensorReadings[widget.sensor.maCamBien];
    final hasReading = reading != null;

    return AlertDialog(
      backgroundColor: const Color(0xFF1A1F36),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          const Icon(Icons.sensors, color: Colors.blueAccent),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${widget.sensor.tenLoaiHienThi} (#${widget.sensor.maCamBien})',
              style: const TextStyle(color: Colors.white, fontSize: 17),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thông tin chi tiết từ GET /api/cam-bien:',
              style: TextStyle(color: Color(0xFF8D8FA1), fontSize: 12),
            ),
            const SizedBox(height: 10),
            _buildRow('Mã cảm biến (ID)', '#${widget.sensor.maCamBien}'),
            _buildRow('Loại cảm biến', widget.sensor.tenLoaiHienThi),
            _buildRow('Mã hệ thống', widget.sensor.loaiCamBien),
            _buildRow(
              'Thiết bị liên kết',
              widget.sensor.maThietBi != null
                  ? '#${widget.sensor.maThietBi}'
                  : 'Không có',
            ),
            const Divider(color: Color(0xFF2A2F46), height: 20),
            const Text(
              'Dữ liệu hiện tại (GET /api/cam-bien/{id}/hien-tai):',
              style: TextStyle(color: Color(0xFF8D8FA1), fontSize: 12),
            ),
            const SizedBox(height: 8),
            _buildRow(
              'Giá trị đo',
              hasReading
                  ? reading.formatValue(widget.sensor.loaiCamBien)
                  : 'Chưa có số liệu',
              valueColor: hasReading ? Colors.greenAccent : Colors.amber,
            ),
            if (hasReading && reading.thoiGianGhiNhan != null)
              _buildRow(
                'Thời gian ghi nhận',
                reading.thoiGianGhiNhan.toString().split('.').first,
              ),
            const Divider(color: Color(0xFF2A2F46), height: 24),

            // Khu vực mô phỏng gửi dữ liệu IoT
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0A0E21),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.blueAccent.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.bolt, color: Colors.amber, size: 16),
                      SizedBox(width: 6),
                      Text(
                        'MÔ PHỎNG THIẾT BỊ GỬI SỐ LIỆU',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Gọi POST /api/cam-bien/ingest để ghi dữ liệu mới vào CSDL:',
                    style: TextStyle(color: Color(0xFF8D8FA1), fontSize: 11),
                  ),
                  const SizedBox(height: 10),

                  // Nút gợi ý nhanh
                  if (widget.sensor.loaiCamBien == 'NhietDo')
                    Wrap(
                      spacing: 6,
                      children: [24.0, 27.5, 30.0, 33.5].map((val) {
                        return ActionChip(
                          label: Text('$val°C'),
                          onPressed: _isSending
                              ? null
                              : () => _sendSimulatedValue(val),
                          backgroundColor: const Color(0xFF1A1F36),
                          labelStyle: const TextStyle(
                            color: Colors.amber,
                            fontSize: 11,
                          ),
                          side: const BorderSide(color: Color(0xFF2A2F46)),
                        );
                      }).toList(),
                    )
                  else if (widget.sensor.loaiCamBien == 'DoAm')
                    Wrap(
                      spacing: 6,
                      children: [45.0, 60.0, 75.0, 85.0].map((val) {
                        return ActionChip(
                          label: Text('${val.toInt()}%'),
                          onPressed: _isSending
                              ? null
                              : () => _sendSimulatedValue(val),
                          backgroundColor: const Color(0xFF1A1F36),
                          labelStyle: const TextStyle(
                            color: Colors.lightBlueAccent,
                            fontSize: 11,
                          ),
                          side: const BorderSide(color: Color(0xFF2A2F46)),
                        );
                      }).toList(),
                    )
                  else
                    Wrap(
                      spacing: 6,
                      children: [1.0, 0.0].map((val) {
                        return ActionChip(
                          label: Text(
                            val > 0 ? 'Kích hoạt (1.0)' : 'Tắt (0.0)',
                          ),
                          onPressed: _isSending
                              ? null
                              : () => _sendSimulatedValue(val),
                          backgroundColor: const Color(0xFF1A1F36),
                          labelStyle: TextStyle(
                            color: val > 0
                                ? Colors.greenAccent
                                : Colors.redAccent,
                            fontSize: 11,
                          ),
                          side: const BorderSide(color: Color(0xFF2A2F46)),
                        );
                      }).toList(),
                    ),

                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _simController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Nhập số đo...',
                            hintStyle: const TextStyle(
                              color: Color(0xFF8D8FA1),
                            ),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 10,
                            ),
                            filled: true,
                            fillColor: const Color(0xFF1A1F36),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFF2A2F46),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: _isSending
                            ? null
                            : () {
                                final val = double.tryParse(
                                  _simController.text.trim(),
                                );
                                if (val != null) {
                                  _sendSimulatedValue(val);
                                }
                              },
                        child: _isSending
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Gửi đo',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Đóng', style: TextStyle(color: Color(0xFF8D8FA1))),
        ),
      ],
    );
  }
}
