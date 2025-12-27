import 'package:flutter/material.dart';
import '../../model/nhanvien/nhan_vien.dart';
import '../../services/auth/auth_service.dart';
import '../../services/nhan_vien/nhan_vien_service.dart';
import '../../services/chamcong/cham_cong_service.dart';
import '../../services/baocao/bao_cao_service.dart';
import '../profile/profile_screen.dart';
import '../nhan_vien/danh_sach_nhan_vien_screen.dart';
import '../cham_cong/danh_sach_cham_cong_screen.dart';
import '../cham_cong/doc_nfc_cham_cong_screen.dart';
import '../baocao/danh_sach_bao_cao_screen.dart';

class ManagerHomeScreen extends StatefulWidget {
  final NhanVien manager;

  const ManagerHomeScreen({super.key, required this.manager});

  @override
  State<ManagerHomeScreen> createState() => _ManagerHomeScreenState();
}

class _ManagerHomeScreenState extends State<ManagerHomeScreen> {
  final NhanVienService _nhanVienService = NhanVienService();
  final ChamCongService _chamCongService = ChamCongService();
  final BaoCaoService _baoCaoService = BaoCaoService();
  
  int _totalEmployees = 0;
  int _presentEmployees = 0;
  int _absentEmployees = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Lấy danh sách nhân viên
      final employees = await _nhanVienService.getAllNhanVien();
      final activeEmployees = employees.where((emp) => !emp.daXoa).toList();
      
      // Lấy dữ liệu chấm công hôm nay
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);
      
      final todayChamCong = await _chamCongService.getChamCongByDateRange(startOfDay, endOfDay);
      
      // Tính toán số liệu
      final presentEmployeeIds = todayChamCong
          .where((cc) => cc.gioVao != null && !cc.daXoa)
          .map((cc) => cc.maNV)
          .toSet();
      
      setState(() {
        _totalEmployees = activeEmployees.length;
        _presentEmployees = presentEmployeeIds.length;
        _absentEmployees = _totalEmployees - _presentEmployees;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        // Giữ giá trị mặc định nếu có lỗi
        _totalEmployees = 0;
        _presentEmployees = 0;
        _absentEmployees = 0;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tải dữ liệu dashboard: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

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
        title: Text('Manager Dashboard - ${widget.manager.hoTen}'),
        backgroundColor: Colors.indigo,
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
                    builder: (context) => ProfileScreen(nhanVien: widget.manager),
                  ),
                );
              },
              child: CircleAvatar(
                backgroundColor: Colors.white,
                foregroundColor: Colors.indigo,
                child: Text(
                  widget.manager.hoTen.isNotEmpty ? widget.manager.hoTen.substring(0, 1).toUpperCase() : 'M',
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
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Làm mới dữ liệu',
            onPressed: _loadDashboardData,
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
              'Quản lý Nhân sự',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildHRManagementGrid(context),
            const SizedBox(height: 24),
            const Text(
              'Báo cáo & Giám sát',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildReportsGrid(context),
            const SizedBox(height: 24),
            const Text(
              'Chức năng cá nhân',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildPersonalGrid(context),
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
            colors: [Colors.indigo.shade700, Colors.indigo.shade500],
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
                  Icons.manage_accounts,
                  color: Colors.white,
                  size: 40,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Chào mừng, ${widget.manager.hoTen}!',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Quản lý nhân sự',
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
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: _isLoading
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem('Nhân viên', '$_totalEmployees'),
                        _buildStatItem('Có mặt', '$_presentEmployees'),
                        _buildStatItem('Vắng mặt', '$_absentEmployees'),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildHRManagementGrid(BuildContext context) {
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
                builder: (context) => DanhSachNhanVienScreen(currentUser: widget.manager),
              ),
            );
          },
        ),
        _buildFeatureCard(
          context,
          icon: Icons.access_time,
          title: 'Giám sát Chấm công',
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
          icon: Icons.schedule,
          title: 'Lịch làm việc',
          color: Colors.purple,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Chức năng Lịch làm việc đang phát triển')),
            );
          },
        ),
        _buildFeatureCard(
          context,
          icon: Icons.event_note,
          title: 'Quản lý Nghỉ phép',
          color: Colors.orange,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Chức năng Nghỉ phép đang phát triển')),
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
          icon: Icons.assessment,
          title: 'Báo cáo Chấm công',
          color: Colors.teal,
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
          icon: Icons.trending_up,
          title: 'Hiệu suất Nhóm',
          color: Colors.deepOrange,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Chức năng Hiệu suất đang phát triển')),
            );
          },
        ),
        _buildFeatureCard(
          context,
          icon: Icons.pie_chart,
          title: 'Phân tích Nhân sự',
          color: Colors.cyan,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Chức năng Phân tích đang phát triển')),
            );
          },
        ),
        _buildFeatureCard(
          context,
          icon: Icons.calendar_view_month,
          title: 'Báo cáo Tháng',
          color: Colors.brown,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Chức năng Báo cáo tháng đang phát triển')),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPersonalGrid(BuildContext context) {
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
          title: 'Chấm công cá nhân',
          color: Colors.blue.shade700,
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
          icon: Icons.person_pin,
          title: 'Thông tin cá nhân',
          color: Colors.green.shade700,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfileScreen(nhanVien: widget.manager),
              ),
            );
          },
        ),
        _buildFeatureCard(
          context,
          icon: Icons.notifications,
          title: 'Thông báo',
          color: Colors.amber.shade700,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Chức năng Thông báo đang phát triển')),
            );
          },
        ),
        _buildFeatureCard(
          context,
          icon: Icons.settings,
          title: 'Cài đặt',
          color: Colors.grey.shade600,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Chức năng Cài đặt đang phát triển')),
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