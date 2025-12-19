import 'package:flutter/material.dart';
import '../model/vaitro/vai_tro.dart';
import '../services/vaitro/vai_tro_service.dart';
import 'them_vai_tro_screen.dart';
import 'sua_vai_tro_screen.dart';

class DanhSachVaiTroScreen extends StatefulWidget {
  const DanhSachVaiTroScreen({super.key});

  @override
  State<DanhSachVaiTroScreen> createState() => _DanhSachVaiTroScreenState();
}

class _DanhSachVaiTroScreenState extends State<DanhSachVaiTroScreen> {
  final _vaiTroService = VaiTroService();
  List<VaiTro> _danhSachVaiTro = [];
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
      final danhSach = await _vaiTroService.layDanhSachVaiTro();
      setState(() {
        _danhSachVaiTro = danhSach;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _khoiPhucVaiTro(VaiTro vaiTro) async {
    try {
      await _vaiTroService.khoiPhucVaiTro(vaiTro.maVaiTro!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Khôi phục vai trò thành công!'),
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

  Future<void> _navigateToThemVaiTro() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ThemVaiTroScreen(),
      ),
    );

    // Nếu thêm thành công, reload danh sách
    if (result == true) {
      _loadDanhSach();
    }
  }

  Future<void> _navigateToSuaVaiTro(VaiTro vaiTro) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SuaVaiTroScreen(vaiTro: vaiTro),
      ),
    );

    if (result == true) {
      _loadDanhSach();
    }
  }

  Future<void> _xoaVaiTro(VaiTro vaiTro) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa vai trò "${vaiTro.tenVaiTro}"?'),
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
        await _vaiTroService.xoaVaiTro(vaiTro.maVaiTro!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Xóa vai trò thành công!'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh Sách Vai Trò'),
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
        onPressed: _navigateToThemVaiTro,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        tooltip: 'Thêm vai trò',
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

    // Lọc danh sách theo trạng thái daXoa
    final danhSachHienThi = _danhSachVaiTro.where((v) => _hienThiDaXoa ? v.daXoa == true : v.daXoa != true).toList();
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton.icon(
              icon: Icon(_hienThiDaXoa ? Icons.visibility : Icons.visibility_off),
              label: Text(_hienThiDaXoa ? 'Ẩn vai trò đã xóa' : 'Hiện vai trò đã xóa'),
              onPressed: () {
                setState(() {
                  _hienThiDaXoa = !_hienThiDaXoa;
                });
              },
            ),
          ],
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadDanhSach,
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: danhSachHienThi.length,
              itemBuilder: (context, index) {
                final vaiTro = danhSachHienThi[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: vaiTro.daXoa == true ? Colors.grey : Colors.blue,
                      foregroundColor: Colors.white,
                      child: Text(
                        vaiTro.tenVaiTro.substring(0, 1).toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(
                      vaiTro.tenVaiTro,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: vaiTro.daXoa == true ? Colors.grey : Colors.black,
                        decoration: vaiTro.daXoa == true ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    subtitle: vaiTro.moTa != null && vaiTro.moTa!.isNotEmpty
                        ? Text(
                            vaiTro.moTa!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: vaiTro.daXoa == true ? Colors.grey : null,
                              fontStyle: vaiTro.daXoa == true ? FontStyle.italic : null,
                            ),
                          )
                        : const Text(
                            'Không có mô tả',
                            style: TextStyle(fontStyle: FontStyle.italic),
                          ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (vaiTro.daXoa == true)
                          IconButton(
                            icon: const Icon(Icons.restore, color: Colors.green),
                            tooltip: 'Khôi phục',
                            onPressed: () => _khoiPhucVaiTro(vaiTro),
                          )
                        else ...[
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.orange),
                            tooltip: 'Sửa',
                            onPressed: () => _navigateToSuaVaiTro(vaiTro),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            tooltip: 'Xóa',
                            onPressed: () => _xoaVaiTro(vaiTro),
                          ),
                        ],
                        Text(
                          'ID: ${vaiTro.maVaiTro}',
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
