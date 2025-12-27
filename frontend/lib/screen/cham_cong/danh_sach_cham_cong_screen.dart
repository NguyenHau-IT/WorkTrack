import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../model/chamcong/cham_cong.dart';
import '../../model/nhanvien/nhan_vien.dart';
import '../../services/chamcong/cham_cong_service.dart';
import 'them_cham_cong_screen.dart';
import 'cap_nhat_cham_cong_screen.dart';

class DanhSachChamCongScreen extends StatefulWidget {
  final NhanVien? currentUser;
  
  const DanhSachChamCongScreen({super.key, this.currentUser});

  @override
  State<DanhSachChamCongScreen> createState() => _DanhSachChamCongScreenState();
}

class _DanhSachChamCongScreenState extends State<DanhSachChamCongScreen> {
  final ChamCongService _chamCongService = ChamCongService();
  List<ChamCong> _danhSachChamCong = [];
  bool _hienThiDaXoa = false;
  bool _isLoading = false;
  String? _errorMessage;
  DateTime? _tuNgay;
  DateTime? _denNgay;
  int? _maNVFilter;
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy HH:mm');
  final DateFormat _dateOnlyFormat = DateFormat('dd/MM/yyyy');

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
      List<ChamCong> danhSach;
      
      if (_tuNgay != null && _denNgay != null) {
        danhSach = await _chamCongService.getChamCongByDateRange(_tuNgay!, _denNgay!);
      } else if (_maNVFilter != null) {
        danhSach = await _chamCongService.getChamCongByNhanVien(_maNVFilter!);
      } else {
        danhSach = await _chamCongService.getAllChamCong();
      }
      
      setState(() {
        _danhSachChamCong = danhSach;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        String errorMessage = 'Không thể tải dữ liệu';
        String errorDetail = 'Vui lòng thử lại sau';
        
        if (e.toString().contains('403')) {
          errorMessage = 'Không có quyền truy cập';
          errorDetail = 'Bạn không có quyền xem danh sách chấm công';
        } else if (e.toString().contains('network') || e.toString().contains('Connection')) {
          errorMessage = 'Lỗi kết nối';
          errorDetail = 'Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối mạng';
        } else if (e.toString().contains('timeout')) {
          errorMessage = 'Hết thời gian chờ';
          errorDetail = 'Máy chủ không phản hồi. Vui lòng thử lại';
        }

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
                const SizedBox(width: 8),
                Text(errorMessage),
              ],
            ),
            content: Text(errorDetail),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Đóng'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _loadDanhSach();
                },
                child: const Text('Thử lại'),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> _chonKhoangNgay() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _tuNgay != null && _denNgay != null
          ? DateTimeRange(start: _tuNgay!, end: _denNgay!)
          : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _tuNgay = picked.start;
        _denNgay = picked.end;
      });
      _loadDanhSach();
    }
  }

  void _xoaBoLoc() {
    setState(() {
      _tuNgay = null;
      _denNgay = null;
      _maNVFilter = null;
    });
    _loadDanhSach();
  }

  Future<void> _navigateToThemChamCong() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ThemChamCongScreen(),
      ),
    );

    if (result == true) {
      _loadDanhSach();
    }
  }

  Future<void> _navigateToCapNhatChamCong(ChamCong chamCong) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CapNhatChamCongScreen(chamCong: chamCong),
      ),
    );

    if (result == true) {
      _loadDanhSach();
    }
  }

  Future<void> _xoaChamCong(ChamCong chamCong) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text(
            'Bạn có chắc chắn muốn xóa bản ghi chấm công này?\nNhân viên: ${chamCong.nhanVien?.hoTen ?? "N/A"}'),
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
        await _chamCongService.deleteChamCong(chamCong.maChamCong!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Xóa bản ghi chấm công thành công!'),
              backgroundColor: Colors.green,
            ),
          );
          _loadDanhSach();
        }
      } catch (e) {
        if (mounted) {
          String errorMessage = 'Không thể xóa bản ghi chấm công';
          String errorDetail = 'Vui lòng thử lại sau';
          
          if (e.toString().contains('403')) {
            errorMessage = 'Không có quyền truy cập';
            errorDetail = 'Bạn không có quyền xóa bản ghi chấm công này';
          } else if (e.toString().contains('404')) {
            errorMessage = 'Không tìm thấy dữ liệu';
            errorDetail = 'Bản ghi chấm công không tồn tại hoặc đã bị xóa';
          } else if (e.toString().contains('network') || e.toString().contains('Connection')) {
            errorMessage = 'Lỗi kết nối';
            errorDetail = 'Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối mạng';
          }

          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 28),
                  const SizedBox(width: 8),
                  Text(errorMessage),
                ],
              ),
              content: Text(errorDetail),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Đóng'),
                ),
              ],
            ),
          );
        }
      }
    }
  }

  Future<void> _xoaCungChamCong(ChamCong chamCong) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red, size: 28),
            SizedBox(width: 8),
            Text('Xác nhận xóa vĩnh viễn'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bạn có chắc chắn muốn xóa VĨNH VIỄN bản ghi này?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Nhân viên: ${chamCong.nhanVien?.hoTen ?? "N/A"}'),
            const SizedBox(height: 16),
            const Text(
              '⚠️ Hành động này KHÔNG THỂ HOÀN TÁC!',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa vĩnh viễn'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _chamCongService.hardDeleteChamCong(chamCong.maChamCong!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã xóa vĩnh viễn bản ghi chấm công!'),
              backgroundColor: Colors.green,
            ),
          );
          _loadDanhSach();
        }
      } catch (e) {
        if (mounted) {
          String errorMessage = 'Không thể xóa vĩnh viễn';
          String errorDetail = 'Vui lòng thử lại sau';
          
          if (e.toString().contains('403')) {
            errorMessage = 'Không có quyền truy cập';
            errorDetail = 'Bạn không có quyền xóa vĩnh viễn bản ghi này';
          } else if (e.toString().contains('404')) {
            errorMessage = 'Không tìm thấy dữ liệu';
            errorDetail = 'Bản ghi không tồn tại trong hệ thống';
          } else if (e.toString().contains('network') || e.toString().contains('Connection')) {
            errorMessage = 'Lỗi kết nối';
            errorDetail = 'Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối mạng';
          }

          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 28),
                  const SizedBox(width: 8),
                  Text(errorMessage),
                ],
              ),
              content: Text(errorDetail),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Đóng'),
                ),
              ],
            ),
          );
        }
      }
    }
  }

  Future<void> _khoiPhucChamCong(ChamCong chamCong) async {
    try {
      await _chamCongService.khoiPhucChamCong(chamCong.maChamCong!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Khôi phục bản ghi chấm công thành công!'),
            backgroundColor: Colors.green,
          ),
        );
        _loadDanhSach();
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Không thể khôi phục';
        String errorDetail = 'Vui lòng thử lại sau';
        
        if (e.toString().contains('403')) {
          errorMessage = 'Không có quyền truy cập';
          errorDetail = 'Bạn không có quyền khôi phục bản ghi chấm công này';
        } else if (e.toString().contains('404')) {
          errorMessage = 'Không tìm thấy dữ liệu';
          errorDetail = 'Bản ghi chấm công không tồn tại trong hệ thống';
        } else if (e.toString().contains('network') || e.toString().contains('Connection')) {
          errorMessage = 'Lỗi kết nối';
          errorDetail = 'Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối mạng';
        } else if (e.toString().contains('Bản ghi chấm công chưa bị xóa')) {
          errorMessage = 'Không thể khôi phục';
          errorDetail = 'Bản ghi này chưa bị xóa nên không thể khôi phục';
        }

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 28),
                const SizedBox(width: 8),
                Text(errorMessage),
              ],
            ),
            content: Text(errorDetail),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Đóng'),
              ),
            ],
          ),
        );
      }
    }
  }

  String _getPhuongThucText(String? phuongThuc) {
    switch (phuongThuc) {
      case 'VanTay':
        return '👆 Vân tay';
      case 'KhuonMat':
        return '👤 Khuôn mặt';
      case 'NFC':
        return '📱 NFC';
      case 'ThuCong':
      default:
        return '✍️ Thủ công';
    }
  }

  Color _getPhuongThucColor(String? phuongThuc) {
    switch (phuongThuc) {
      case 'VanTay':
        return Colors.blue;
      case 'KhuonMat':
        return Colors.green;
      case 'NFC':
        return Colors.orange;
      case 'ThuCong':
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản Lý Chấm Công'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: _chonKhoangNgay,
            tooltip: 'Lọc theo ngày',
          ),
          if (_tuNgay != null || _denNgay != null || _maNVFilter != null)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _xoaBoLoc,
              tooltip: 'Xóa bộ lọc',
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDanhSach,
            tooltip: 'Làm mới',
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToThemChamCong,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        tooltip: 'Thêm chấm công',
        child: const Icon(Icons.add),
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

    final danhSachHienThi = _danhSachChamCong
        .where((cc) => _hienThiDaXoa ? cc.daXoa : !cc.daXoa)
        .toList();

    return Column(
      children: [
        if (_tuNgay != null && _denNgay != null)
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.blue.shade50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.filter_alt, size: 16, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Từ ${_dateOnlyFormat.format(_tuNgay!)} đến ${_dateOnlyFormat.format(_denNgay!)}',
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tổng: ${danhSachHienThi.length} bản ghi',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              // Chỉ admin mới thấy toggle "Hiện đã xóa"
              if (widget.currentUser?.isAdmin == true)
                TextButton.icon(
                  icon: Icon(_hienThiDaXoa ? Icons.visibility : Icons.visibility_off),
                  label: Text(_hienThiDaXoa ? 'Ẩn đã xóa' : 'Hiện đã xóa'),
                  onPressed: () {
                    setState(() {
                      _hienThiDaXoa = !_hienThiDaXoa;
                    });
                  },
                ),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadDanhSach,
            child: danhSachHienThi.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Không có bản ghi chấm công nào',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: danhSachHienThi.length,
                    itemBuilder: (context, index) {
                      final chamCong = danhSachHienThi[index];
                      return _buildChamCongCard(chamCong);
                    },
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildChamCongCard(ChamCong chamCong) {
    final thoiGianLamViec = chamCong.thoiGianLamViec;
    final isDaXoa = chamCong.daXoa;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: isDaXoa ? Colors.grey : Colors.blue,
                        foregroundColor: Colors.white,
                        child: Text(
                          chamCong.nhanVien?.hoTen?.substring(0, 1).toUpperCase() ?? '?',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              chamCong.nhanVien?.hoTen ?? 'N/A',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: isDaXoa ? Colors.grey : Colors.black,
                                decoration: isDaXoa ? TextDecoration.lineThrough : null,
                              ),
                            ),
                            Text(
                              'Mã NV: ${chamCong.maNV}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getPhuongThucColor(chamCong.phuongThuc).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getPhuongThucColor(chamCong.phuongThuc),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    _getPhuongThucText(chamCong.phuongThuc),
                    style: TextStyle(
                      fontSize: 11,
                      color: _getPhuongThucColor(chamCong.phuongThuc),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.login, size: 16, color: Colors.green[700]),
                          const SizedBox(width: 4),
                          const Text(
                            'Giờ vào:',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        chamCong.gioVao != null
                            ? _dateFormat.format(chamCong.gioVao!)
                            : 'Chưa chấm',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDaXoa ? Colors.grey : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.logout, size: 16, color: Colors.red[700]),
                          const SizedBox(width: 4),
                          const Text(
                            'Giờ ra:',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        chamCong.gioRa != null
                            ? _dateFormat.format(chamCong.gioRa!)
                            : 'Chưa chấm',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDaXoa ? Colors.grey : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (thoiGianLamViec != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.timer, size: 16, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(
                      'Thời gian làm việc: ${thoiGianLamViec.toStringAsFixed(2)} giờ',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (chamCong.ghiChu != null && chamCong.ghiChu!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.note, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      chamCong.ghiChu!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Mã CC: ${chamCong.maChamCong}',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 11,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isDaXoa) ...[
                      IconButton(
                        icon: const Icon(Icons.restore, color: Colors.green, size: 20),
                        tooltip: 'Khôi phục',
                        onPressed: () => _khoiPhucChamCong(chamCong),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_forever, color: Colors.red, size: 20),
                        tooltip: 'Xóa vĩnh viễn',
                        onPressed: () => _xoaCungChamCong(chamCong),
                      ),
                    ] else ...[
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange, size: 20),
                        tooltip: 'Sửa',
                        onPressed: () => _navigateToCapNhatChamCong(chamCong),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                        tooltip: 'Xóa',
                        onPressed: () => _xoaChamCong(chamCong),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
