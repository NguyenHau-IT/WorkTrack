import 'package:flutter/material.dart';
import '../model/vaitro/vai_tro.dart';
import '../services/vaitro/vai_tro_service.dart';

class SuaVaiTroScreen extends StatefulWidget {
  final VaiTro vaiTro;

  const SuaVaiTroScreen({super.key, required this.vaiTro});

  @override
  State<SuaVaiTroScreen> createState() => _SuaVaiTroScreenState();
}

class _SuaVaiTroScreenState extends State<SuaVaiTroScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _tenVaiTroController;
  late TextEditingController _moTaController;
  final _vaiTroService = VaiTroService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tenVaiTroController = TextEditingController(text: widget.vaiTro.tenVaiTro);
    _moTaController = TextEditingController(text: widget.vaiTro.moTa ?? '');
  }

  @override
  void dispose() {
    _tenVaiTroController.dispose();
    _moTaController.dispose();
    super.dispose();
  }

  Future<void> _capNhatVaiTro() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final vaiTroCapNhat = VaiTro(
          maVaiTro: widget.vaiTro.maVaiTro,
          tenVaiTro: _tenVaiTroController.text.trim(),
          moTa: _moTaController.text.trim().isEmpty
              ? null
              : _moTaController.text.trim(),
          ngayTao: widget.vaiTro.ngayTao,
        );

        await _vaiTroService.capNhatVaiTro(
          widget.vaiTro.maVaiTro!,
          vaiTroCapNhat,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cập nhật vai trò thành công!'),
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
        title: const Text('Sửa Vai Trò'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Hiển thị ID
              Card(
                color: Colors.grey[100],
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        'ID: ${widget.vaiTro.maVaiTro}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

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

              // Nút cập nhật
              ElevatedButton(
                onPressed: _isLoading ? null : _capNhatVaiTro,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
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
                        'Cập nhật',
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
