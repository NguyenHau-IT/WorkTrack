import 'package:flutter/material.dart';
import '../../model/nhanvien/nhan_vien.dart';
import '../../services/auth/auth_service.dart';
import '../auth/change_password_screen.dart';

class ProfileScreen extends StatelessWidget {
  final NhanVien nhanVien;

  const ProfileScreen({super.key, required this.nhanVien});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông Tin Cá Nhân'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Chỉnh sửa',
            onPressed: () {
              // Điều hướng đến trang cập nhật
              Navigator.pushNamed(
                context,
                '/cap-nhat-nhan-vien',
                arguments: {'nhanVien': nhanVien, 'currentUser': nhanVien},
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header với avatar
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.orange, Colors.orange.shade300],
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 55,
                      backgroundColor: Colors.orange.shade700,
                      child: Text(
                        nhanVien.hoTen.isNotEmpty ? nhanVien.hoTen.substring(0, 1).toUpperCase() : '?',
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    nhanVien.hoTen,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      nhanVien.vaiTro?['tenVaiTro'] ?? 'Nhân viên',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),

            // Thông tin chi tiết
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Thông tin cá nhân',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Card thông tin
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      children: [
                        _buildInfoTile(
                          icon: Icons.badge,
                          label: 'Mã nhân viên',
                          value: nhanVien.maNV?.toString() ?? 'N/A',
                          color: Colors.blue,
                        ),
                        const Divider(height: 1, indent: 16, endIndent: 16),
                        _buildInfoTile(
                          icon: Icons.email,
                          label: 'Email',
                          value: nhanVien.email,
                          color: Colors.orange,
                        ),
                        const Divider(height: 1, indent: 16, endIndent: 16),
                        _buildInfoTile(
                          icon: Icons.phone,
                          label: 'Số điện thoại',
                          value: nhanVien.dienThoai ?? 'Chưa cập nhật',
                          color: Colors.green,
                        ),
                        const Divider(height: 1, indent: 16, endIndent: 16),
                        _buildInfoTile(
                          icon: Icons.account_circle,
                          label: 'Tên đăng nhập',
                          value: nhanVien.tenDangNhap,
                          color: Colors.purple,
                        ),
                        if (nhanVien.theNFC != null && nhanVien.theNFC!.isNotEmpty) ...[
                          const Divider(height: 1, indent: 16, endIndent: 16),
                          _buildInfoTile(
                            icon: Icons.credit_card,
                            label: 'Thẻ NFC',
                            value: nhanVien.theNFC!,
                            color: Colors.teal,
                          ),
                        ],
                        const Divider(height: 1, indent: 16, endIndent: 16),
                        _buildInfoTile(
                          icon: Icons.calendar_today,
                          label: 'Ngày tạo',
                          value: nhanVien.ngayTao != null
                              ? _formatDateTime(nhanVien.ngayTao!)
                              : 'N/A',
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Các hành động
                  const Text(
                    'Cài đặt tài khoản',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.lock, color: Colors.orange),
                          title: const Text('Đổi mật khẩu'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChangePasswordScreen(employee: nhanVien),
                              ),
                            );
                          },
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.fingerprint, color: Colors.blue),
                          title: const Text('Quản lý sinh trắc học'),
                          subtitle: const Text('Vân tay, khuôn mặt'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/biometric-setup',
                              arguments: nhanVien,
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Nút đăng xuất
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Đăng xuất'),
                            content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Hủy'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  Navigator.pop(context);
                                  
                                  final authService = AuthService();
                                  await authService.logout();
                                  
                                  if (context.mounted) {
                                    Navigator.pushNamedAndRemoveUntil(
                                      context, 
                                      '/login', 
                                      (route) => false,
                                    );
                                  }
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.red,
                                ),
                                child: const Text('Đăng xuất'),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text('Đăng xuất'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.1),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
        ),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
