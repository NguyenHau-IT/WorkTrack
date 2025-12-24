import 'package:flutter/material.dart';
import '../../model/nhanvien/nhan_vien.dart';
import '../../services/nhan_vien/nhan_vien_service.dart';
import '../../services/biometric/biometric_service.dart';
import 'dart:convert';

class ThemNhanVienScreen extends StatefulWidget {
  const ThemNhanVienScreen({super.key});

  @override
  State<ThemNhanVienScreen> createState() => _ThemNhanVienScreenState();
}

class _ThemNhanVienScreenState extends State<ThemNhanVienScreen> {
  final _formKey = GlobalKey<FormState>();
  final _hoTenController = TextEditingController();
  final _emailController = TextEditingController();
  final _dienThoaiController = TextEditingController();
  final _tenDangNhapController = TextEditingController();
  final _matKhauController = TextEditingController();
  final _xacNhanMatKhauController = TextEditingController();
  final _nhanVienService = NhanVienService();
  final _biometricService = BiometricService();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  NhanVien? _createdNhanVien;

  @override
  void dispose() {
    _hoTenController.dispose();
    _emailController.dispose();
    _dienThoaiController.dispose();
    _tenDangNhapController.dispose();
    _matKhauController.dispose();
    _xacNhanMatKhauController.dispose();
    super.dispose();
  }

  void _showFingerprintDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.fingerprint, color: Colors.blue, size: 28),
            SizedBox(width: 12),
            Text('Đăng ký vân tay'),
          ],
        ),
        content: Text(
          'Bạn có muốn đăng ký vân tay cho nhân viên ${_createdNhanVien?.hoTen} ngay bây giờ không?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context, true);
            },
            child: const Text('Để sau'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(context);
              await _registerFingerprintDirect();
            },
            icon: const Icon(Icons.fingerprint),
            label: const Text('Đăng ký ngay'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _registerFingerprintDirect() async {
    if (_createdNhanVien == null) return;

    try {
      // Kiểm tra hỗ trợ vân tay
      final canCheck = await _biometricService.canCheckBiometrics();
      if (!canCheck) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Thiết bị chưa đăng ký vân tay. Vui lòng đăng ký trong cài đặt hệ thống.'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 4),
            ),
          );
        }
        if (mounted) Navigator.pop(context, true);
        return;
      }

      // Hiển thị thông báo
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng đặt vân tay lên cảm biến...'),
            duration: Duration(seconds: 2),
          ),
        );
      }

      await Future.delayed(const Duration(milliseconds: 500));

      // Yêu cầu xác thực vân tay
      final didAuthenticate = await _biometricService.authenticate(
        localizedReason: 'Đặt vân tay để đăng ký cho nhân viên ${_createdNhanVien?.hoTen}',
        biometricOnly: false,
      );

      if (didAuthenticate) {
        // Tạo fingerprint hash
        final fingerprintHash = base64Encode(
          utf8.encode('${_createdNhanVien!.maNV}_fingerprint_${DateTime.now().millisecondsSinceEpoch}')
        );

        // Gửi lên server
        await _nhanVienService.updateVanTay(
          _createdNhanVien!.maNV!,
          fingerprintHash,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Đăng ký vân tay thành công!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
          await Future.delayed(const Duration(seconds: 1));
          Navigator.pop(context, true);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ Xác thực vân tay thất bại. Vui lòng thử lại.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      print('Error registering fingerprint: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
        Navigator.pop(context, true);
      }
    }
  }

  Future<void> _themNhanVien() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final nhanVien = NhanVien(
          hoTen: _hoTenController.text.trim(),
          email: _emailController.text.trim(),
          dienThoai: _dienThoaiController.text.trim().isEmpty
              ? null
              : _dienThoaiController.text.trim(),
          tenDangNhap: _tenDangNhapController.text.trim(),
          matKhau: _matKhauController.text,
        );

        final createdNhanVien = await _nhanVienService.createNhanVien(nhanVien);
        _createdNhanVien = createdNhanVien;

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Thêm nhân viên thành công!'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Hỏi có muốn đăng ký vân tay không
          _showFingerprintDialog();
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
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm Nhân Viên'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Họ tên
              TextFormField(
                controller: _hoTenController,
                decoration: const InputDecoration(
                  labelText: 'Họ và tên *',
                  hintText: 'Nhập họ và tên',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Họ tên không được để trống';
                  }
                  if (value.length > 100) {
                    return 'Họ tên không được vượt quá 100 ký tự';
                  }
                  return null;
                },
                maxLength: 100,
              ),
              const SizedBox(height: 16),

              // Email
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email *',
                  hintText: 'Nhập email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Email không được để trống';
                  }
                  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                  if (!emailRegex.hasMatch(value)) {
                    return 'Email không hợp lệ';
                  }
                  return null;
                },
                maxLength: 100,
              ),
              const SizedBox(height: 16),

              // Điện thoại
              TextFormField(
                controller: _dienThoaiController,
                decoration: const InputDecoration(
                  labelText: 'Số điện thoại',
                  hintText: 'Nhập số điện thoại (không bắt buộc)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final phoneRegex = RegExp(r'^[0-9]{10,11}$');
                    if (!phoneRegex.hasMatch(value)) {
                      return 'Số điện thoại không hợp lệ (10-11 số)';
                    }
                  }
                  return null;
                },
                maxLength: 11,
              ),
              const SizedBox(height: 16),

              // Tên đăng nhập
              TextFormField(
                controller: _tenDangNhapController,
                decoration: const InputDecoration(
                  labelText: 'Tên đăng nhập *',
                  hintText: 'Nhập tên đăng nhập',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.account_circle),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Tên đăng nhập không được để trống';
                  }
                  if (value.length < 3) {
                    return 'Tên đăng nhập phải có ít nhất 3 ký tự';
                  }
                  if (value.length > 50) {
                    return 'Tên đăng nhập không được vượt quá 50 ký tự';
                  }
                  return null;
                },
                maxLength: 50,
              ),
              const SizedBox(height: 16),

              // Mật khẩu
              TextFormField(
                controller: _matKhauController,
                decoration: InputDecoration(
                  labelText: 'Mật khẩu *',
                  hintText: 'Nhập mật khẩu',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                obscureText: _obscurePassword,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Mật khẩu không được để trống';
                  }
                  if (value.length < 6) {
                    return 'Mật khẩu phải có ít nhất 6 ký tự';
                  }
                  return null;
                },
                maxLength: 50,
              ),
              const SizedBox(height: 16),

              // Xác nhận mật khẩu
              TextFormField(
                controller: _xacNhanMatKhauController,
                decoration: InputDecoration(
                  labelText: 'Xác nhận mật khẩu *',
                  hintText: 'Nhập lại mật khẩu',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                ),
                obscureText: _obscureConfirmPassword,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng xác nhận mật khẩu';
                  }
                  if (value != _matKhauController.text) {
                    return 'Mật khẩu không khớp';
                  }
                  return null;
                },
                maxLength: 50,
              ),
              const SizedBox(height: 24),

              // Nút thêm
              ElevatedButton(
                onPressed: _isLoading ? null : _themNhanVien,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Thêm nhân viên',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}