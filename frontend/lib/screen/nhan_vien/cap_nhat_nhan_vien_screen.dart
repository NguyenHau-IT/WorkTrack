import 'package:flutter/material.dart';
import '../../services/nhan_vien/nhan_vien_service.dart';
import '../../services/vaitro/vai_tro_service.dart';
import '../../model/nhanvien/nhan_vien.dart';
import '../../model/vaitro/vai_tro.dart';

class CapNhatNhanVienScreen extends StatefulWidget {
  final NhanVien nhanVien;
  final NhanVien? currentUser;

  const CapNhatNhanVienScreen({
    super.key, 
    required this.nhanVien,
    this.currentUser,
  });

  @override
  State<CapNhatNhanVienScreen> createState() => _CapNhatNhanVienScreenState();
}

class _CapNhatNhanVienScreenState extends State<CapNhatNhanVienScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _hoTenController;
  late TextEditingController _emailController;
  late TextEditingController _dienThoaiController;
  late TextEditingController _theNFCController;
  final _nhanVienService = NhanVienService();
  final _vaiTroService = VaiTroService();
  bool _isLoading = false;
  
  List<VaiTro> _danhSachVaiTro = [];
  int? _selectedVaiTro;
  bool _isLoadingVaiTro = true;

  @override
  void initState() {
    super.initState();
    _hoTenController = TextEditingController(text: widget.nhanVien.hoTen);
    _emailController = TextEditingController(text: widget.nhanVien.email);
    _dienThoaiController = TextEditingController(
      text: widget.nhanVien.dienThoai ?? '',
    );
    _theNFCController = TextEditingController(
      text: widget.nhanVien.theNFC ?? '',
    );
    _selectedVaiTro = widget.nhanVien.maVaiTro;
    
    if (_isAdmin) {
      _loadVaiTro();
    }
  }

  bool get _isAdmin => widget.currentUser?.isAdmin ?? false;

  Future<void> _loadVaiTro() async {
    try {
      final danhSach = await _vaiTroService.layDanhSachVaiTro();
      setState(() {
        _danhSachVaiTro = danhSach.where((vt) => vt.daXoa != true).toList();
        _isLoadingVaiTro = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingVaiTro = false;
      });
    }
  }

  @override
  void dispose() {
    _hoTenController.dispose();
    _emailController.dispose();
    _dienThoaiController.dispose();
    _theNFCController.dispose();
    super.dispose();
  }

  Future<void> _capNhatNhanVien() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final updatedNhanVien = NhanVien(
          maNV: widget.nhanVien.maNV,
          hoTen: _hoTenController.text.trim(),
          email: _emailController.text.trim(),
          dienThoai: _dienThoaiController.text.trim().isEmpty
              ? null
              : _dienThoaiController.text.trim(),
          tenDangNhap: widget.nhanVien.tenDangNhap,
          matKhau: widget.nhanVien.matKhau,
          maVaiTro: _isAdmin ? _selectedVaiTro : widget.nhanVien.maVaiTro,
          theNFC: _isAdmin && _theNFCController.text.trim().isNotEmpty
              ? _theNFCController.text.trim()
              : widget.nhanVien.theNFC,
          ngayTao: widget.nhanVien.ngayTao,
          ngayCapNhat: DateTime.now(),
          daXoa: widget.nhanVien.daXoa,
        );

        await _nhanVienService.updateNhanVien(
          updatedNhanVien.maNV!,
          updatedNhanVien,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cập nhật nhân viên thành công!'),
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
        title: const Text('Cập Nhật Nhân Viên'),
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
              // Hiển thị ID và tên đăng nhập
              Card(
                color: Colors.grey[100],
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.info_outline, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text(
                            'ID: ${widget.nhanVien.maNV}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.account_circle, color: Colors.grey, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Tên đăng nhập: ${widget.nhanVien.tenDangNhap}',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

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

              // Vai trò (chỉ admin mới thấy)
              if (_isAdmin) ...[
                if (_isLoadingVaiTro)
                  const Center(child: CircularProgressIndicator())
                else
                  DropdownButtonFormField<int>(
                    value: _selectedVaiTro,
                    decoration: const InputDecoration(
                      labelText: 'Vai trò *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.badge),
                    ),
                    items: _danhSachVaiTro.map((vaiTro) {
                      return DropdownMenuItem<int>(
                        value: vaiTro.maVaiTro,
                        child: Row(
                          children: [
                            Icon(
                              vaiTro.tenVaiTro.toLowerCase() == 'admin'
                                  ? Icons.admin_panel_settings
                                  : Icons.person,
                              size: 20,
                              color: vaiTro.tenVaiTro.toLowerCase() == 'admin'
                                  ? Colors.red
                                  : Colors.blue,
                            ),
                            const SizedBox(width: 8),
                            Text(vaiTro.tenVaiTro),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedVaiTro = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Vui lòng chọn vai trò';
                      }
                      return null;
                    },
                  ),
                const SizedBox(height: 16),

                // Thẻ NFC
                TextFormField(
                  controller: _theNFCController,
                  decoration: const InputDecoration(
                    labelText: 'Thẻ NFC',
                    hintText: 'Nhập mã thẻ NFC (không bắt buộc)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.credit_card),
                  ),
                  maxLength: 50,
                  validator: (value) {
                    if (value != null && value.length > 50) {
                      return 'Mã thẻ NFC không được vượt quá 50 ký tự';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
              ],

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
              const SizedBox(height: 24),

              // Nút cập nhật
              ElevatedButton(
                onPressed: _isLoading ? null : _capNhatNhanVien,
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
