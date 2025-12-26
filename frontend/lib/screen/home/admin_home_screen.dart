import 'package:flutter/material.dart';
import '../../model/nhanvien/nhan_vien.dart';
import '../../services/auth/auth_service.dart';
import '../profile/profile_screen.dart';
import '../vaitro/danh_sach_vai_tro_screen.dart';
import '../nhan_vien/danh_sach_nhan_vien_screen.dart';
import '../cham_cong/danh_sach_cham_cong_screen.dart';
import '../cham_cong/ghi_nfc_screen.dart';
import '../cham_cong/doc_nfc_cham_cong_screen.dart';
import '../cau_hinh_luong/danh_sach_cau_hinh_luong_screen.dart';
import '../baocao/danh_sach_bao_cao_screen.dart';

class AdminHomeScreen extends StatelessWidget {
  final NhanVien admin;

  const AdminHomeScreen({super.key, required this.admin});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    // Hàm xử lý đăng xuất
    Future<void> _logout() async {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Xác nhận đăng xuất'),
            content: const Text('Bạn có chắc chắn muốn đăng xuất không?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Hủy'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Đăng xuất'),
              ),
            ],
          );
        },
      );

      if (confirmed == true) {
        await authService.logout();
        if (context.mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard - ${admin.hoTen}'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        actions: [
          // Profile button
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileScreen(nhanVien: admin),
                  ),
                );
              },
              child: CircleAvatar(
                backgroundColor: Colors.white,
                foregroundColor: Colors.red,
                child: Text(
                  admin.hoTen.isNotEmpty ? admin.hoTen.substring(0, 1).toUpperCase() : 'A',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Đăng xuất',
            onPressed: _logout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeCard(context),
            const SizedBox(height: 24),
            const Text(
              'Quản trị hệ thống',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildSystemManagementGrid(context),
            const SizedBox(height: 24),
            const Text(
              'Báo cáo & Thống kê',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildReportsGrid(context),
            const SizedBox(height: 24),
            const Text(
              'Công cụ hệ thống',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildToolsGrid(context),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [Colors.red.shade700, Colors.red.shade500],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.admin_panel_settings,
                  color: Colors.white,
                  size: 40,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Chào mừng, ${admin.hoTen}!',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Quản trị viên hệ thống',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemManagementGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildFeatureCard(
          context,
          icon: Icons.people,
          title: 'Quản lý Nhân viên',
          color: Colors.blue,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DanhSachNhanVienScreen(currentUser: admin),
              ),
            );
          },
        ),
        _buildFeatureCard(
          context,
          icon: Icons.badge,
          title: 'Quản lý Vai trò',
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
        _buildFeatureCard(
          context,
          icon: Icons.access_time,
          title: 'Quản lý Chấm công',
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
        _buildFeatureCard(
          context,
          icon: Icons.settings,
          title: 'Cấu hình Lương',
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
      ],
    );
  }

  Widget _buildReportsGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildFeatureCard(
          context,
          icon: Icons.monetization_on,
          title: 'Báo cáo Lương',
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
        _buildFeatureCard(
          context,
          icon: Icons.bar_chart,
          title: 'Thống kê Hệ thống',
          color: Colors.deepPurple,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Chức năng Thống kê đang phát triển')),
            );
          },
        ),
        _buildFeatureCard(
          context,
          icon: Icons.analytics,
          title: 'Phân tích Dữ liệu',
          color: Colors.teal,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Chức năng Phân tích đang phát triển')),
            );
          },
        ),
        _buildFeatureCard(
          context,
          icon: Icons.assessment,
          title: 'Đánh giá Hiệu suất',
          color: Colors.cyan,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Chức năng Đánh giá đang phát triển')),
            );
          },
        ),
      ],
    );
  }

  Widget _buildToolsGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildFeatureCard(
          context,
          icon: Icons.nfc,
          title: 'Ghi thẻ NFC',
          color: Colors.brown,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const GhiNFCScreen(),
              ),
            );
          },
        ),
        _buildFeatureCard(
          context,
          icon: Icons.touch_app,
          title: 'Test Chấm công',
          color: Colors.pink,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const DocNFCChamCongScreen(),
              ),
            );
          },
        ),
        _buildFeatureCard(
          context,
          icon: Icons.backup,
          title: 'Sao lưu Dữ liệu',
          color: Colors.blueGrey,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Chức năng Sao lưu đang phát triển')),
            );
          },
        ),
        _buildFeatureCard(
          context,
          icon: Icons.security,
          title: 'Bảo mật Hệ thống',
          color: Colors.red.shade800,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Chức năng Bảo mật đang phát triển')),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}