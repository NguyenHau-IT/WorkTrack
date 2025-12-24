import 'package:flutter/material.dart';
import 'them_nhan_vien_screen.dart';
import 'cap_nhat_nhan_vien_screen.dart';
import '../../services/nhan_vien/nhan_vien_service.dart';
import '../../model/nhanvien/nhan_vien.dart';

class DanhSachNhanVienScreen extends StatefulWidget {
  final NhanVien? currentUser;
  
  const DanhSachNhanVienScreen({super.key, this.currentUser});

  @override
  State<DanhSachNhanVienScreen> createState() => _DanhSachNhanVienScreenState();
}

class _DanhSachNhanVienScreenState extends State<DanhSachNhanVienScreen> {
  final NhanVienService _nhanVienService = NhanVienService();
  List<NhanVien> _danhSachNhanVien = [];
  bool _hienThiDaXoa = false;
  bool _isLoading = false;
  String? _errorMessage;

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
      final danhSach = await _nhanVienService.getAllNhanVien();
      setState(() {
        // Lọc bỏ nhân viên đang đăng nhập
        _danhSachNhanVien = danhSach.where((nv) => nv.maNV != widget.currentUser?.maNV).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _navigateToThemNhanVien() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ThemNhanVienScreen(),
      ),
    );

    if (result == true) {
      _loadDanhSach();
    }
  }

  Future<void> _navigateToCapNhatNhanVien(NhanVien nhanVien) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CapNhatNhanVienScreen(
          nhanVien: nhanVien,
          currentUser: widget.currentUser,
        ),
      ),
    );

    if (result == true) {
      _loadDanhSach();
    }
  }

  Future<void> _xoaNhanVien(NhanVien nhanVien) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa nhân viên "${nhanVien.hoTen}"?'),
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
        await _nhanVienService.deleteNhanVien(nhanVien.maNV!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Xóa nhân viên thành công!'),
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

  Future<void> _khoiPhucNhanVien(NhanVien nhanVien) async {
    try {
      await _nhanVienService.khoiPhucNhanVien(nhanVien.maNV!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Khôi phục nhân viên thành công!'),
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

  Future<void> _xoaCungNhanVien(NhanVien nhanVien) async {
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
              'Bạn có chắc chắn muốn xóa VĨNH VIỄN nhân viên này?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Nhân viên: ${nhanVien.hoTen}'),
            Text('Mã: ${nhanVien.maNV}'),
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
        await _nhanVienService.hardDeleteNhanVien(nhanVien.maNV!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã xóa vĩnh viễn nhân viên!'),
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
            errorDetail = 'Bạn không có quyền xóa vĩnh viễn nhân viên này';
          } else if (e.toString().contains('404')) {
            errorMessage = 'Không tìm thấy dữ liệu';
            errorDetail = 'Nhân viên không tồn tại trong hệ thống';
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
        title: const Text('Danh Sách Nhân Viên'),
        backgroundColor: Colors.blue,
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
        onPressed: _navigateToThemNhanVien,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        tooltip: 'Thêm nhân viên',
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

    final danhSachHienThi = _danhSachNhanVien
        .where((nv) => _hienThiDaXoa ? nv.daXoa : !nv.daXoa)
        .toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                icon: Icon(_hienThiDaXoa ? Icons.visibility : Icons.visibility_off),
                label: Text(_hienThiDaXoa ? 'Ẩn nhân viên đã xóa' : 'Hiện nhân viên đã xóa'),
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
                          Icons.people_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Không có nhân viên nào',
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
                      final nhanVien = danhSachHienThi[index];
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: nhanVien.daXoa ? Colors.grey : Colors.blue,
                            foregroundColor: Colors.white,
                            child: Text(
                              nhanVien.hoTen.substring(0, 1).toUpperCase(),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(
                            nhanVien.hoTen,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: nhanVien.daXoa ? Colors.grey : Colors.black,
                              decoration: nhanVien.daXoa ? TextDecoration.lineThrough : null,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.email, size: 14, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      nhanVien.email,
                                      style: TextStyle(
                                        color: nhanVien.daXoa ? Colors.grey : null,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (nhanVien.dienThoai != null && nhanVien.dienThoai!.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    const Icon(Icons.phone, size: 14, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text(
                                      nhanVien.dienThoai!,
                                      style: TextStyle(
                                        color: nhanVien.daXoa ? Colors.grey : null,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (nhanVien.daXoa) ...[
                                IconButton(
                                  icon: const Icon(Icons.restore, color: Colors.green),
                                  tooltip: 'Khôi phục',
                                  onPressed: () => _khoiPhucNhanVien(nhanVien),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_forever, color: Colors.red),
                                  tooltip: 'Xóa vĩnh viễn',
                                  onPressed: () => _xoaCungNhanVien(nhanVien),
                                ),
                              ] else ...[
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.orange),
                                  tooltip: 'Sửa',
                                  onPressed: () => _navigateToCapNhatNhanVien(nhanVien),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  tooltip: 'Xóa',
                                  onPressed: () => _xoaNhanVien(nhanVien),
                                ),
                              ],
                              Text(
                                'ID: ${nhanVien.maNV}',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
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