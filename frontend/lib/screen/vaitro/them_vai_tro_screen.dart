import 'package:flutter/material.dart';
import '../../model/vaitro/vai_tro.dart';
import '../../services/vaitro/vai_tro_service.dart';

class ThemVaiTroScreen extends StatefulWidget {
  const ThemVaiTroScreen({super.key});

  @override
  State<ThemVaiTroScreen> createState() => _ThemVaiTroScreenState();
}

class _ThemVaiTroScreenState extends State<ThemVaiTroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tenVaiTroController = TextEditingController();
  final _moTaController = TextEditingController();
  final _vaiTroService = VaiTroService();
  bool _isLoading = false;

  @override
  void dispose() {
    _tenVaiTroController.dispose();
    _moTaController.dispose();
    super.dispose();
  }

  Future<void> _themVaiTro() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final vaiTro = VaiTro(
          tenVaiTro: _tenVaiTroController.text.trim(),
          moTa: _moTaController.text.trim().isEmpty 
              ? null 
              : _moTaController.text.trim(),
        );

        await _vaiTroService.themVaiTro(vaiTro);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Thêm vai trò thành công!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true); // Trả về true để refresh danh sách
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
        title: const Text('Thêm Vai Trò'),
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
              // Tên vai trò
              TextFormField(
                controller: _tenVaiTroController,
                decoration: const InputDecoration(
                  labelText: 'Tên vai trò *',
                  hintText: 'Nhập tên vai trò',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.badge),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Tên vai trò không được để trống';
                  }
                  if (value.length > 50) {
                    return 'Tên vai trò không được vượt quá 50 ký tự';
                  }
                  return null;
                },
                maxLength: 50,
              ),
              const SizedBox(height: 16),

              // Mô tả
              TextFormField(
                controller: _moTaController,
                decoration: const InputDecoration(
                  labelText: 'Mô tả',
                  hintText: 'Nhập mô tả vai trò (không bắt buộc)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
                maxLength: 255,
                validator: (value) {
                  if (value != null && value.length > 255) {
                    return 'Mô tả không được vượt quá 255 ký tự';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Nút thêm
              ElevatedButton(
                onPressed: _isLoading ? null : _themVaiTro,
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
                        'Thêm vai trò',
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
