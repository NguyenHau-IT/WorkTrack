import 'package:flutter/material.dart';
import 'them_cau_hinh_luong_screen.dart';
import 'cap_nhat_cau_hinh_luong_screen.dart';
import '../../services/cauhinhluong/cau_hinh_luong_service.dart';
import '../../model/cauhinhluong/cau_hinh_luong.dart';
import '../../model/nhanvien/nhan_vien.dart';
import 'package:intl/intl.dart';

class DanhSachCauHinhLuongScreen extends StatefulWidget {
  final NhanVien? currentUser;
  
  const DanhSachCauHinhLuongScreen({super.key, this.currentUser});

  @override
  State<DanhSachCauHinhLuongScreen> createState() => _DanhSachCauHinhLuongScreenState();
}

class _DanhSachCauHinhLuongScreenState extends State<DanhSachCauHinhLuongScreen> {
  final CauHinhLuongService _cauHinhLuongService = CauHinhLuongService();
  List<CauHinhLuong> _danhSachCauHinh = [];
  bool _hienThiDaXoa = false;
  bool _isLoading = false;
  String? _errorMessage;
  final _currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

  @override
  void initState() {
    super.initState();
    _loadDanhSach();
  }

  Future<void> _loadDanhSach() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final danhSach = await _cauHinhLuongService.getAllCauHinhLuong();
      setState(() {
        _danhSachCauHinh = danhSach;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _navigateToThemCauHinh() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ThemCauHinhLuongScreen(),
      ),
    );

    if (result == true) {
      _loadDanhSach();
    }
  }

  Future<void> _navigateToCapNhatCauHinh(CauHinhLuong cauHinh) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CapNhatCauHinhLuongScreen(cauHinh: cauHinh),
      ),
    );

    if (result == true) {
      _loadDanhSach();
    }
  }

  Future<void> _xoaCauHinh(CauHinhLuong cauHinh) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa cấu hình lương này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _cauHinhLuongService.deleteCauHinhLuong(cauHinh.maCauHinh!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Xóa cấu hình lương thành công!'),
              backgroundColor: Colors.green,
            ),
          );
          _loadDanhSach();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _khoiPhucCauHinh(CauHinhLuong cauHinh) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận khôi phục'),
        content: const Text('Bạn có chắc chắn muốn khôi phục cấu hình lương này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.green),
            child: const Text('Khôi phục'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _cauHinhLuongService.restoreCauHinhLuong(cauHinh.maCauHinh!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Khôi phục cấu hình lương thành công!'),
              backgroundColor: Colors.green,
            ),
          );
          _loadDanhSach();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _xoaCungCauHinh(CauHinhLuong cauHinh) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red, size: 28),
            SizedBox(width: 8),
            Text('Xác nhận xóa vĩnh viễn'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bạn có chắc chắn muốn xóa VĨNH VIỄN cấu hình lương này?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Lương giờ: ${cauHinh.luongGio.toStringAsFixed(0)} ₫'),
            const SizedBox(height: 16),
            const Text(
              '⚠️ Hành động này KHÔNG THỂ HOÀN TÁC!',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa vĩnh viễn'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _cauHinhLuongService.hardDeleteCauHinhLuong(cauHinh.maCauHinh!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã xóa vĩnh viễn cấu hình lương!'),
              backgroundColor: Colors.green,
            ),
          );
          _loadDanhSach();
        }
      } catch (e) {
        if (mounted) {
          String errorMessage = 'Không thể xóa vĩnh viễn';
          String errorDetail = 'Vui lòng thử lại sau';
          
          if (e.toString().contains('403')) {
            errorMessage = 'Không có quyền truy cập';
            errorDetail = 'Bạn không có quyền xóa vĩnh viễn cấu hình lương này';
          } else if (e.toString().contains('404')) {
            errorMessage = 'Không tìm thấy dữ liệu';
            errorDetail = 'Cấu hình lương không tồn tại trong hệ thống';
          } else if (e.toString().contains('network') || e.toString().contains('Connection')) {
            errorMessage = 'Lỗi kết nối';
            errorDetail = 'Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối mạng';
          }

          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 28),
                  const SizedBox(width: 8),
                  Text(errorMessage),
                ],
              ),
              content: Text(errorDetail),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Đóng'),
                ),
              ],
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cấu Hình Lương'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDanhSach,
            tooltip: 'Làm mới',
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToThemCauHinh,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        tooltip: 'Thêm cấu hình',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Lỗi: $_errorMessage',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadDanhSach,
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    final danhSachHienThi = _danhSachCauHinh
        .where((ch) => _hienThiDaXoa ? ch.daXoa : !ch.daXoa)
        .toList();

    return Column(
      children: [
        // Chỉ admin mới thấy toggle "Hiện đã xóa"
        if (widget.currentUser?.isAdmin == true)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  icon: Icon(_hienThiDaXoa ? Icons.visibility : Icons.visibility_off),
                  label: Text(_hienThiDaXoa ? 'Ẩn đã xóa' : 'Hiện đã xóa'),
                  onPressed: () {
                    setState(() {
                      _hienThiDaXoa = !_hienThiDaXoa;
                    });
                  },
                ),
              ],
            ),
          ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadDanhSach,
            child: danhSachHienThi.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.settings_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Chưa có cấu hình lương nào',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: danhSachHienThi.length,
                    itemBuilder: (context, index) {
                      final cauHinh = danhSachHienThi[index];
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: cauHinh.daXoa ? Colors.grey : Colors.green,
                            foregroundColor: Colors.white,
                            child: const Icon(Icons.attach_money),
                          ),
                          title: Text(
                            'Cấu hình #${cauHinh.maCauHinh}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: cauHinh.daXoa ? Colors.grey : Colors.black,
                              decoration: cauHinh.daXoa ? TextDecoration.lineThrough : null,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.schedule, size: 14, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      'Lương giờ: ${_currencyFormat.format(cauHinh.luongGio)}',
                                      style: TextStyle(
                                        color: cauHinh.daXoa ? Colors.grey : Colors.black87,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.access_time, size: 14, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      'Làm thêm: ${_currencyFormat.format(cauHinh.luongLamThem)}',
                                      style: TextStyle(
                                        color: cauHinh.daXoa ? Colors.grey : Colors.black87,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (cauHinh.ngayTao != null) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Text(
                                          'Ngày tạo: ${DateFormat('dd/MM/yyyy').format(cauHinh.ngayTao!)}',
                                          style: TextStyle(
                                            color: cauHinh.daXoa ? Colors.grey : Colors.black54,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                          trailing: SizedBox(
                            width: 96,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (!cauHinh.daXoa) ...[
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.orange),
                                    tooltip: 'Sửa',
                                    onPressed: () => _navigateToCapNhatCauHinh(cauHinh),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    tooltip: 'Xóa',
                                    onPressed: () => _xoaCauHinh(cauHinh),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ] else ...[
                                  IconButton(
                                    icon: const Icon(Icons.restore, color: Colors.blue),
                                    tooltip: 'Khôi phục',
                                    onPressed: () => _khoiPhucCauHinh(cauHinh),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_forever, color: Colors.red),
                                    tooltip: 'Xóa vĩnh viễn',
                                    onPressed: () => _xoaCungCauHinh(cauHinh),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }
}
