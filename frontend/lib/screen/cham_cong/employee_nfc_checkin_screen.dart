import 'package:flutter/material.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:intl/intl.dart';
import '../../model/chamcong/cham_cong.dart';
import '../../model/nhanvien/nhan_vien.dart';
import '../../services/nfc/nfc_service.dart';
import '../../services/chamcong/cham_cong_service.dart';

class EmployeeNFCCheckinScreen extends StatefulWidget {
  final NhanVien employee;

  const EmployeeNFCCheckinScreen({super.key, required this.employee});

  @override
  State<EmployeeNFCCheckinScreen> createState() => _EmployeeNFCCheckinScreenState();
}

class _EmployeeNFCCheckinScreenState extends State<EmployeeNFCCheckinScreen> {
  final NFCService _nfcService = NFCService();
  final ChamCongService _chamCongService = ChamCongService();
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy HH:mm:ss');

  bool _isScanning = false;
  bool _isNFCAvailable = false;
  String _statusMessage = 'Kiểm tra NFC...';
  ChamCong? _lastChamCong;
  ChamCong? _currentCheckin;

  @override
  void initState() {
    super.initState();
    _checkNFC();
    _loadCurrentCheckin();
  }

  Future<void> _checkNFC() async {
    try {
      NFCAvailability availability = await _nfcService.checkNFCAvailability();
      setState(() {
        _isNFCAvailable = availability == NFCAvailability.available;
        if (_isNFCAvailable) {
          _statusMessage = 'NFC sẵn sàng. Đưa thẻ gần thiết bị để chấm công';
        } else if (availability == NFCAvailability.not_supported) {
          _statusMessage = 'Thiết bị không hỗ trợ NFC';
        } else {
          _statusMessage = 'NFC chưa được bật. Vui lòng bật NFC trong cài đặt';
        }
      });
    } catch (e) {
      setState(() {
        _isNFCAvailable = false;
        _statusMessage = 'Lỗi kiểm tra NFC: ${e.toString()}';
      });
    }
  }

  Future<void> _loadCurrentCheckin() async {
    try {
      ChamCong? current = await _chamCongService.getChamCongHienTai(widget.employee.maNV!);
      setState(() {
        _currentCheckin = current;
      });
    } catch (e) {
      print('Lỗi tải thông tin chấm công: $e');
    }
  }

  Future<void> _scanNFC() async {
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
      _isScanning = true;
      _statusMessage = 'Đưa thẻ NFC gần thiết bị...';
    });

    try {
      // Đọc thẻ NFC
      Map<String, dynamic>? data = await _nfcService.readNFC();

      if (data != null && mounted) {
        // Kiểm tra thẻ có phải của nhân viên này không
        if (data.containsKey('maNV')) {
          int maNV = data['maNV'];
          
          if (maNV != widget.employee.maNV) {
            setState(() {
              _statusMessage = 'Thẻ này không phải của bạn!';
            });
            
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Thẻ NFC này không phải của bạn. Vui lòng sử dụng thẻ của chính mình.'),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 4),
              ),
            );
            return;
          }
          
          await _processCheckin();
        } else {
          setState(() {
            _statusMessage = 'Thẻ không chứa thông tin nhân viên hợp lệ';
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Thẻ không chứa mã nhân viên. Vui lòng liên hệ admin để ghi lại thẻ.'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 4),
            ),
          );
        }
      } else {
        setState(() {
          _statusMessage = 'Không đọc được dữ liệu từ thẻ';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _statusMessage = 'Lỗi: ${e.toString()}';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi đọc thẻ: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
      }
    }
  }

  Future<void> _processCheckin() async {
    try {
      ChamCong result;
      String message;
      Color bgColor;

      if (_currentCheckin == null) {
        // Chưa chấm công vào => Chấm công vào
        result = await _chamCongService.chamCongVao(widget.employee.maNV!, phuongThuc: 'NFC');
        message = 'Chấm công VÀO thành công!';
        bgColor = Colors.green;
      } else {
        // Đã chấm công vào => Chấm công ra
        
        // Kiểm tra thời gian làm việc
        final gioVao = _currentCheckin!.gioVao!;
        final gioHienTai = DateTime.now();
        final thoiGianLamViec = gioHienTai.difference(gioVao).inMinutes;

        // Nếu chưa đủ thời gian làm việc, hỏi xác nhận
        if (thoiGianLamViec < 30) {
          bool confirm = await _showConfirmDialog(thoiGianLamViec);
          if (!confirm) {
            setState(() {
              _statusMessage = 'Đã hủy chấm công ra';
            });
            
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Đã hủy chấm công ra'),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 2),
              ),
            );
            return;
          }
        }
        
        result = await _chamCongService.chamCongRa(widget.employee.maNV!);
        message = 'Chấm công RA thành công!';
        bgColor = Colors.blue;
      }

      if (mounted) {
        setState(() {
          _lastChamCong = result;
          _currentCheckin = _currentCheckin == null ? result : null;
          _statusMessage = message;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: bgColor,
            duration: const Duration(seconds: 2),
          ),
        );

        // Tự động quay về sau 3 giây
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            Navigator.pop(context);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _statusMessage = 'Lỗi chấm công: ${e.toString()}';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi xử lý chấm công: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Future<bool> _showConfirmDialog(int thoiGianLamViec) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange),
              SizedBox(width: 8),
              Expanded(
                child: Text('Xác nhận chấm công ra'),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Bạn chỉ làm việc được:'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Text(
                  '$thoiGianLamViec phút',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade700,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text('Bạn có chắc chắn muốn chấm công ra không?'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Xác nhận'),
            ),
          ],
        );
      },
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chấm Công NFC'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _checkNFC();
              _loadCurrentCheckin();
            },
            tooltip: 'Làm mới',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Thông tin nhân viên
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.teal.shade700,
                      child: Text(
                        widget.employee.hoTen.isNotEmpty ? widget.employee.hoTen.substring(0, 1).toUpperCase() : '?',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.employee.hoTen,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Mã NV: ${widget.employee.maNV}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),

            // Trạng thái hiện tại
            Card(
              elevation: 2,
              color: _currentCheckin != null ? Colors.green.shade50 : Colors.grey.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(
                      _currentCheckin != null ? Icons.work : Icons.work_off,
                      size: 48,
                      color: _currentCheckin != null ? Colors.green : Colors.grey,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _currentCheckin != null ? 'Đã chấm công vào' : 'Chưa chấm công',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _currentCheckin != null ? Colors.green.shade700 : Colors.grey.shade700,
                      ),
                    ),
                    if (_currentCheckin != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Vào lúc: ${_dateFormat.format(_currentCheckin!.gioVao!)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Trạng thái NFC
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(
                      _isScanning 
                          ? Icons.nfc 
                          : (_isNFCAvailable ? Icons.nfc : Icons.nfc_outlined),
                      size: 64,
                      color: _isScanning 
                          ? Colors.orange 
                          : (_isNFCAvailable ? Colors.teal : Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _statusMessage,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: _isScanning 
                            ? Colors.orange 
                            : (_isNFCAvailable ? Colors.teal : Colors.red),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Nút chấm công
            ElevatedButton.icon(
              onPressed: (_isScanning || !_isNFCAvailable) ? null : _scanNFC,
              icon: _isScanning
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
                _isScanning 
                    ? 'Đang quét thẻ...' 
                    : (_currentCheckin != null ? 'Chấm Công RA' : 'Chấm Công VÀO'),
                style: const TextStyle(fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _currentCheckin != null ? Colors.blue : Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            // Thông tin chấm công vừa thực hiện
            if (_lastChamCong != null) ...[
              const SizedBox(height: 24),
              Card(
                elevation: 2,
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green.shade700),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Chấm công thành công',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(),
                      _buildInfoRow('Mã chấm công:', '${_lastChamCong!.maChamCong}'),
                      if (_lastChamCong!.gioVao != null)
                        _buildInfoRow('Giờ vào:', _dateFormat.format(_lastChamCong!.gioVao!)),
                      if (_lastChamCong!.gioRa != null)
                        _buildInfoRow('Giờ ra:', _dateFormat.format(_lastChamCong!.gioRa!)),
                      if (_lastChamCong!.thoiGianLamViec != null)
                        _buildInfoRow('Thời gian làm việc:', '${_lastChamCong!.thoiGianLamViec!.toStringAsFixed(2)} giờ'),
                      _buildInfoRow('Phương thức:', 'NFC'),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Hướng dẫn
            Card(
              elevation: 1,
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Hướng dẫn:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text('1. Đảm bảo NFC đã được bật'),
                    const Text('2. Nhấn nút chấm công'),
                    const Text('3. Đưa thẻ NFC của bạn gần thiết bị'),
                    const Text('4. Hệ thống sẽ tự động chấm công VÀO/RA'),
                    const Text('5. Chỉ sử dụng thẻ NFC của chính bạn'),
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
            width: 150,
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