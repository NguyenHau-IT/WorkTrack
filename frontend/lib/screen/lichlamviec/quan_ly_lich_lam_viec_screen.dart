import 'package:flutter/material.dart';
import '../../model/lichlamviec/lich_lam_viec.dart';
import '../../model/nhanvien/nhan_vien.dart';
import '../../services/lichlamviec/lich_lam_viec_service.dart';
import '../../services/nhan_vien/nhan_vien_service.dart';
import 'tao_sua_lich_lam_viec_screen.dart';

class QuanLyLichLamViecScreen extends StatefulWidget {
  final NhanVien manager;

  const QuanLyLichLamViecScreen({super.key, required this.manager});

  @override
  State<QuanLyLichLamViecScreen> createState() => _QuanLyLichLamViecScreenState();
}

class _QuanLyLichLamViecScreenState extends State<QuanLyLichLamViecScreen> {
  final LichLamViecService _lichLamViecService = LichLamViecService();
  final NhanVienService _nhanVienService = NhanVienService();
  
  List<LichLamViec> _danhSachLich = [];
  List<NhanVien> _danhSachNhanVien = [];
  bool _isLoading = true;
  
  DateTime _selectedDate = DateTime.now();
  String _selectedFilter = 'TATCA'; // TATCA, NHANVIEN

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load danh sách nhân viên
      final nhanViens = await _nhanVienService.getAllNhanVien();
      _danhSachNhanVien = nhanViens.where((nv) => !nv.daXoa).toList();

      // Load lịch làm việc theo ngày đã chọn
      await _loadLichLamViec();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tải dữ liệu: ${e.toString()}'),
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

  Future<void> _loadLichLamViec() async {
    try {
      List<LichLamViec> lichLamViec;
      
      if (_selectedFilter == 'TATCA') {
        lichLamViec = await _lichLamViecService.getLichLamViecByNgay(_selectedDate);
      } else {
        // Filter theo nhân viên cụ thể nếu cần
        lichLamViec = await _lichLamViecService.getLichLamViecByNgay(_selectedDate);
      }
      
      setState(() {
        _danhSachLich = lichLamViec;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tải lịch làm việc: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _chonNgay() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      await _loadLichLamViec();
    }
  }

  void _taoLichLamViec() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaoSuaLichLamViecScreen(
          manager: widget.manager,
          danhSachNhanVien: _danhSachNhanVien,
        ),
      ),
    );
    
    if (result == true) {
      await _loadLichLamViec();
    }
  }

  void _suaLichLamViec(LichLamViec lichLamViec) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaoSuaLichLamViecScreen(
          manager: widget.manager,
          danhSachNhanVien: _danhSachNhanVien,
          lichLamViec: lichLamViec,
        ),
      ),
    );
    
    if (result == true) {
      await _loadLichLamViec();
    }
  }

  void _xoaLichLamViec(LichLamViec lichLamViec) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Xác nhận'),
        content: Text('Bạn có chắc muốn xóa lịch làm việc này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true && lichLamViec.maLich != null) {
      try {
        await _lichLamViecService.deleteLichLamViec(lichLamViec.maLich!);
        await _loadLichLamViec();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã xóa lịch làm việc'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi xóa lịch: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  NhanVien? _getNhanVienByMa(int maNV) {
    try {
      return _danhSachNhanVien.firstWhere((nv) => nv.maNV == maNV);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quản Lý Lịch Làm Việc'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Header với filter
                Container(
                  padding: EdgeInsets.all(16),
                  color: Colors.grey[100],
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: _chonNgay,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.calendar_today, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: _taoLichLamViec,
                        icon: Icon(Icons.add),
                        label: Text('Tạo Lịch'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Danh sách lịch làm việc
                Expanded(
                  child: _danhSachLich.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.schedule, size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text(
                                'Không có lịch làm việc nào',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.all(16),
                          itemCount: _danhSachLich.length,
                          itemBuilder: (context, index) {
                            final lich = _danhSachLich[index];
                            final nhanVien = _getNhanVienByMa(lich.maNV);
                            
                            return Card(
                              margin: EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: _getColorByCa(lich.caLamViec),
                                  child: Icon(
                                    Icons.work,
                                    color: Colors.white,
                                  ),
                                ),
                                title: Text(
                                  nhanVien?.hoTen ?? 'NV #${lich.maNV}',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Ca: ${lich.caLamViecDisplay}'),
                                    if (lich.gioBatDau != null && lich.gioKetThuc != null)
                                      Text('Giờ: ${lich.gioBatDau} - ${lich.gioKetThuc}'),
                                    Text('Loại: ${lich.loaiCaDisplay}'),
                                    if (lich.ghiChu?.isNotEmpty == true)
                                      Text(
                                        'Ghi chú: ${lich.ghiChu}',
                                        style: TextStyle(fontStyle: FontStyle.italic),
                                      ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: lich.trangThai == 'KICH_HOAT' 
                                            ? Colors.green 
                                            : Colors.red,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        lich.trangThaiDisplay,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    PopupMenuButton(
                                      itemBuilder: (context) => [
                                        PopupMenuItem(
                                          value: 'edit',
                                          child: Row(
                                            children: [
                                              Icon(Icons.edit, size: 16),
                                              SizedBox(width: 8),
                                              Text('Sửa'),
                                            ],
                                          ),
                                        ),
                                        PopupMenuItem(
                                          value: 'delete',
                                          child: Row(
                                            children: [
                                              Icon(Icons.delete, size: 16, color: Colors.red),
                                              SizedBox(width: 8),
                                              Text('Xóa', style: TextStyle(color: Colors.red)),
                                            ],
                                          ),
                                        ),
                                      ],
                                      onSelected: (value) {
                                        if (value == 'edit') {
                                          _suaLichLamViec(lich);
                                        } else if (value == 'delete') {
                                          _xoaLichLamViec(lich);
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Color _getColorByCa(String? caLamViec) {
    switch (caLamViec) {
      case 'SANG':
        return Colors.orange;
      case 'CHIEU':
        return Colors.blue;
      case 'TOI':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }
}