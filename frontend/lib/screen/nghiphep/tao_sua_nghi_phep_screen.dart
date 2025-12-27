import 'package:flutter/material.dart';
import '../../model/nghiphep/nghi_phep.dart';
import '../../model/nhanvien/nhan_vien.dart';
import '../../services/nghiphep/nghi_phep_service.dart';

class TaoSuaNghiPhepScreen extends StatefulWidget {
  final NhanVien manager;
  final List<NhanVien> danhSachNhanVien;
  final NghiPhep? nghiPhep; // null = tạo mới, có giá trị = sửa

  const TaoSuaNghiPhepScreen({
    super.key,
    required this.manager,
    required this.danhSachNhanVien,
    this.nghiPhep,
  });

  @override
  State<TaoSuaNghiPhepScreen> createState() => _TaoSuaNghiPhepScreenState();
}

class _TaoSuaNghiPhepScreenState extends State<TaoSuaNghiPhepScreen> {
  final NghiPhepService _nghiPhepService = NghiPhepService();
  final _formKey = GlobalKey<FormState>();
  
  bool _isLoading = false;
  
  // Form fields
  int? _selectedNhanVienId;
  DateTime? _tuNgay;
  DateTime? _denNgay;
  String _loaiNghi = 'PHEP_NAM';
  String _lyDo = '';

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() {
    if (widget.nghiPhep != null) {
      // Chế độ sửa
      final nghiPhep = widget.nghiPhep!;
      _selectedNhanVienId = nghiPhep.maNV;
      _tuNgay = nghiPhep.tuNgayAsDateTime;
      _denNgay = nghiPhep.denNgayAsDateTime;
      _loaiNghi = nghiPhep.loaiNghi;
      _lyDo = nghiPhep.lyDo ?? '';
    } else {
      // Chế độ tạo mới
      _tuNgay = DateTime.now();
      _denNgay = DateTime.now();
    }
  }

  Future<void> _chonTuNgay() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _tuNgay ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    
    if (picked != null) {
      setState(() {
        _tuNgay = picked;
        // Nếu đến ngày nhỏ hơn từ ngày thì reset đến ngày
        if (_denNgay != null && _denNgay!.isBefore(picked)) {
          _denNgay = picked;
        }
      });
    }
  }

  Future<void> _chonDenNgay() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _denNgay ?? DateTime.now(),
      firstDate: _tuNgay ?? DateTime.now(),
      lastDate: DateTime(2030),
    );
    
    if (picked != null) {
      setState(() {
        _denNgay = picked;
      });
    }
  }

  int _tinhSoNgay() {
    if (_tuNgay != null && _denNgay != null) {
      return _denNgay!.difference(_tuNgay!).inDays + 1;
    }
    return 0;
  }

  Future<void> _luuNghiPhep() async {
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

    if (_tuNgay == null || _denNgay == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vui lòng chọn ngày nghỉ'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final nghiPhep = NghiPhep(
        maNghiPhep: widget.nghiPhep?.maNghiPhep,
        maNV: _selectedNhanVienId!,
        tuNgay: _tuNgay!.toIso8601String().split('T')[0],
        denNgay: _denNgay!.toIso8601String().split('T')[0],
        soNgay: _tinhSoNgay(),
        loaiNghi: _loaiNghi,
        lyDo: _lyDo.trim().isEmpty ? null : _lyDo.trim(),
        trangThai: 'CHO_DUYET',
        daXoa: false,
      );

      if (widget.nghiPhep != null) {
        // Cập nhật
        await _nghiPhepService.updateNghiPhep(
          widget.nghiPhep!.maNghiPhep!,
          nghiPhep,
        );
      } else {
        // Tạo mới
        await _nghiPhepService.createNghiPhep(nghiPhep);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.nghiPhep != null 
                ? 'Cập nhật đơn nghỉ phép thành công' 
                : 'Tạo đơn nghỉ phép thành công'),
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
        title: Text(widget.nghiPhep != null ? 'Sửa Đơn Nghỉ Phép' : 'Tạo Đơn Nghỉ Phép'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _luuNghiPhep,
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
                      onChanged: widget.nghiPhep != null ? null : (value) {
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

                    // Loại nghỉ
                    Text('Loại Nghỉ *', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _loaiNghi,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        DropdownMenuItem(value: 'PHEP_NAM', child: Text('Phép năm')),
                        DropdownMenuItem(value: 'PHEP_OM', child: Text('Phép ốm')),
                        DropdownMenuItem(value: 'PHEP_THAI_SAN', child: Text('Phép thai sản')),
                        DropdownMenuItem(value: 'PHEP_LE', child: Text('Phép lễ')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _loaiNghi = value!;
                        });
                      },
                    ),

                    SizedBox(height: 16),

                    // Row cho từ ngày và đến ngày
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Từ Ngày *', style: TextStyle(fontWeight: FontWeight.bold)),
                              SizedBox(height: 8),
                              InkWell(
                                onTap: _chonTuNgay,
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
                                      SizedBox(width: 8),
                                      Text(
                                        _tuNgay != null
                                            ? '${_tuNgay!.day}/${_tuNgay!.month}/${_tuNgay!.year}'
                                            : 'Chọn ngày',
                                        style: TextStyle(
                                          color: _tuNgay != null ? Colors.black : Colors.grey[600],
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
                              Text('Đến Ngày *', style: TextStyle(fontWeight: FontWeight.bold)),
                              SizedBox(height: 8),
                              InkWell(
                                onTap: _chonDenNgay,
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
                                      SizedBox(width: 8),
                                      Text(
                                        _denNgay != null
                                            ? '${_denNgay!.day}/${_denNgay!.month}/${_denNgay!.year}'
                                            : 'Chọn ngày',
                                        style: TextStyle(
                                          color: _denNgay != null ? Colors.black : Colors.grey[600],
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

                    // Hiển thị số ngày nghỉ
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        border: Border.all(color: Colors.blue[200]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue[700]),
                          SizedBox(width: 8),
                          Text(
                            'Số ngày nghỉ: ${_tinhSoNgay()} ngày',
                            style: TextStyle(
                              color: Colors.blue[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 16),

                    // Lý do
                    Text('Lý Do', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    TextFormField(
                      initialValue: _lyDo,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Nhập lý do nghỉ phép (tùy chọn)',
                      ),
                      maxLines: 3,
                      onChanged: (value) {
                        _lyDo = value;
                      },
                    ),

                    SizedBox(height: 32),

                    // Nút lưu
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _luuNghiPhep,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text(
                                widget.nghiPhep != null ? 'CẬP NHẬT' : 'TẠO MỚI',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),

                    SizedBox(height: 16),

                    // Ghi chú cho admin/manager
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.yellow[50],
                        border: Border.all(color: Colors.orange[200]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.warning_amber, color: Colors.orange[700], size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Lưu ý:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange[700],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            '• Đơn nghỉ phép sẽ có trạng thái "Chờ duyệt" sau khi tạo\n'
                            '• Cần duyệt đơn để có hiệu lực\n'
                            '• Chỉ có thể sửa đơn khi đang ở trạng thái "Chờ duyệt"',
                            style: TextStyle(
                              color: Colors.orange[700],
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}