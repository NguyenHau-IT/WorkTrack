import 'package:flutter/material.dart';
import '../../services/baocao/bao_cao_service.dart';
import '../../model/baocao/bao_cao.dart';
import '../../model/nhanvien/nhan_vien.dart';
import 'package:intl/intl.dart';

class EmployeeBaoCaoScreen extends StatefulWidget {
  final NhanVien employee;

  const EmployeeBaoCaoScreen({super.key, required this.employee});

  @override
  State<EmployeeBaoCaoScreen> createState() => _EmployeeBaoCaoScreenState();
}

class _EmployeeBaoCaoScreenState extends State<EmployeeBaoCaoScreen> {
  final BaoCaoService _baoCaoService = BaoCaoService();
  List<BaoCao> _danhSachBaoCao = [];
  bool _isLoading = false;
  String? _errorMessage;
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _loadBaoCao();
  }

  Future<void> _loadBaoCao() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Lấy tất cả báo cáo và filter theo mã nhân viên
      final allBaoCao = await _baoCaoService.getAllBaoCao();
      final employeeBaoCao = allBaoCao
          .where((bc) => bc.maNV == widget.employee.maNV && !bc.daXoa)
          .toList();
      
      // Sắp xếp theo ngày tạo mới nhất
      employeeBaoCao.sort((a, b) => b.denNgay.compareTo(a.denNgay));

      setState(() {
        _danhSachBaoCao = employeeBaoCao;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi khi tải dữ liệu: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Báo cáo lương của tôi'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadBaoCao,
            tooltip: 'Làm mới',
          ),
        ],
      ),
      body: _buildBody(),
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
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadBaoCao,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (_danhSachBaoCao.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Chưa có báo cáo lương nào',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Báo cáo lương sẽ được tạo sau khi bạn có dữ liệu chấm công',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBaoCao,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _danhSachBaoCao.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final baoCao = _danhSachBaoCao[index];
          return _buildBaoCaoCard(baoCao);
        },
      ),
    );
  }

  Widget _buildBaoCaoCard(BaoCao baoCao) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showBaoCaoDetail(baoCao),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.calendar_month,
                    color: Colors.green.shade600,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Từ ${_dateFormat.format(baoCao.tuNgay)} - ${_dateFormat.format(baoCao.denNgay)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Hoàn thành',
                      style: TextStyle(
                        color: Colors.green.shade800,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildInfoRow(
                icon: Icons.access_time,
                label: 'Tổng giờ làm việc',
                value: '${baoCao.tongGio.toStringAsFixed(1)} giờ',
                color: Colors.blue,
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                icon: Icons.schedule,
                label: 'Giờ làm thêm',
                value: '${baoCao.gioLamThem.toStringAsFixed(1)} giờ',
                color: Colors.orange,
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                icon: Icons.monetization_on,
                label: 'Tổng lương',
                value: _formatCurrency(baoCao.luong.toDouble()),
                color: Colors.green,
                isHighlight: true,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Nhấn để xem chi tiết',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    bool isHighlight = false,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isHighlight ? 16 : 14,
            fontWeight: isHighlight ? FontWeight.bold : FontWeight.w500,
            color: isHighlight ? color : Colors.black87,
          ),
        ),
      ],
    );
  }

  void _showBaoCaoDetail(BaoCao baoCao) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Chi tiết báo cáo từ ${_dateFormat.format(baoCao.tuNgay)} - ${_dateFormat.format(baoCao.denNgay)}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Tổng giờ làm việc:', '${baoCao.tongGio.toStringAsFixed(1)} giờ'),
                _buildDetailRow('Giờ làm thêm:', '${baoCao.gioLamThem.toStringAsFixed(1)} giờ'),
                _buildDetailRow('Số ngày đi trễ:', '${baoCao.soNgayDiTre} ngày'),
                _buildDetailRow('Số ngày về sớm:', '${baoCao.soNgayVeSom} ngày'),
                const Divider(),
                _buildDetailRow('Tổng lương:', _formatCurrency(baoCao.luong), isHighlight: true),
                const SizedBox(height: 8),
                if (baoCao.ngayTao != null)
                  Text(
                    'Ngày tạo: ${_dateFormat.format(baoCao.ngayTao!)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Đóng'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
              color: isHighlight ? Colors.green.shade700 : null,
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    return formatter.format(amount);
  }
}