import 'package:flutter/material.dart';
import '../../model/nhanvien/nhan_vien.dart';
import '../../services/nhan_vien/nhan_vien_service.dart';

class ThemNhanVienScreen extends StatefulWidget {
  const ThemNhanVienScreen({super.key});

  @override
  State<ThemNhanVienScreen> createState() => _ThemNhanVienScreenState();
}

class _ThemNhanVienScreenState extends State<ThemNhanVienScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _hoTenController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _dienThoaiController = TextEditingController();
  final TextEditingController _tenDangNhapController = TextEditingController();
  final TextEditingController _matKhauController = TextEditingController();
  final NhanVienService _nhanVienService = NhanVienService();

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final newNhanVien = NhanVien(
        hoTen: _hoTenController.text,
        email: _emailController.text,
        dienThoai: _dienThoaiController.text,
        tenDangNhap: _tenDangNhapController.text,
        matKhau: _matKhauController.text,
      );

      try {
        await _nhanVienService.createNhanVien(newNhanVien);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thêm nhân viên thành công!')),
        );
        Navigator.pop(context, true); // Trả về true để báo cần tải lại danh sách
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi thêm nhân viên: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm Nhân Viên'),
      ),
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
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _tenDangNhapController,
                decoration: const InputDecoration(labelText: 'Tên Đăng Nhập'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tên đăng nhập';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _matKhauController,
                decoration: const InputDecoration(labelText: 'Mật Khẩu'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập mật khẩu';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32.0),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Thêm Nhân Viên'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}