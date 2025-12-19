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

    return RefreshIndicator(
      onRefresh: _loadDanhSach,
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: _danhSachVaiTro.length,
        itemBuilder: (context, index) {
          final vaiTro = _danhSachVaiTro[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                child: Text(
                  vaiTro.tenVaiTro.substring(0, 1).toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(
                vaiTro.tenVaiTro,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: vaiTro.moTa != null && vaiTro.moTa!.isNotEmpty
                  ? Text(
                      vaiTro.moTa!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    )
                  : const Text(
                      'Không có mô tả',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
              trailing: Text(
                'ID: ${vaiTro.maVaiTro}',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
