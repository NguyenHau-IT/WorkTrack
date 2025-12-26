import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/baocao/bao_cao_service.dart';
import '../../services/nhan_vien/nhan_vien_service.dart';
import '../../services/chamcong/cham_cong_service.dart';
import '../../services/cauhinhluong/cau_hinh_luong_service.dart';
import '../../model/nhanvien/nhan_vien.dart';
import '../../model/cauhinhluong/cau_hinh_luong.dart';
import '../../model/baocao/bao_cao.dart';

// Class để lưu chi tiết tính lương từng ngày
class ChiTietNgay {
  final DateTime ngay;
  final DateTime? gioVao;
  final DateTime? gioRa;
  final double tongGio;
  final double gioLamChinh;
  final double gioLamThem;

  ChiTietNgay({
    required this.ngay,
    this.gioVao,
    this.gioRa,
    required this.tongGio,
    required this.gioLamChinh,
    required this.gioLamThem,
  });
}

class TaoBaoCaoScreen extends StatefulWidget {
  const TaoBaoCaoScreen({super.key});

  @override
  State<TaoBaoCaoScreen> createState() => _TaoBaoCaoScreenState();
}

class _TaoBaoCaoScreenState extends State<TaoBaoCaoScreen> {
  final _formKey = GlobalKey<FormState>();
  final BaoCaoService _baoCaoService = BaoCaoService();
  final NhanVienService _nhanVienService = NhanVienService();
  final ChamCongService _chamCongService = ChamCongService();
  final CauHinhLuongService _cauHinhLuongService = CauHinhLuongService();
  
  List<NhanVien> _danhSachNhanVien = [];
  NhanVien? _selectedNhanVien;
  DateTime? _tuNgay;
  DateTime? _denNgay;
  
  bool _isLoading = false;
  bool _isCalculating = false;
  
  // Kết quả tính toán
  double _tongGio = 0;
  double _gioLamChinh = 0;
  double _gioLamThem = 0;
  int _soNgayDiTre = 0;
  int _soNgayVeSom = 0;
  double _luong = 0;
  CauHinhLuong? _cauHinhLuong;
  List<ChiTietNgay> _chiTietTungNgay = []; // Chi tiết từng ngày

  @override
  void initState() {
    super.initState();
    _loadNhanVien();
    _loadCauHinhLuong();
  }

  Future<void> _loadNhanVien() async {
    setState(() => _isLoading = true);
    try {
      final danhSach = await _nhanVienService.getAllNhanVien();
      setState(() {
        _danhSachNhanVien = danhSach.where((nv) => !nv.daXoa).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải danh sách nhân viên: $e')),
        );
      }
    }
  }

  Future<void> _loadCauHinhLuong() async {
    try {
      final cauHinh = await _cauHinhLuongService.getActiveCauHinhLuong();
      setState(() => _cauHinhLuong = cauHinh);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải cấu hình lương: $e')),
        );
      }
    }
  }

  Future<void> _tinhLuong() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedNhanVien == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn nhân viên')),
      );
      return;
    }
    if (_tuNgay == null || _denNgay == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn khoảng thời gian')),
      );
      return;
    }
    if (_cauHinhLuong == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chưa có cấu hình lương')),
      );
      return;
    }

    setState(() => _isCalculating = true);

    try {
      // Gọi API backend để tính lương thay vì xử lý ở frontend
      final result = await _baoCaoService.calculateSalaryDetails(
        _selectedNhanVien!.maNV!,
        _tuNgay!,
        _denNgay!,
        _cauHinhLuong!.luongGio,
        _cauHinhLuong!.luongLamThem,
      );

      setState(() {
        _tongGio = result['tongGio']?.toDouble() ?? 0.0;
        _gioLamChinh = result['gioLamChinh']?.toDouble() ?? 0.0;
        _gioLamThem = result['gioLamThem']?.toDouble() ?? 0.0;
        _soNgayDiTre = result['soNgayDiTre']?.toInt() ?? 0;
        _soNgayVeSom = result['soNgayVeSom']?.toInt() ?? 0;
        _luong = result['tongLuong']?.toDouble() ?? 0.0;
        
        // Tạo chi tiết từng ngày từ dữ liệu backend (nếu có)
        _chiTietTungNgay = []; // Backend sẽ cung cấp chi tiết này trong tương lai
        
        _isCalculating = false;
      });
    } catch (e) {
      setState(() => _isCalculating = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tính lương: $e')),
        );
      }
    }
  }

  Future<void> _luuBaoCao() async {
    if (_selectedNhanVien == null || _tuNgay == null || _denNgay == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng tính lương trước khi lưu')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final baoCao = BaoCao(
        maNV: _selectedNhanVien!.maNV!,
        tuNgay: _tuNgay!,
        denNgay: _denNgay!,
        tongGio: _tongGio,
        soNgayDiTre: _soNgayDiTre,
        soNgayVeSom: _soNgayVeSom,
        gioLamThem: _gioLamThem,
        luong: _luong,
      );

      await _baoCaoService.createBaoCao(baoCao);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lưu báo cáo thành công!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi lưu báo cáo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tạo Báo Cáo Lương'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildNhanVienDropdown(),
                    const SizedBox(height: 16),
                    _buildDateRangePicker(),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _isCalculating ? null : _tinhLuong,
                      icon: _isCalculating
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.calculate),
                      label: Text(_isCalculating ? 'Đang tính...' : 'Tính Lương'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (_tongGio > 0) _buildKetQua(),
                    if (_chiTietTungNgay.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      _buildChiTietTungNgay(),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildNhanVienDropdown() {
    return DropdownButtonFormField<NhanVien>(
      value: _selectedNhanVien,
      decoration: const InputDecoration(
        labelText: 'Chọn nhân viên',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.person),
      ),
      isExpanded: true,
      items: _danhSachNhanVien.map((nv) {
        return DropdownMenuItem(
          value: nv,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Text('${nv.hoTen} - ${nv.email}'),
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() => _selectedNhanVien = value);
      },
      validator: (value) {
        if (value == null) return 'Vui lòng chọn nhân viên';
        return null;
      },
    );
  }

  Widget _buildDateRangePicker() {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.calendar_today),
          title: const Text('Từ ngày'),
          subtitle: Text(
            _tuNgay != null
                ? DateFormat('dd/MM/yyyy').format(_tuNgay!)
                : 'Chưa chọn',
          ),
          trailing: const Icon(Icons.arrow_drop_down),
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _tuNgay ?? DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
            );
            if (date != null) {
              setState(() => _tuNgay = date);
            }
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: Colors.grey.shade400),
          ),
        ),
        const SizedBox(height: 16),
        ListTile(
          leading: const Icon(Icons.calendar_today),
          title: const Text('Đến ngày'),
          subtitle: Text(
            _denNgay != null
                ? DateFormat('dd/MM/yyyy').format(_denNgay!)
                : 'Chưa chọn',
          ),
          trailing: const Icon(Icons.arrow_drop_down),
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _denNgay ?? DateTime.now(),
              firstDate: _tuNgay ?? DateTime(2020),
              lastDate: DateTime.now(),
            );
            if (date != null) {
              setState(() => _denNgay = date);
            }
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: Colors.grey.shade400),
          ),
        ),
      ],
    );
  }

  Widget _buildKetQua() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'KẾT QUẢ TÍNH LƯƠNG',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
              textAlign: TextAlign.center,
            ),
            const Divider(height: 24),
            _buildKetQuaRow('Tổng giờ làm việc', '${_tongGio.toStringAsFixed(2)} giờ'),
            _buildKetQuaRow('Giờ làm chính (8h/ngày)', '${_gioLamChinh.toStringAsFixed(2)} giờ'),
            _buildKetQuaRow('Giờ làm thêm', '${_gioLamThem.toStringAsFixed(2)} giờ', color: Colors.orange),
            const Divider(),
            _buildKetQuaRow('Số ngày đi trễ', '$_soNgayDiTre ngày', color: Colors.red),
            _buildKetQuaRow('Số ngày về sớm', '$_soNgayVeSom ngày', color: Colors.red),
            const Divider(),
            _buildKetQuaRow(
              'Tổng lương',
              _baoCaoService.formatCurrency(_luong),
              color: Colors.green,
              bold: true,
              large: true,
            ),
            const SizedBox(height: 16),
            if (_cauHinhLuong != null) ...[
              const Divider(),
              Text(
                'Cấu hình lương hiện tại:',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              Text(
                '• Lương giờ: ${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(_cauHinhLuong!.luongGio)}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              Text(
                '• Lương làm thêm: ${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(_cauHinhLuong!.luongLamThem)}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _luuBaoCao,
              icon: const Icon(Icons.save),
              label: const Text('Lưu Báo Cáo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKetQuaRow(String label, String value, {
    Color? color,
    bool bold = false,
    bool large = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: large ? 16 : 14,
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            flex: 1,
            child: Text(
              value,
              style: TextStyle(
                fontSize: large ? 18 : 14,
                fontWeight: bold ? FontWeight.bold : FontWeight.w500,
                color: color,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChiTietTungNgay() {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final timeFormat = DateFormat('HH:mm');

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'CHI TIẾT TỪNG NGÀY',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
              textAlign: TextAlign.center,
            ),
            const Divider(height: 24),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 16,
                horizontalMargin: 0,
                headingRowColor: MaterialStateProperty.all(Colors.grey.shade200),
                columns: const [
                  DataColumn(label: Text('Ngày', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Giờ vào', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Giờ ra', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Tổng giờ', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Giờ chính', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Giờ thêm', style: TextStyle(fontWeight: FontWeight.bold))),
                ],
                rows: _chiTietTungNgay.map((chiTiet) {
                  return DataRow(
                    cells: [
                      DataCell(Text(dateFormat.format(chiTiet.ngay))),
                      DataCell(Text(chiTiet.gioVao != null ? timeFormat.format(chiTiet.gioVao!) : '-')),
                      DataCell(Text(chiTiet.gioRa != null ? timeFormat.format(chiTiet.gioRa!) : '-')),
                      DataCell(Text('${chiTiet.tongGio.toStringAsFixed(2)}h')),
                      DataCell(Text(
                        '${chiTiet.gioLamChinh.toStringAsFixed(2)}h',
                        style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w500),
                      )),
                      DataCell(Text(
                        '${chiTiet.gioLamThem.toStringAsFixed(2)}h',
                        style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.w500),
                      )),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
