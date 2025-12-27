import 'package:flutter/material.dart';
import '../../model/lichlamviec/lich_lam_viec.dart';
import '../../model/nhanvien/nhan_vien.dart';
import '../../services/lichlamviec/lich_lam_viec_service.dart';

class TaoSuaLichLamViecScreen extends StatefulWidget {
  final NhanVien manager;
  final List<NhanVien> danhSachNhanVien;
  final LichLamViec? lichLamViec; // null = tạo mới, có giá trị = sửa

  const TaoSuaLichLamViecScreen({
    super.key,
    required this.manager,
    required this.danhSachNhanVien,
    this.lichLamViec,
  });

  @override
  State<TaoSuaLichLamViecScreen> createState() => _TaoSuaLichLamViecScreenState();
}

class _TaoSuaLichLamViecScreenState extends State<TaoSuaLichLamViecScreen> {
  final LichLamViecService _lichLamViecService = LichLamViecService();
  final _formKey = GlobalKey<FormState>();
  
  bool _isLoading = false;
  
  // Form fields
  int? _selectedNhanVienId;
  DateTime? _ngayLamViec;
  TimeOfDay? _gioBatDau;
  TimeOfDay? _gioKetThuc;
  String _caLamViec = 'SANG';
  String _loaiCa = 'BINH_THUONG';
  String _ghiChu = '';
  String _trangThai = 'KICH_HOAT';

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() {
    if (widget.lichLamViec != null) {
      // Chế độ sửa
      final lich = widget.lichLamViec!;
      _selectedNhanVienId = lich.maNV;
      _ngayLamViec = lich.ngayLamViecAsDateTime;
      _caLamViec = lich.caLamViec ?? 'SANG';
      _loaiCa = lich.loaiCa ?? 'BINH_THUONG';
      _ghiChu = lich.ghiChu ?? '';
      _trangThai = lich.trangThai;
      
      // Parse thời gian
      if (lich.gioBatDau != null) {
        final parts = lich.gioBatDau!.split(':');
        _gioBatDau = TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }
      
      if (lich.gioKetThuc != null) {
        final parts = lich.gioKetThuc!.split(':');
        _gioKetThuc = TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }
    } else {
      // Chế độ tạo mới
      _ngayLamViec = DateTime.now();
    }
  }

  Future<void> _chonNgay() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _ngayLamViec ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    
    if (picked != null) {
      setState(() {
        _ngayLamViec = picked;
      });
    }
  }

  Future<void> _chonGioBatDau() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _gioBatDau ?? TimeOfDay(hour: 8, minute: 0),
    );
    
    if (picked != null) {
      setState(() {
        _gioBatDau = picked;
      });
    }
  }

  Future<void> _chonGioKetThuc() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _gioKetThuc ?? TimeOfDay(hour: 17, minute: 0),
    );
    
    if (picked != null) {
      setState(() {
        _gioKetThuc = picked;
      });
    }
  }

  String _formatTimeOfDay(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00';
  }

  Future<void> _luuLichLamViec() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedNhanVienId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vui lòng chọn nhân viên'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_ngayLamViec == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vui lòng chọn ngày làm việc'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final lichLamViec = LichLamViec(
        maLich: widget.lichLamViec?.maLich,
        maNV: _selectedNhanVienId!,
        ngayLamViec: _ngayLamViec!.toIso8601String().split('T')[0],
        gioBatDau: _gioBatDau != null ? _formatTimeOfDay(_gioBatDau!) : null,
        gioKetThuc: _gioKetThuc != null ? _formatTimeOfDay(_gioKetThuc!) : null,
        caLamViec: _caLamViec,
        loaiCa: _loaiCa,
        ghiChu: _ghiChu.trim().isEmpty ? null : _ghiChu.trim(),
        trangThai: _trangThai,
        nguoiTao: widget.manager.hoTen,
        daXoa: false,
      );

      if (widget.lichLamViec != null) {
        // Cập nhật
        await _lichLamViecService.updateLichLamViec(
          widget.lichLamViec!.maLich!,
          lichLamViec,
        );
      } else {
        // Tạo mới
        await _lichLamViecService.createLichLamViec(lichLamViec);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.lichLamViec != null 
                ? 'Cập nhật lịch làm việc thành công' 
                : 'Tạo lịch làm việc thành công'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi lưu dữ liệu: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lichLamViec != null ? 'Sửa Lịch Làm Việc' : 'Tạo Lịch Làm Việc'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _luuLichLamViec,
            child: Text(
              'LẮU',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Chọn nhân viên
                    Text('Nhân Viên *', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    DropdownButtonFormField<int>(
                      value: _selectedNhanVienId,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Chọn nhân viên',
                      ),
                      items: widget.danhSachNhanVien
                          .map((nv) => DropdownMenuItem(
                                value: nv.maNV,
                                child: Text('${nv.hoTen} (${nv.maNV})'),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedNhanVienId = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Vui lòng chọn nhân viên';
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: 16),

                    // Ngày làm việc
                    Text('Ngày Làm Việc *', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    InkWell(
                      onTap: _chonNgay,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today, color: Colors.grey[600]),
                            SizedBox(width: 12),
                            Text(
                              _ngayLamViec != null
                                  ? '${_ngayLamViec!.day}/${_ngayLamViec!.month}/${_ngayLamViec!.year}'
                                  : 'Chọn ngày làm việc',
                              style: TextStyle(
                                color: _ngayLamViec != null ? Colors.black : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 16),

                    // Row cho giờ bắt đầu và kết thúc
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Giờ Bắt Đầu', style: TextStyle(fontWeight: FontWeight.bold)),
                              SizedBox(height: 8),
                              InkWell(
                                onTap: _chonGioBatDau,
                                child: Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.access_time, color: Colors.grey[600]),
                                      SizedBox(width: 8),
                                      Text(
                                        _gioBatDau != null
                                            ? _gioBatDau!.format(context)
                                            : 'Chọn giờ',
                                        style: TextStyle(
                                          color: _gioBatDau != null ? Colors.black : Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Giờ Kết Thúc', style: TextStyle(fontWeight: FontWeight.bold)),
                              SizedBox(height: 8),
                              InkWell(
                                onTap: _chonGioKetThuc,
                                child: Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.access_time, color: Colors.grey[600]),
                                      SizedBox(width: 8),
                                      Text(
                                        _gioKetThuc != null
                                            ? _gioKetThuc!.format(context)
                                            : 'Chọn giờ',
                                        style: TextStyle(
                                          color: _gioKetThuc != null ? Colors.black : Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 16),

                    // Ca làm việc
                    Text('Ca Làm Việc *', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _caLamViec,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        DropdownMenuItem(value: 'SANG', child: Text('Ca Sáng')),
                        DropdownMenuItem(value: 'CHIEU', child: Text('Ca Chiều')),
                        DropdownMenuItem(value: 'TOI', child: Text('Ca Tối')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _caLamViec = value!;
                        });
                      },
                    ),

                    SizedBox(height: 16),

                    // Loại ca
                    Text('Loại Ca *', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _loaiCa,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        DropdownMenuItem(value: 'BINH_THUONG', child: Text('Bình thường')),
                        DropdownMenuItem(value: 'TANG_CA', child: Text('Tăng ca')),
                        DropdownMenuItem(value: 'LAM_THEM', child: Text('Làm thêm')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _loaiCa = value!;
                        });
                      },
                    ),

                    SizedBox(height: 16),

                    // Trạng thái
                    Text('Trạng Thái *', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _trangThai,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        DropdownMenuItem(value: 'KICH_HOAT', child: Text('Kích hoạt')),
                        DropdownMenuItem(value: 'HUY', child: Text('Hủy')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _trangThai = value!;
                        });
                      },
                    ),

                    SizedBox(height: 16),

                    // Ghi chú
                    Text('Ghi Chú', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    TextFormField(
                      initialValue: _ghiChu,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Nhập ghi chú (tùy chọn)',
                      ),
                      maxLines: 3,
                      onChanged: (value) {
                        _ghiChu = value;
                      },
                    ),

                    SizedBox(height: 32),

                    // Nút lưu
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _luuLichLamViec,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text(
                                widget.lichLamViec != null ? 'CẬP NHẬT' : 'TẠO MỚI',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}