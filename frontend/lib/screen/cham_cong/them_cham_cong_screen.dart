import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../model/chamcong/cham_cong.dart';
import '../../model/nhanvien/nhan_vien.dart';
import '../../services/chamcong/cham_cong_service.dart';
import '../../services/nhan_vien/nhan_vien_service.dart';

class ThemChamCongScreen extends StatefulWidget {
  const ThemChamCongScreen({super.key});

  @override
  State<ThemChamCongScreen> createState() => _ThemChamCongScreenState();
}

class _ThemChamCongScreenState extends State<ThemChamCongScreen> {
  final _formKey = GlobalKey<FormState>();
  final ChamCongService _chamCongService = ChamCongService();
  final NhanVienService _nhanVienService = NhanVienService();
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  List<NhanVien> _danhSachNhanVien = [];
  bool _isLoading = false;
  bool _isLoadingNhanVien = false;

  int? _maNV;
  DateTime? _gioVao;
  DateTime? _gioRa;
  String _phuongThuc = 'ThuCong';
  final TextEditingController _ghiChuController = TextEditingController();

  @override
  void initState() {
    super.initState();
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi tải danh sách nhân viên: ${e.toString()}'),
            backgroundColor: Colors.red,
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

  Future<void> _luuChamCong() async {
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
      final chamCong = ChamCong(
        maNV: _maNV,
        gioVao: _gioVao,
        gioRa: _gioRa,
        phuongThuc: _phuongThuc,
        ghiChu: _ghiChuController.text.trim().isEmpty ? null : _ghiChuController.text.trim(),
      );

      await _chamCongService.createChamCong(chamCong);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thêm chấm công thành công!'),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
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
        title: const Text('Thêm Chấm Công'),
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
                            const Icon(Icons.calendar_today, size: 20),
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
                            onPressed: _isLoading ? null : _luuChamCong,
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
                                  : const Text('Lưu'),
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
