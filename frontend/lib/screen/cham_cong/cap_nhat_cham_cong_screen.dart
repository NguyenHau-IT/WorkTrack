import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../model/chamcong/cham_cong.dart';
import '../../model/nhanvien/nhan_vien.dart';
import '../../services/chamcong/cham_cong_service.dart';
import '../../services/nhan_vien/nhan_vien_service.dart';

class CapNhatChamCongScreen extends StatefulWidget {
  final ChamCong chamCong;

  const CapNhatChamCongScreen({super.key, required this.chamCong});

  @override
  State<CapNhatChamCongScreen> createState() => _CapNhatChamCongScreenState();
}

class _CapNhatChamCongScreenState extends State<CapNhatChamCongScreen> {
  final _formKey = GlobalKey<FormState>();
  final ChamCongService _chamCongService = ChamCongService();
  final NhanVienService _nhanVienService = NhanVienService();
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  List<NhanVien> _danhSachNhanVien = [];
  bool _isLoading = false;
  bool _isLoadingNhanVien = false;

  late int? _maNV;
  late DateTime? _gioVao;
  late DateTime? _gioRa;
  late String _phuongThuc;
  late TextEditingController _ghiChuController;

  @override
  void initState() {
    super.initState();
    _maNV = widget.chamCong.maNV;
    _gioVao = widget.chamCong.gioVao;
    _gioRa = widget.chamCong.gioRa;
    _phuongThuc = widget.chamCong.phuongThuc ?? 'ThuCong';
    _ghiChuController = TextEditingController(text: widget.chamCong.ghiChu);
    _loadDanhSachNhanVien();
  }

  Future<void> _loadDanhSachNhanVien() async {
    setState(() {
      _isLoadingNhanVien = true;
    });

    try {
      final danhSach = await _nhanVienService.getAllNhanVien();
      setState(() {
        _danhSachNhanVien = danhSach.where((nv) => !nv.daXoa).toList();
        _isLoadingNhanVien = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingNhanVien = false;
      });
      if (mounted) {
        String errorMessage = 'Không thể tải danh sách nhân viên';
        String errorDetail = 'Vui lòng thử lại sau';
        
        if (e.toString().contains('403')) {
          errorMessage = 'Không có quyền truy cập';
          errorDetail = 'Bạn không có quyền xem danh sách nhân viên';
        } else if (e.toString().contains('network') || e.toString().contains('Connection')) {
          errorMessage = 'Lỗi kết nối';
          errorDetail = 'Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối mạng';
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
                  _loadDanhSachNhanVien();
                },
                child: const Text('Thử lại'),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> _chonGioVao() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _gioVao ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_gioVao ?? DateTime.now()),
      );

      if (time != null) {
        setState(() {
          _gioVao = DateTime(date.year, date.month, date.day, time.hour, time.minute);
        });
      }
    }
  }

  Future<void> _chonGioRa() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _gioRa ?? _gioVao ?? DateTime.now(),
      firstDate: _gioVao ?? DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_gioRa ?? DateTime.now()),
      );

      if (time != null) {
        setState(() {
          _gioRa = DateTime(date.year, date.month, date.day, time.hour, time.minute);
        });
      }
    }
  }

  Future<void> _capNhatChamCong() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_maNV == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn nhân viên'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_gioVao == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn giờ vào'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_gioRa != null && _gioRa!.isBefore(_gioVao!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Giờ ra phải sau giờ vào'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final chamCongCapNhat = ChamCong(
        maChamCong: widget.chamCong.maChamCong,
        maNV: _maNV,
        gioVao: _gioVao,
        gioRa: _gioRa,
        phuongThuc: _phuongThuc,
        ghiChu: _ghiChuController.text.trim().isEmpty ? null : _ghiChuController.text.trim(),
        daXoa: widget.chamCong.daXoa,
      );

      await _chamCongService.updateChamCong(widget.chamCong.maChamCong!, chamCongCapNhat);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cập nhật chấm công thành công!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        String errorMessage = 'Không thể cập nhật chấm công';
        String errorDetail = 'Vui lòng thử lại sau';
        
        if (e.toString().contains('403')) {
          errorMessage = 'Không có quyền truy cập';
          errorDetail = 'Bạn không có quyền cập nhật chấm công';
        } else if (e.toString().contains('404')) {
          errorMessage = 'Không tìm thấy dữ liệu';
          errorDetail = 'Bản ghi chấm công không tồn tại hoặc đã bị xóa';
        } else if (e.toString().contains('Giờ ra phải sau giờ vào')) {
          errorMessage = 'Thời gian không hợp lệ';
          errorDetail = 'Giờ ra phải sau giờ vào. Vui lòng kiểm tra lại';
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

  @override
  void dispose() {
    _ghiChuController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cập Nhật Chấm Công'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _isLoadingNhanVien
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, color: Colors.blue),
                          const SizedBox(width: 8),
                          Text(
                            'Mã chấm công: ${widget.chamCong.maChamCong}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Thông tin chấm công',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                        labelText: 'Nhân viên *',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                      value: _maNV,
                      items: _danhSachNhanVien.map((nv) {
                        return DropdownMenuItem<int>(
                          value: nv.maNV,
                          child: Text('${nv.hoTen} (Mã: ${nv.maNV})'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _maNV = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Vui lòng chọn nhân viên';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: _chonGioVao,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Giờ vào *',
                          prefixIcon: Icon(Icons.login),
                          border: OutlineInputBorder(),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _gioVao != null
                                  ? _dateFormat.format(_gioVao!)
                                  : 'Chọn giờ vào',
                              style: TextStyle(
                                color: _gioVao != null ? Colors.black : Colors.grey,
                              ),
                            ),
                            const Icon(Icons.calendar_today, size: 20),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: _chonGioRa,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Giờ ra',
                          prefixIcon: Icon(Icons.logout),
                          border: OutlineInputBorder(),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _gioRa != null
                                  ? _dateFormat.format(_gioRa!)
                                  : 'Chọn giờ ra (tùy chọn)',
                              style: TextStyle(
                                color: _gioRa != null ? Colors.black : Colors.grey,
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (_gioRa != null)
                                  IconButton(
                                    icon: const Icon(Icons.clear, size: 20, color: Colors.red),
                                    onPressed: () {
                                      setState(() {
                                        _gioRa = null;
                                      });
                                    },
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                const SizedBox(width: 8),
                                const Icon(Icons.calendar_today, size: 20),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Phương thức *',
                        prefixIcon: Icon(Icons.fingerprint),
                        border: OutlineInputBorder(),
                      ),
                      value: _phuongThuc,
                      items: const [
                        DropdownMenuItem(value: 'ThuCong', child: Text('✍️ Thủ công')),
                        DropdownMenuItem(value: 'VanTay', child: Text('👆 Vân tay')),
                        DropdownMenuItem(value: 'KhuonMat', child: Text('👤 Khuôn mặt')),
                        DropdownMenuItem(value: 'NFC', child: Text('📱 NFC')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _phuongThuc = value ?? 'ThuCong';
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _ghiChuController,
                      decoration: const InputDecoration(
                        labelText: 'Ghi chú',
                        prefixIcon: Icon(Icons.note),
                        border: OutlineInputBorder(),
                        hintText: 'Nhập ghi chú (tùy chọn)',
                      ),
                      maxLines: 3,
                      maxLength: 255,
                    ),
                    if (_gioVao != null && _gioRa != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.timer, color: Colors.blue),
                            const SizedBox(width: 8),
                            Text(
                              'Thời gian làm việc: ${(_gioRa!.difference(_gioVao!).inMinutes / 60.0).toStringAsFixed(2)} giờ',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _isLoading
                                ? null
                                : () => Navigator.pop(context),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Text('Hủy'),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _capNhatChamCong,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : const Text('Cập nhật'),
                            ),
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
}
