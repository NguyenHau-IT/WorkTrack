import 'package:flutter/material.dart';
import '../../model/nghiphep/nghi_phep.dart';
import '../../model/nhanvien/nhan_vien.dart';
import '../../services/nghiphep/nghi_phep_service.dart';
import '../../services/nhan_vien/nhan_vien_service.dart';
import 'tao_sua_nghi_phep_screen.dart';

class QuanLyNghiPhepScreen extends StatefulWidget {
  final NhanVien manager;

  const QuanLyNghiPhepScreen({super.key, required this.manager});

  @override
  State<QuanLyNghiPhepScreen> createState() => _QuanLyNghiPhepScreenState();
}

class _QuanLyNghiPhepScreenState extends State<QuanLyNghiPhepScreen>
    with SingleTickerProviderStateMixin {
  final NghiPhepService _nghiPhepService = NghiPhepService();
  final NhanVienService _nhanVienService = NhanVienService();
  
  TabController? _tabController;
  List<NghiPhep> _danhSachNghiPhep = [];
  List<NhanVien> _danhSachNhanVien = [];
  bool _isLoading = true;
  
  String _selectedFilter = 'TATCA'; // TATCA, CHO_DUYET, DA_DUYET, TU_CHOI

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController!.addListener(_onTabChanged);
    _loadData();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController!.indexIsChanging) {
      setState(() {
        switch (_tabController!.index) {
          case 0:
            _selectedFilter = 'TATCA';
            break;
          case 1:
            _selectedFilter = 'CHO_DUYET';
            break;
          case 2:
            _selectedFilter = 'DA_DUYET';
            break;
          case 3:
            _selectedFilter = 'TU_CHOI';
            break;
        }
      });
      _loadNghiPhep();
    }
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load danh sách nhân viên
      final nhanViens = await _nhanVienService.getAllNhanVien();
      _danhSachNhanVien = nhanViens.where((nv) => !nv.daXoa).toList();

      // Load nghỉ phép
      await _loadNghiPhep();
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

  Future<void> _loadNghiPhep() async {
    try {
      List<NghiPhep> nghiPhep;
      
      if (_selectedFilter == 'TATCA') {
        nghiPhep = await _nghiPhepService.getAllNghiPhep();
      } else {
        nghiPhep = await _nghiPhepService.getNghiPhepByTrangThai(_selectedFilter);
      }
      
      setState(() {
        _danhSachNghiPhep = nghiPhep.where((np) => !np.daXoa).toList();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tải nghỉ phép: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getNhanVienName(int maNV) {
    final nhanVien = _danhSachNhanVien.firstWhere(
      (nv) => nv.maNV == maNV,
      orElse: () => NhanVien(
        maNV: maNV,
        hoTen: 'Không xác định',
        email: '',
        tenDangNhap: 'unknown',
        matKhau: '',
        dienThoai: '',
        vaiTro: null,
        daXoa: false,
      ),
    );
    return nhanVien.hoTen;
  }

  String _getLoaiNghiText(String loaiNghi) {
    switch (loaiNghi) {
      case 'PHEP_NAM':
        return 'Phép năm';
      case 'PHEP_OM':
        return 'Phép ốm';
      case 'PHEP_THAI_SAN':
        return 'Phép thai sản';
      case 'PHEP_LE':
        return 'Phép lễ';
      default:
        return loaiNghi;
    }
  }

  void _taoNghiPhep() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaoSuaNghiPhepScreen(
          manager: widget.manager,
          danhSachNhanVien: _danhSachNhanVien,
        ),
      ),
    );
    
    if (result == true) {
      await _loadNghiPhep();
    }
  }

  void _suaNghiPhep(NghiPhep nghiPhep) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaoSuaNghiPhepScreen(
          manager: widget.manager,
          danhSachNhanVien: _danhSachNhanVien,
          nghiPhep: nghiPhep,
        ),
      ),
    );
    
    if (result == true) {
      await _loadNghiPhep();
    }
  }

  void _duyetNghiPhep(NghiPhep nghiPhep) async {
    final action = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Duyệt Đơn Nghỉ Phép'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nhân viên: ${_getNhanVienName(nghiPhep.maNV)}'),
            Text('Thời gian: ${nghiPhep.tuNgay} - ${nghiPhep.denNgay}'),
            Text('Số ngày: ${nghiPhep.soNgay} ngày'),
            Text('Loại nghỉ: ${_getLoaiNghiText(nghiPhep.loaiNghi)}'),
            if (nghiPhep.lyDo?.isNotEmpty == true)
              Text('Lý do: ${nghiPhep.lyDo}'),
            SizedBox(height: 16),
            Text('Bạn muốn duyệt hay từ chối đơn này?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'TU_CHOI'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Từ Chối'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, 'DUYET'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: Text('Duyệt'),
          ),
        ],
      ),
    );

    if (action != null && action != 'HUY') {
      try {
        final updatedNghiPhep = NghiPhep(
          maNghiPhep: nghiPhep.maNghiPhep,
          maNV: nghiPhep.maNV,
          tuNgay: nghiPhep.tuNgay,
          denNgay: nghiPhep.denNgay,
          soNgay: nghiPhep.soNgay,
          loaiNghi: nghiPhep.loaiNghi,
          lyDo: nghiPhep.lyDo,
          trangThai: action == 'DUYET' ? 'DA_DUYET' : 'TU_CHOI',
          daXoa: nghiPhep.daXoa,
        );

        await _nghiPhepService.updateNghiPhep(
          nghiPhep.maNghiPhep!,
          updatedNghiPhep,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(action == 'DUYET' 
                  ? 'Đã duyệt đơn nghỉ phép'
                  : 'Đã từ chối đơn nghỉ phép'),
              backgroundColor: action == 'DUYET' ? Colors.green : Colors.orange,
            ),
          );
          await _loadNghiPhep();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi xử lý đơn: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _xoaNghiPhep(NghiPhep nghiPhep) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Xác nhận'),
        content: Text('Bạn có chắc muốn xóa đơn nghỉ phép này?'),
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

    if (confirm == true && nghiPhep.maNghiPhep != null) {
      try {
        await _nghiPhepService.deleteNghiPhep(nghiPhep.maNghiPhep!);
        await _loadNghiPhep();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã xóa đơn nghỉ phép'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi xóa đơn: ${e.toString()}'),
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
        title: Text('Quản Lý Nghỉ Phép'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadData,
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _taoNghiPhep,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: [
            Tab(text: 'Tất Cả'),
            Tab(text: 'Chờ Duyệt'),
            Tab(text: 'Đã Duyệt'),
            Tab(text: 'Từ Chối'),
          ],
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildNghiPhepList('TATCA'),
                _buildNghiPhepList('CHO_DUYET'),
                _buildNghiPhepList('DA_DUYET'),
                _buildNghiPhepList('TU_CHOI'),
              ],
            ),
    );
  }

  Widget _buildNghiPhepList(String filter) {
    final filteredList = filter == 'TATCA' 
        ? _danhSachNghiPhep
        : _danhSachNghiPhep.where((np) => np.trangThai == filter).toList();

    if (filteredList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              _getEmptyMessage(filter),
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: filteredList.length,
      itemBuilder: (context, index) {
        final nghiPhep = filteredList[index];
        final nhanVien = _getNhanVienByMa(nghiPhep.maNV);
        
        return Card(
          margin: EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getColorByTrangThai(nghiPhep.trangThai),
              child: Icon(
                _getIconByLoaiNghi(nghiPhep.loaiNghi),
                color: Colors.white,
              ),
            ),
            title: Text(
              nhanVien?.hoTen ?? 'NV #${nghiPhep.maNV}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Loại: ${nghiPhep.loaiNghiDisplay}'),
                Text('Từ: ${nghiPhep.tuNgay} đến: ${nghiPhep.denNgay}'),
                Text('Số ngày: ${nghiPhep.soNgay ?? nghiPhep.soNgayTinhToan} ngày'),
                if (nghiPhep.lyDo?.isNotEmpty == true)
                  Text(
                    'Lý do: ${nghiPhep.lyDo}',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                if (nghiPhep.ghiChuDuyet?.isNotEmpty == true)
                  Text(
                    'Ghi chú duyệt: ${nghiPhep.ghiChuDuyet}',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.red,
                    ),
                  ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getColorByTrangThai(nghiPhep.trangThai),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    nghiPhep.trangThaiDisplay,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
                PopupMenuButton(
                  itemBuilder: (context) {
                    List<PopupMenuEntry> items = [];
                    
                    if (nghiPhep.isChoDuyet) {
                      items.add(
                        PopupMenuItem(
                          value: 'approve',
                          child: Row(
                            children: [
                              Icon(Icons.check_circle, size: 16, color: Colors.green),
                              SizedBox(width: 8),
                              Text('Duyệt', style: TextStyle(color: Colors.green)),
                            ],
                          ),
                        ),
                      );
                    }
                    
                    if (nghiPhep.isChoDuyet) {
                      items.add(
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
                      );
                    }
                    
                    items.add(
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
                    );
                    
                    return items;
                  },
                  onSelected: (value) {
                    if (value == 'approve') {
                      _duyetNghiPhep(nghiPhep);
                    } else if (value == 'edit') {
                      _suaNghiPhep(nghiPhep);
                    } else if (value == 'delete') {
                      _xoaNghiPhep(nghiPhep);
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getEmptyMessage(String filter) {
    switch (filter) {
      case 'CHO_DUYET':
        return 'Không có đơn nào chờ duyệt';
      case 'DA_DUYET':
        return 'Không có đơn nào đã duyệt';
      case 'TU_CHOI':
        return 'Không có đơn nào bị từ chối';
      default:
        return 'Không có đơn nghỉ phép nào';
    }
  }

  Color _getColorByTrangThai(String trangThai) {
    switch (trangThai) {
      case 'CHO_DUYET':
        return Colors.orange;
      case 'DA_DUYET':
        return Colors.green;
      case 'TU_CHOI':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getIconByLoaiNghi(String loaiNghi) {
    switch (loaiNghi) {
      case 'PHEP_NAM':
        return Icons.beach_access;
      case 'PHEP_OM':
        return Icons.local_hospital;
      case 'PHEP_THAI_SAN':
        return Icons.pregnant_woman;
      case 'PHEP_LE':
        return Icons.celebration;
      default:
        return Icons.event;
    }
  }
}