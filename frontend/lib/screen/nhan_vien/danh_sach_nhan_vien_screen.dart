import 'package:flutter/material.dart';
import 'them_nhan_vien_screen.dart';
import '../../services/nhan_vien/nhan_vien_service.dart';
import '../../model/nhanvien/nhan_vien.dart';

class DanhSachNhanVienScreen extends StatefulWidget {
  const DanhSachNhanVienScreen({super.key});

  @override
  State<DanhSachNhanVienScreen> createState() => _DanhSachNhanVienScreenState();
}

class _DanhSachNhanVienScreenState extends State<DanhSachNhanVienScreen> {
  final NhanVienService _nhanVienService = NhanVienService();
  List<NhanVien> _danhSachNhanVien = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDanhSachNhanVien();
  }

  Future<void> _fetchDanhSachNhanVien() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final danhSach = await _nhanVienService.getAllNhanVien();
      setState(() {
        _danhSachNhanVien = danhSach;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi tải danh sách nhân viên: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh Sách Nhân Viên'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchDanhSachNhanVien,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ThemNhanVienScreen(),
                ),
              );
              if (result == true) {
                _fetchDanhSachNhanVien(); // Tải lại danh sách nếu cần
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _danhSachNhanVien.isEmpty
              ? const Center(child: Text('Không có nhân viên nào.'))
              : ListView.builder(
                  itemCount: _danhSachNhanVien.length,
                  itemBuilder: (context, index) {
                    final nhanVien = _danhSachNhanVien[index];
                    return ListTile(
                      title: Text(nhanVien.hoTen),
                      subtitle: Text('Mã NV: ${nhanVien.maNV}'),
                    );
                  },
                ),
    );
  }
}