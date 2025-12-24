import 'package:flutter/material.dart';
import '../vaitro/danh_sach_vai_tro_screen.dart';
import '../nhan_vien/danh_sach_nhan_vien_screen.dart';
import '../profile/profile_screen.dart';
import '../cham_cong/danh_sach_cham_cong_screen.dart';
import '../cham_cong/ghi_nfc_screen.dart';
import '../cham_cong/doc_nfc_cham_cong_screen.dart';
import '../cau_hinh_luong/danh_sach_cau_hinh_luong_screen.dart';
import '../baocao/danh_sach_bao_cao_screen.dart';
import '../../model/nhanvien/nhan_vien.dart';
import '../../services/auth/auth_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    // Xóa dữ liệu đăng nhập
    final authService = AuthService();
    await authService.logout();
    
    // Chuyển về màn hình login
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments;
    final nhanVien = arguments is NhanVien ? arguments : null;
    final isAdmin = nhanVien?.isAdmin ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('WorkTrack - Trang Chủ'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          if (nhanVien != null)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Center(
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfileScreen(nhanVien: nhanVien),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blue,
                        child: Text(
                          nhanVien.hoTen.substring(0, 1).toUpperCase(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nhanVien.hoTen,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            nhanVien.vaiTro?['tenVaiTro'] ?? 'Nhân viên',
                            style: const TextStyle(
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Đăng xuất',
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: nhanVien == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.lock_outline,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Vui lòng đăng nhập',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    icon: const Icon(Icons.login),
                    label: const Text('Đăng nhập'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : isAdmin
              ? _buildAdminView(context, nhanVien)
              : _buildEmployeeView(context),
    );
  }

  // Giao diện cho Admin
  Widget _buildAdminView(BuildContext context, NhanVien? currentUser) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.1,
        children: [
          _buildMenuCard(
            context,
            icon: Icons.people,
            title: 'Quản lý Nhân Viên',
            color: Colors.blue,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DanhSachNhanVienScreen(currentUser: currentUser),
                ),
              );
            },
          ),
          _buildMenuCard(
            context,
            icon: Icons.badge,
            title: 'Quản lý Vai Trò',
            color: Colors.orange,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DanhSachVaiTroScreen(),
                ),
              );
            },
          ),
          _buildMenuCard(
            context,
            icon: Icons.access_time,
            title: 'Quản lý Chấm Công',
            color: Colors.green,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DanhSachChamCongScreen(),
                ),
              );
            },
          ),
          _buildMenuCard(
            context,
            icon: Icons.settings,
            title: 'Cấu Hình Lương',
            color: Colors.indigo,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DanhSachCauHinhLuongScreen(),
                ),
              );
            },
          ),
          _buildMenuCard(
            context,
            icon: Icons.monetization_on,
            title: 'Báo Cáo Lương',
            color: Colors.purple,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DanhSachBaoCaoScreen(),
                ),
              );
            },
          ),
          _buildMenuCard(
            context,
            icon: Icons.bar_chart,
            title: 'Thống Kê',
            color: Colors.deepPurple,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tính năng đang phát triển'),
                ),
              );
            },
          ),
          _buildMenuCard(
            context,
            icon: Icons.nfc,
            title: 'Ghi Thẻ NFC',
            color: Colors.teal,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const GhiNFCScreen(),
                ),
              );
            },
          ),
          _buildMenuCard(
            context,
            icon: Icons.touch_app,
            title: 'Chấm Công NFC',
            color: Colors.cyan,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DocNFCChamCongScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Giao diện cho Nhân viên thường
  Widget _buildEmployeeView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction,
              size: 100,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              'Tính năng đang phát triển',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Các tính năng dành cho nhân viên sẽ sớm được cập nhật',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.touch_app, color: Colors.cyan),
                      title: const Text('Chấm công NFC'),
                      subtitle: const Text('Quét thẻ để chấm công'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DocNFCChamCongScreen(),
                          ),
                        );
                      },
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.calendar_today, color: Colors.orange),
                      title: const Text('Lịch làm việc'),
                      subtitle: const Text('Đang phát triển'),
                      trailing: const Icon(Icons.lock_outline),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.receipt, color: Colors.green),
                      title: const Text('Xem lương'),
                      subtitle: const Text('Đang phát triển'),
                      trailing: const Icon(Icons.lock_outline),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 40,
                color: color,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}