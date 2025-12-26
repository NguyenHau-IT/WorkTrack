import 'package:flutter/material.dart';
import '../../model/nhanvien/nhan_vien.dart';
import '../../services/auth/auth_service.dart';
import '../profile/profile_screen.dart';
import '../cham_cong/doc_nfc_cham_cong_screen.dart';

class EmployeeHomeScreen extends StatelessWidget {
  final NhanVien employee;

  const EmployeeHomeScreen({super.key, required this.employee});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    // Hàm xử lý đăng xuất
    Future<void> _logout() async {
      // Hiển thị dialog xác nhận
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

      // Nếu người dùng xác nhận, tiến hành đăng xuất
      if (confirmed == true) {
        await authService.logout();
        if (context.mounted) {
          // Quay về màn hình đăng nhập và xóa hết các màn hình cũ
          Navigator.of(context).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Xin chào, ${employee.hoTen}!'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
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
            _buildUserInfoCard(context),
            const SizedBox(height: 24),
            const Text(
              'Chức năng',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildFeatureGrid(context),
          ],
        ),
      ),
    );
  }

  // Widget hiển thị thông tin người dùng
  Widget _buildUserInfoCard(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.orange.shade100,
              child: Icon(
                Icons.person,
                size: 40,
                color: Colors.orange.shade800,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    employee.hoTen,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Email: ${employee.email}',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget hiển thị lưới các chức năng
  Widget _buildFeatureGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildFeatureCard(
          context,
          icon: Icons.touch_app,
          title: 'Chấm công',
          color: Colors.blue,
          onTap: () {
            _showCheckInOptions(context);
          },
        ),
        _buildFeatureCard(
          context,
          icon: Icons.bar_chart,
          title: 'Xem báo cáo',
          color: Colors.green,
          onTap: () {
            // TODO: Điều hướng đến màn hình báo cáo
             ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Chức năng Báo cáo sắp ra mắt!')),
            );
          },
        ),
        _buildFeatureCard(
          context,
          icon: Icons.manage_accounts,
          title: 'Thông tin cá nhân',
          color: Colors.purple,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfileScreen(nhanVien: employee),
              ),
            );
          },
        ),
        _buildFeatureCard(
          context,
          icon: Icons.lock_reset,
          title: 'Đổi mật khẩu',
          color: Colors.red,
          onTap: () {
             // TODO: Điều hướng đến màn hình đổi mật khẩu
             ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Chức năng Đổi mật khẩu sắp ra mắt!')),
            );
          },
        ),
      ],
    );
  }

  // Hiển thị bottom sheet với các tùy chọn chấm công
  void _showCheckInOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Chọn phương thức chấm công',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.fingerprint, color: Colors.blue),
                title: const Text('Chấm công bằng Vân tay'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement Fingerprint check-in
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Chức năng chấm công bằng vân tay sắp ra mắt!')),
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.face, color: Colors.purple),
                title: const Text('Chấm công bằng Khuôn mặt'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement Face check-in
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Chức năng chấm công bằng khuôn mặt sắp ra mắt!')),
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.nfc, color: Colors.teal),
                title: const Text('Chấm công bằng NFC'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DocNFCChamCongScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  // Widget cho một thẻ chức năng
  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
