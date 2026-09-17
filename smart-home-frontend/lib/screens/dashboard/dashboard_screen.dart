import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/room_provider.dart';
import '../../models/room_model.dart';
import '../room/room_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _bottomNavIndex = 0;
  bool _isAtHome = true; // Trạng thái Ở nhà / Vắng

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = context.read<AuthProvider>().user?.token;
      context.read<RoomProvider>().fetchRooms(token);
    });
  }

  void _showAddRoomDialog(BuildContext context) {
    final nameController = TextEditingController();
    final authProvider = context.read<AuthProvider>();
    final roomProvider = context.read<RoomProvider>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F36),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.add_home_outlined, color: Colors.blueAccent),
            SizedBox(width: 8),
            Text(
              'Thêm phòng mới',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'VD: Phòng Làm Việc, Ban Công...',
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
                final ok = await roomProvider.createRoom(
                  name,
                  authProvider.user?.token,
                );
                if (!mounted) return;
                if (ok) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('Đã thêm phòng "$name" thành công!'),
                      backgroundColor: Colors.green.shade700,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } else {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        roomProvider.errorMessage ?? 'Thêm phòng thất bại',
                      ),
                      backgroundColor: Colors.red.shade700,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            child: const Text('Thêm', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteRoom(
    Room room,
    RoomProvider roomProv,
    String? token,
  ) async {
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
          'Bạn có chắc chắn muốn xóa phòng "${room.tenPhong}" và toàn bộ thiết bị trong phòng không?',
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
      final success = await roomProv.deleteRoom(room.maPhong, token);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Đã xóa phòng "${room.tenPhong}" thành công!'
                : (roomProv.errorMessage ?? 'Xóa phòng thất bại'),
          ),
          backgroundColor: success
              ? Colors.green.shade700
              : Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // Hộp thoại chỉnh sửa tên phòng (Admin): PUT /api/phong/{maPhong}
  void _showEditRoomDialog(
    BuildContext context,
    Room room,
    RoomProvider roomProv,
    String? token,
  ) {
    final controller = TextEditingController(text: room.tenPhong);
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
                  room.maPhong,
                  newName,
                  token,
                  maNha: room.maNha ?? 1,
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

  // Hộp thoại kiểm tra GET /api/user/me và GET /api/admin/ping
  void _showUserSessionDialog(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (ctx) => _UserSessionDialog(auth: auth),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final roomProv = context.watch<RoomProvider>();
    final user = auth.user;
    final isAdmin = user?.vaiTro == 'Admin';

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => roomProv.fetchRooms(user?.token),
          color: Colors.blueAccent,
          backgroundColor: const Color(0xFF1A1F36),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                // === TOP BAR: Title & Actions ===
                _buildTopBar(context, auth),
                const SizedBox(height: 20),

                // === USER INFO & HOUSE CARD ===
                _buildUserCard(context, auth, user, isAdmin),
                const SizedBox(height: 20),

                // === 3 THẺ MÔI TRƯỜNG TỔNG QUAN ===
                _buildEnvironmentCards(roomProv),
                const SizedBox(height: 24),

                // === KỊCH BẢN NHANH ===
                _buildQuickScenes(),
                const SizedBox(height: 24),

                // === TIÊU ĐỀ DANH SÁCH PHÒNG & NÚT THÊM PHÒNG (ADMIN) ===
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 18,
                          decoration: BoxDecoration(
                            color: Colors.blueAccent,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Danh sách phòng',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1F36),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${roomProv.rooms.length}',
                            style: const TextStyle(
                              color: Colors.blueAccent,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Nút thêm phòng dành riêng cho Admin
                    if (isAdmin)
                      InkWell(
                        onTap: () => _showAddRoomDialog(context),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF3B82F6), Color(0xFF06B6D4)],
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add, color: Colors.white, size: 16),
                              SizedBox(width: 4),
                              Text(
                                'Thêm phòng',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 14),

                // === DANH SÁCH CÁC PHÒNG (GRID VIEW) ===
                if (roomProv.isLoading && roomProv.rooms.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(
                        color: Colors.blueAccent,
                      ),
                    ),
                  )
                else
                  _buildRoomGrid(context, roomProv, user?.token, isAdmin),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // ============================
  // WIDGETS CON
  // ============================

  Widget _buildTopBar(BuildContext context, AuthProvider auth) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFF1A1F36),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.home_work_outlined,
            color: Colors.blueAccent,
            size: 20,
          ),
        ),
        const SizedBox(width: 10),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SMART HOME',
              style: TextStyle(
                color: Color(0xFF8D8FA1),
                fontSize: 10,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Trang Chủ',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const Spacer(),
        // Chuông thông báo
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFF1A1F36),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.notifications_none,
            color: Colors.white70,
            size: 20,
          ),
        ),
        const SizedBox(width: 8),
        // Nút Đăng xuất
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.redAccent, size: 20),
          tooltip: 'Đăng xuất',
          onPressed: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                backgroundColor: const Color(0xFF1A1F36),
                title: const Text(
                  'Đăng xuất',
                  style: TextStyle(color: Colors.white),
                ),
                content: const Text(
                  'Bạn có chắc muốn đăng xuất khỏi hệ thống?',
                  style: TextStyle(color: Color(0xFF8D8FA1)),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text(
                      'Không',
                      style: TextStyle(color: Color(0xFF8D8FA1)),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text(
                      'Đăng xuất',
                      style: TextStyle(color: Colors.redAccent),
                    ),
                  ),
                ],
              ),
            );

            if (confirm == true && context.mounted) {
              await auth.logout();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            }
          },
        ),
      ],
    );
  }

  Widget _buildUserCard(
    BuildContext context,
    AuthProvider auth,
    dynamic user,
    bool isAdmin,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F36),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF2A2F46)),
      ),
      child: Row(
        children: [
          // Avatar có thể bấm để mở chi tiết phiên đăng nhập
          InkWell(
            onTap: () => _showUserSessionDialog(context, auth),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF3B82F6), Color(0xFF06B6D4)],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 28),
            ),
          ),
          const SizedBox(width: 14),

          // Lời chào & Tên & Vai trò (Bấm để xem GET /api/user/me)
          Expanded(
            child: InkWell(
              onTap: () => _showUserSessionDialog(context, auth),
              borderRadius: BorderRadius.circular(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Xin chào, ${user?.hoTen ?? 'Người dùng'} ✨',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isAdmin
                              ? Colors.amber.withValues(alpha: 0.2)
                              : Colors.blueAccent.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isAdmin ? '👑 Admin (Chủ nhà)' : '👤 Thành viên',
                          style: TextStyle(
                            color: isAdmin
                                ? Colors.amberAccent
                                : Colors.lightBlueAccent,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        '• Nhà của tôi',
                        style: TextStyle(
                          color: Color(0xFF8D8FA1),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Nút toggle trạng thái Ở nhà / Vắng
          InkWell(
            onTap: () {
              setState(() {
                _isAtHome = !_isAtHome;
              });
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _isAtHome
                    ? const Color(0xFF3B82F6)
                    : const Color(0xFF2A2F46),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isAtHome ? Icons.home : Icons.directions_walk,
                    color: Colors.white,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _isAtHome ? 'Ở nhà' : 'Vắng',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 4),

          // Nút kiểm tra quyền Admin & User session: GET /api/user/me & GET /api/admin/ping
          IconButton(
            icon: const Icon(
              Icons.shield_outlined,
              color: Colors.blueAccent,
              size: 20,
            ),
            tooltip: 'Kiểm tra quyền Admin (GET /api/user/me & ping)',
            onPressed: () => _showUserSessionDialog(context, auth),
          ),
        ],
      ),
    );
  }

  Widget _buildEnvironmentCards(RoomProvider roomProv) {
    return Row(
      children: [
        // Nhiệt độ TB
        Expanded(
          child: _buildEnvItem(
            icon: Icons.thermostat_outlined,
            iconColor: Colors.amber,
            tag: 'Ổn định',
            value: '28.5°C',
            label: 'Nhiệt độ TB',
          ),
        ),
        const SizedBox(width: 10),
        // Độ ẩm phòng
        Expanded(
          child: _buildEnvItem(
            icon: Icons.water_drop_outlined,
            iconColor: Colors.lightBlueAccent,
            tag: 'Lý tưởng',
            value: '65%',
            label: 'Độ ẩm phòng',
          ),
        ),
        const SizedBox(width: 10),
        // Thiết bị đang bật
        Expanded(
          child: _buildEnvItem(
            icon: Icons.bolt,
            iconColor: Colors.greenAccent,
            tag: 'Đang chạy',
            value: '${roomProv.activeDeviceCount}/${roomProv.totalDeviceCount}',
            label: 'Thiết bị bật',
          ),
        ),
      ],
    );
  }

  Widget _buildEnvItem({
    required IconData icon,
    required Color iconColor,
    required String tag,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F36),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2F46)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 16),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    color: iconColor,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(color: Color(0xFF8D8FA1), fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickScenes() {
    final scenes = [
      {'title': 'Đi ngủ', 'icon': Icons.nightlight_round},
      {'title': 'Rời nhà', 'icon': Icons.door_front_door_outlined},
      {'title': 'Về nhà', 'icon': Icons.cottage_outlined},
      {'title': 'Xem phim', 'icon': Icons.movie_creation_outlined},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Kịch bản nhanh',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Xem tất cả ›',
              style: TextStyle(color: Color(0xFF8D8FA1), fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: scenes.map((s) {
            return Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1F36),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF2A2F46)),
                ),
                child: Column(
                  children: [
                    Icon(
                      s['icon'] as IconData,
                      color: Colors.white70,
                      size: 22,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      s['title'] as String,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRoomGrid(
    BuildContext context,
    RoomProvider roomProv,
    String? token,
    bool isAdmin,
  ) {
    if (roomProv.rooms.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1F36),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF2A2F46)),
        ),
        child: const Center(
          child: Column(
            children: [
              Icon(
                Icons.meeting_room_outlined,
                color: Color(0xFF8D8FA1),
                size: 40,
              ),
              SizedBox(height: 12),
              Text(
                'Chưa có phòng nào trong hệ thống',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;
    final isTablet = screenWidth > 600 && screenWidth <= 900;
    final crossAxisCount = isDesktop ? 4 : (isTablet ? 3 : 2);
    final childAspectRatio = isDesktop ? 1.6 : (isTablet ? 1.4 : 1.3);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: roomProv.rooms.length,
      itemBuilder: (ctx, index) {
        final room = roomProv.rooms[index];
        return _buildRoomCard(context, room, roomProv, token, isAdmin);
      },
    );
  }

  Widget _buildRoomCard(
    BuildContext context,
    Room room,
    RoomProvider roomProv,
    String? token,
    bool isAdmin,
  ) {
    // Chọn icon tương ứng tên phòng
    IconData roomIcon = Icons.weekend_outlined;
    if (room.tenPhong.toLowerCase().contains('ngủ')) {
      roomIcon = Icons.bed_outlined;
    } else if (room.tenPhong.toLowerCase().contains('bếp')) {
      roomIcon = Icons.kitchen_outlined;
    } else if (room.tenPhong.toLowerCase().contains('việc')) {
      roomIcon = Icons.desk_outlined;
    } else if (room.tenPhong.toLowerCase().contains('tắm')) {
      roomIcon = Icons.bathtub_outlined;
    }

    return InkWell(
      onTap: () {
        roomProv.selectRoom(room, token);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => RoomDetailScreen(room: room)),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1F36),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF2A2F46)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    roomIcon,
                    color: const Color(0xFF3B82F6),
                    size: 20,
                  ),
                ),
                if (isAdmin)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.edit_outlined,
                          color: Colors.blueAccent,
                          size: 18,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        tooltip: 'Đổi tên phòng',
                        onPressed: () =>
                            _showEditRoomDialog(context, room, roomProv, token),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.redAccent,
                          size: 18,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        tooltip: 'Xóa phòng',
                        onPressed: () =>
                            _confirmDeleteRoom(room, roomProv, token),
                      ),
                    ],
                  )
                else
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Color(0xFF8D8FA1),
                    size: 12,
                  ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  room.tenPhong,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${room.soLuongThietBi} thiết bị',
                  style: const TextStyle(
                    color: Color(0xFF8D8FA1),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF12162A),
        border: Border(top: BorderSide(color: Color(0xFF2A2F46))),
      ),
      child: BottomNavigationBar(
        currentIndex: _bottomNavIndex,
        onTap: (index) {
          setState(() {
            _bottomNavIndex = index;
          });
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF3B82F6),
        unselectedItemColor: const Color(0xFF8D8FA1),
        selectedFontSize: 11,
        unselectedFontSize: 11,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.door_sliding_outlined),
            label: 'Phòng ốc',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bolt_outlined),
            label: 'Tự động hóa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shield_outlined),
            label: 'An ninh',
          ),
        ],
      ),
    );
  }
}

/// Hộp thoại chuyên dụng hiển thị GET /api/user/me và thực hiện GET /api/admin/ping
class _UserSessionDialog extends StatefulWidget {
  final AuthProvider auth;

  const _UserSessionDialog({required this.auth});

  @override
  State<_UserSessionDialog> createState() => _UserSessionDialogState();
}

class _UserSessionDialogState extends State<_UserSessionDialog> {
  late Future<Map<String, dynamic>?> _userFuture;
  bool _isPinging = false;
  String? _pingMessage;
  bool _pingSuccess = false;

  @override
  void initState() {
    super.initState();
    _userFuture = widget.auth.fetchCurrentUser();
  }

  void _handleRefresh() {
    setState(() {
      _userFuture = widget.auth.fetchCurrentUser();
    });
  }

  void _handlePing() async {
    setState(() {
      _isPinging = true;
      _pingMessage = null;
    });

    try {
      final msg = await widget.auth.pingAdmin();
      if (mounted) {
        setState(() {
          _isPinging = false;
          _pingSuccess = true;
          _pingMessage = msg;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isPinging = false;
          _pingSuccess = false;
          _pingMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1A1F36),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(
        children: [
          Icon(Icons.verified_user_outlined, color: Colors.blueAccent),
          SizedBox(width: 8),
          Text(
            'Tài khoản & Quyền hạn',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Dữ liệu từ GET /api/user/me:',
                  style: TextStyle(color: Color(0xFF8D8FA1), fontSize: 12),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.refresh,
                    color: Colors.blueAccent,
                    size: 16,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'Tải lại',
                  onPressed: _handleRefresh,
                ),
              ],
            ),
            const SizedBox(height: 10),
            FutureBuilder<Map<String, dynamic>?>(
              future: _userFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(
                        color: Colors.blueAccent,
                      ),
                    ),
                  );
                }

                if (snapshot.hasError || snapshot.data == null) {
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.redAccent.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.redAccent,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.auth.errorMessage ??
                                'Không thể tải thông tin từ GET /api/user/me',
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final data = snapshot.data!;
                final username = data['tenDangNhap'] ?? 'N/A';

                // Parse danh sách quyền: [{"authority": "ROLE_ADMIN"}]
                String rolesText = '';
                final rawQuyen = data['quyen'];
                if (rawQuyen is List) {
                  rolesText = rawQuyen
                      .map((q) {
                        if (q is Map) return q['authority'] ?? '';
                        return q.toString();
                      })
                      .where((s) => s.isNotEmpty)
                      .join(', ');
                } else {
                  rolesText = rawQuyen?.toString() ?? 'N/A';
                }

                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A0E21),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF2A2F46)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.account_circle,
                            color: Colors.blueAccent,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Username: ',
                            style: TextStyle(
                              color: Color(0xFF8D8FA1),
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            '$username',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.security,
                            color: Colors.greenAccent,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Quyền hạn: ',
                            style: TextStyle(
                              color: Color(0xFF8D8FA1),
                              fontSize: 13,
                            ),
                          ),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.greenAccent.withValues(
                                  alpha: 0.15,
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                rolesText.isEmpty ? 'ROLE_USER' : rolesText,
                                style: const TextStyle(
                                  color: Colors.greenAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 18),
            const Divider(color: Color(0xFF2A2F46)),
            const SizedBox(height: 10),
            const Text(
              'Kiểm tra quyền Admin: GET /api/admin/ping',
              style: TextStyle(color: Color(0xFF8D8FA1), fontSize: 12),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: _isPinging
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(
                          Icons.network_ping,
                          color: Colors.white,
                          size: 16,
                        ),
                  label: const Text(
                    'Gửi Ping Admin',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: _isPinging ? null : _handlePing,
                ),
              ],
            ),
            if (_pingMessage != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _pingSuccess
                      ? Colors.green.withValues(alpha: 0.15)
                      : Colors.red.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _pingSuccess ? Colors.greenAccent : Colors.redAccent,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _pingSuccess
                          ? Icons.check_circle_outline
                          : Icons.error_outline,
                      color: _pingSuccess
                          ? Colors.greenAccent
                          : Colors.redAccent,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _pingSuccess
                            ? 'Xác thực thành công (200 OK):\n"$_pingMessage"'
                            : 'Thất bại: $_pingMessage',
                        style: TextStyle(
                          color: _pingSuccess
                              ? Colors.greenAccent
                              : Colors.redAccent,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
