import 'package:flutter/material.dart';
import '../../services/nhan_vien/nhan_vien_service.dart';
import '../../model/nhanvien/nhan_vien.dart';

class CapNhatNhanVienScreen extends StatefulWidget {
  final NhanVien nhanVien;

  const CapNhatNhanVienScreen({super.key, required this.nhanVien});

  @override
  State<CapNhatNhanVienScreen> createState() => _CapNhatNhanVienScreenState();
}

class _CapNhatNhanVienScreenState extends State<CapNhatNhanVienScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _hoTenController;
  late TextEditingController _emailController;
  late TextEditingController _dienThoaiController;
  final NhanVienService _nhanVienService = NhanVienService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _hoTenController = TextEditingController(text: widget.nhanVien.hoTen);
    _emailController = TextEditingController(text: widget.nhanVien.email);
    _dienThoaiController = TextEditingController(
      text: widget.nhanVien.dienThoai,
    );
  }

  @override
  void dispose() {
    _hoTenController.dispose();
    _emailController.dispose();
    _dienThoaiController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final updatedNhanVien = NhanVien(
          maNV: widget.nhanVien.maNV,
          hoTen: _hoTenController.text,
          email: _emailController.text,
          dienThoai: _dienThoaiController.text,
          tenDangNhap: widget.nhanVien.tenDangNhap,
          matKhau: widget.nhanVien.matKhau,
          maVaiTro: widget.nhanVien.maVaiTro,
          theNFC: widget.nhanVien.theNFC,
          ngayTao: widget.nhanVien.ngayTao,
          ngayCapNhat: DateTime.now(),
          daXoa: widget.nhanVien.daXoa,
        );
        await _nhanVienService.updateNhanVien(
          updatedNhanVien.maNV!,
          updatedNhanVien,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật nhân viên thành công!')),
        );
        Navigator.pop(context, true); // Trả về true để tải lại danh sách
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi cập nhật nhân viên: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cập Nhật Nhân Viên')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _hoTenController,
                decoration: const InputDecoration(labelText: 'Họ Tên'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập họ tên';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _dienThoaiController,
                decoration: const InputDecoration(labelText: 'Điện Thoại'),
              ),
              const SizedBox(height: 32.0),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Cập Nhật Nhân Viên'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
