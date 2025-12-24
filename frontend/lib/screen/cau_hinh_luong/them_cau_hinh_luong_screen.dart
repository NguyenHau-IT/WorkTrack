import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../model/cauhinhluong/cau_hinh_luong.dart';
import '../../services/cauhinhluong/cau_hinh_luong_service.dart';

class ThemCauHinhLuongScreen extends StatefulWidget {
  const ThemCauHinhLuongScreen({super.key});

  @override
  State<ThemCauHinhLuongScreen> createState() => _ThemCauHinhLuongScreenState();
}

class _ThemCauHinhLuongScreenState extends State<ThemCauHinhLuongScreen> {
  final _formKey = GlobalKey<FormState>();
  final _luongGioController = TextEditingController();
  final _luongLamThemController = TextEditingController();
  final _cauHinhLuongService = CauHinhLuongService();
  bool _isLoading = false;

  @override
  void dispose() {
    _luongGioController.dispose();
    _luongLamThemController.dispose();
    super.dispose();
  }

  Future<void> _themCauHinh() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final cauHinh = CauHinhLuong(
          luongGio: double.parse(_luongGioController.text.trim().replaceAll(',', '')),
          luongLamThem: _luongLamThemController.text.trim().isEmpty
              ? 0.0
              : double.parse(_luongLamThemController.text.trim().replaceAll(',', '')),
        );

        await _cauHinhLuongService.createCauHinhLuong(cauHinh);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Thêm cấu hình lương thành công!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
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
        title: const Text('Thêm Cấu Hình Lương'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info card
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Cấu hình mức lương cơ bản và lương làm thêm giờ',
                          style: TextStyle(
                            color: Colors.blue.shade900,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Lương giờ
              TextFormField(
                controller: _luongGioController,
                decoration: const InputDecoration(
                  labelText: 'Lương giờ *',
                  hintText: 'Nhập mức lương theo giờ',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                  suffixText: '₫/giờ',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Lương giờ không được để trống';
                  }
                  final number = double.tryParse(value.replaceAll(',', ''));
                  if (number == null || number <= 0) {
                    return 'Lương giờ phải lớn hơn 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Lương làm thêm
              TextFormField(
                controller: _luongLamThemController,
                decoration: const InputDecoration(
                  labelText: 'Lương làm thêm',
                  hintText: 'Nhập mức lương làm thêm giờ (không bắt buộc)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.access_time),
                  suffixText: '₫/giờ',
                  helperText: 'Để trống nếu không có lương làm thêm',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    final number = double.tryParse(value.replaceAll(',', ''));
                    if (number == null || number < 0) {
                      return 'Lương làm thêm phải lớn hơn hoặc bằng 0';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Thông tin tính toán mẫu
              Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.calculate, color: Colors.green.shade700),
                          const SizedBox(width: 8),
                          Text(
                            'Ví dụ tính lương',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '• 160 giờ thường + 20 giờ làm thêm\n'
                        '• Lương = (160 × Lương giờ) + (20 × Lương làm thêm)',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.green.shade900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Nút thêm
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _themCauHinh,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save),
                label: Text(_isLoading ? 'Đang thêm...' : 'Thêm cấu hình'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
