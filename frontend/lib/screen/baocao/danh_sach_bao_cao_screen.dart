import 'package:flutter/material.dart';
import '../../services/baocao/bao_cao_service.dart';
import '../../model/baocao/bao_cao.dart';
import '../../model/nhanvien/nhan_vien.dart';
import 'tao_bao_cao_screen.dart';
import 'package:intl/intl.dart';

class DanhSachBaoCaoScreen extends StatefulWidget {
  final NhanVien? currentUser;
  
  const DanhSachBaoCaoScreen({super.key, this.currentUser});

  @override
  State<DanhSachBaoCaoScreen> createState() => _DanhSachBaoCaoScreenState();
}

class _DanhSachBaoCaoScreenState extends State<DanhSachBaoCaoScreen> {
  final BaoCaoService _baoCaoService = BaoCaoService();
  List<BaoCao> _danhSachBaoCao = [];
  bool _hienThiDaXoa = false;
  bool _isLoading = false;
  String? _errorMessage;
  final _dateFormat = DateFormat('dd/MM/yyyy');

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
      final danhSach = await _baoCaoService.getAllBaoCao();
      setState(() {
        _danhSachBaoCao = danhSach;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _xoaBaoCao(BaoCao baoCao) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa báo cáo này?'),
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
        await _baoCaoService.deleteBaoCao(baoCao.maBaoCao!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Xóa báo cáo thành công!'),
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

  Future<void> _khoiPhucBaoCao(BaoCao baoCao) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận khôi phục'),
        content: const Text('Bạn có chắc chắn muốn khôi phục báo cáo này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.green),
            child: const Text('Khôi phục'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _baoCaoService.restoreBaoCao(baoCao.maBaoCao!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Khôi phục báo cáo thành công!'),
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

  Future<void> _xoaCungBaoCao(BaoCao baoCao) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red, size: 28),
            SizedBox(width: 8),
            Text('Xóa vĩnh viễn?'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bạn có chắc chắn muốn xóa VĨNH VIỄN báo cáo này?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Nhân viên: ${baoCao.tenNhanVien ?? "N/A"}'),
            Text('Mã báo cáo: ${baoCao.maBaoCao}'),
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
        await _baoCaoService.hardDeleteBaoCao(baoCao.maBaoCao!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã xóa vĩnh viễn báo cáo!'),
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
            errorDetail = 'Bạn không có quyền xóa vĩnh viễn báo cáo này';
          } else if (e.toString().contains('404')) {
            errorMessage = 'Không tìm thấy dữ liệu';
            errorDetail = 'Báo cáo không tồn tại trong hệ thống';
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
                  Expanded(
                    child: Text(errorMessage),
                  ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Báo Cáo Lương'),
        backgroundColor: Colors.purple,
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
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TaoBaoCaoScreen(),
            ),
          );
          if (result == true) {
            _loadDanhSach();
          }
        },
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        tooltip: 'Tạo báo cáo',
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

    final danhSachHienThi = _danhSachBaoCao
        .where((bc) => _hienThiDaXoa ? bc.daXoa : !bc.daXoa)
        .toList();

    return Column(
      children: [
        // Chỉ admin mới thấy toggle "Hiện đã xóa"
        if (widget.currentUser?.isAdmin == true)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
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
                          Icons.receipt_long_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Chưa có báo cáo nào',
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
                      final baoCao = danhSachHienThi[index];
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: baoCao.daXoa ? Colors.grey : Colors.purple,
                            foregroundColor: Colors.white,
                            child: const Icon(Icons.receipt),
                          ),
                          title: Text(
                            baoCao.tenNhanVien ?? 'Nhân viên #${baoCao.maNV}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: baoCao.daXoa ? Colors.grey : Colors.black,
                              decoration: baoCao.daXoa ? TextDecoration.lineThrough : null,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Text(
                                        '${_dateFormat.format(baoCao.tuNgay)} - ${_dateFormat.format(baoCao.denNgay)}',
                                        style: TextStyle(
                                          color: baoCao.daXoa ? Colors.grey : Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.access_time, size: 14, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      'Tổng giờ: ${baoCao.tongGio}h | Làm thêm: ${baoCao.gioLamThem}h',
                                      style: TextStyle(
                                        color: baoCao.daXoa ? Colors.grey : Colors.black87,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.monetization_on, size: 14, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      'Lương: ${_baoCaoService.formatCurrency(baoCao.luong)}',
                                      style: TextStyle(
                                        color: baoCao.daXoa ? Colors.grey : Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: SizedBox(
                            width: 110,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (!baoCao.daXoa) ...[
                                  IconButton(
                                    icon: const Icon(Icons.visibility, color: Colors.blue),
                                    tooltip: 'Xem chi tiết',
                                    onPressed: () {
                                      _showBaoCaoDetail(baoCao);
                                    },
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    tooltip: 'Xóa',
                                    onPressed: () => _xoaBaoCao(baoCao),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ] else ...[
                                  IconButton(
                                    icon: const Icon(Icons.restore, color: Colors.blue),
                                    tooltip: 'Khôi phục',
                                    onPressed: () => _khoiPhucBaoCao(baoCao),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_forever, color: Colors.red),
                                    tooltip: 'Xóa vĩnh viễn',
                                    onPressed: () => _xoaCungBaoCao(baoCao),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              ],
                            ),
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

  void _showBaoCaoDetail(BaoCao baoCao) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(baoCao.tenNhanVien ?? 'Nhân viên #${baoCao.maNV}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Mã báo cáo', '#${baoCao.maBaoCao}'),
              _buildDetailRow('Từ ngày', _dateFormat.format(baoCao.tuNgay)),
              _buildDetailRow('Đến ngày', _dateFormat.format(baoCao.denNgay)),
              const Divider(),
              _buildDetailRow('Tổng giờ làm', '${baoCao.tongGio} giờ'),
              _buildDetailRow('Giờ làm thêm', '${baoCao.gioLamThem} giờ'),
              const Divider(),
              _buildDetailRow('Số ngày đi trễ', '${baoCao.soNgayDiTre} ngày'),
              _buildDetailRow('Số ngày về sớm', '${baoCao.soNgayVeSom} ngày'),
              const Divider(),
              _buildDetailRow(
                'Lương',
                _baoCaoService.formatCurrency(baoCao.luong),
                valueColor: Colors.green,
                valueBold: true,
              ),
              if (baoCao.ngayTao != null)
                _buildDetailRow(
                  'Ngày tạo',
                  DateFormat('dd/MM/yyyy HH:mm').format(baoCao.ngayTao!),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor, bool valueBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: valueBold ? FontWeight.bold : FontWeight.normal,
                color: valueColor,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
