import 'package:flutter/material.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import '../../model/nhanvien/nhan_vien.dart';
import '../../services/nfc/nfc_service.dart';
import '../../services/nhan_vien/nhan_vien_service.dart';

class GhiNFCScreen extends StatefulWidget {
  const GhiNFCScreen({super.key});

  @override
  State<GhiNFCScreen> createState() => _GhiNFCScreenState();
}

class _GhiNFCScreenState extends State<GhiNFCScreen> {
  final NFCService _nfcService = NFCService();
  final NhanVienService _nhanVienService = NhanVienService();
  
  List<NhanVien> _danhSachNhanVien = [];
  NhanVien? _nhanVienDuocChon;
  bool _isLoading = false;
  bool _isLoadingNhanVien = false;
  bool _isNFCAvailable = false;
  String _statusMessage = 'Kiểm tra NFC...';

  @override
  void initState() {
    super.initState();
    _checkNFC();
    _loadDanhSachNhanVien();
  }

  Future<void> _checkNFC() async {
    try {
      NFCAvailability availability = await _nfcService.checkNFCAvailability();
      setState(() {
        _isNFCAvailable = availability == NFCAvailability.available;
        if (_isNFCAvailable) {
          _statusMessage = 'NFC sẵn sàng';
        } else if (availability == NFCAvailability.not_supported) {
          _statusMessage = 'Thiết bị không hỗ trợ NFC';
        } else {
          _statusMessage = 'NFC chưa được bật';
        }
      });
    } catch (e) {
      setState(() {
        _isNFCAvailable = false;
        _statusMessage = 'Lỗi kiểm tra NFC: ${e.toString()}';
      });
    }
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
            content: Text('Lỗi tải danh sách nhân viên: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _ghiTheNFC() async {
    if (_nhanVienDuocChon == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn nhân viên'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (!_isNFCAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_statusMessage),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = 'Đang chuẩn bị ghi thẻ...';
    });

    try {
      setState(() {
        _statusMessage = 'Đưa thẻ NFC gần thiết bị...';
      });

      bool success = await _nfcService.writeNFC(
        maNV: _nhanVienDuocChon!.maNV!,
        hoTen: _nhanVienDuocChon!.hoTen,
        additionalData: {
          'email': _nhanVienDuocChon!.email,
          'dienThoai': _nhanVienDuocChon!.dienThoai,
        },
      );

      if (success && mounted) {
        setState(() {
          _statusMessage = 'Ghi thẻ thành công!';
        });

        // Cập nhật theNFC cho nhân viên (nếu cần)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Đã ghi thẻ NFC cho ${_nhanVienDuocChon!.hoTen} thành công!',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );

        // Reset
        setState(() {
          _nhanVienDuocChon = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _statusMessage = 'Lỗi: ${e.toString()}';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi ghi thẻ: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ghi Thẻ NFC'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Trạng thái NFC
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(
                      _isNFCAvailable ? Icons.nfc : Icons.nfc_outlined,
                      size: 64,
                      color: _isNFCAvailable ? Colors.green : Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _statusMessage,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: _isNFCAvailable ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (!_isNFCAvailable) ...[
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _checkNFC,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Kiểm tra lại'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Chọn nhân viên
            Text(
              'Chọn nhân viên để ghi thẻ:',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            if (_isLoadingNhanVien)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_danhSachNhanVien.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text('Không có nhân viên nào'),
                ),
              )
            else
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: DropdownButtonFormField<NhanVien>(
                    value: _nhanVienDuocChon,
                    decoration: const InputDecoration(
                      labelText: 'Nhân viên',
                      border: InputBorder.none,
                    ),
                    hint: const Text('-- Chọn nhân viên --'),
                    items: _danhSachNhanVien.map((nv) {
                      return DropdownMenuItem<NhanVien>(
                        value: nv,
                        child: Text(
                          '${nv.maNV} - ${nv.hoTen}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: _isLoading ? null : (value) {
                      setState(() {
                        _nhanVienDuocChon = value;
                      });
                    },
                  ),
                ),
              ),

            // Thông tin nhân viên được chọn
            if (_nhanVienDuocChon != null) ...[
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Thông tin sẽ ghi vào thẻ:',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(),
                      _buildInfoRow('Mã NV:', '${_nhanVienDuocChon!.maNV}'),
                      _buildInfoRow('Họ tên:', _nhanVienDuocChon!.hoTen),
                      _buildInfoRow('Email:', _nhanVienDuocChon!.email),
                      if (_nhanVienDuocChon!.dienThoai != null)
                        _buildInfoRow('Điện thoại:', _nhanVienDuocChon!.dienThoai!),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 32),

            // Nút ghi thẻ
            ElevatedButton.icon(
              onPressed: (_isLoading || !_isNFCAvailable) ? null : _ghiTheNFC,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.nfc),
              label: Text(
                _isLoading ? 'Đang ghi thẻ...' : 'Ghi Thẻ NFC',
                style: const TextStyle(fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Hướng dẫn
            Card(
              elevation: 1,
              color: Colors.amber.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.amber.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Hướng dẫn:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.amber.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text('1. Chọn nhân viên cần ghi thẻ'),
                    const Text('2. Nhấn nút "Ghi Thẻ NFC"'),
                    const Text('3. Đưa thẻ NFC gần mặt sau thiết bị'),
                    const Text('4. Giữ nguyên cho đến khi có thông báo thành công'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
