import 'package:flutter/material.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:intl/intl.dart';
import '../../model/chamcong/cham_cong.dart';
import '../../services/nfc/nfc_service.dart';
import '../../services/chamcong/cham_cong_service.dart';

class DocNFCChamCongScreen extends StatefulWidget {
  const DocNFCChamCongScreen({super.key});

  @override
  State<DocNFCChamCongScreen> createState() => _DocNFCChamCongScreenState();
}

class _DocNFCChamCongScreenState extends State<DocNFCChamCongScreen> {
  final NFCService _nfcService = NFCService();
  final ChamCongService _chamCongService = ChamCongService();
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy HH:mm:ss');

  bool _isScanning = false;
  bool _isNFCAvailable = false;
  String _statusMessage = 'Kiểm tra NFC...';
  Map<String, dynamic>? _lastReadData;
  ChamCong? _lastChamCong;
  List<Map<String, dynamic>> _scanHistory = [];

  @override
  void initState() {
    super.initState();
    _checkNFC();
  }

  Future<void> _checkNFC() async {
    try {
      NFCAvailability availability = await _nfcService.checkNFCAvailability();
      setState(() {
        _isNFCAvailable = availability == NFCAvailability.available;
        if (_isNFCAvailable) {
          _statusMessage = 'NFC sẵn sàng. Nhấn "Quét Thẻ" để bắt đầu';
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

  Future<void> _docTheNFC() async {
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
      _lastReadData = null;
      _lastChamCong = null;
    });

    try {
      // Đọc thẻ NFC
      Map<String, dynamic>? data = await _nfcService.readNFC();

      if (data != null && mounted) {
        setState(() {
          _lastReadData = data;
          _statusMessage = 'Đọc thẻ thành công! Đang xử lý chấm công...';
        });

        // Kiểm tra có mã nhân viên không
        if (data.containsKey('maNV')) {
          int maNV = data['maNV'];
          await _xuLyChamCong(maNV, data);
        } else {
          setState(() {
            _statusMessage = 'Thẻ không chứa thông tin nhân viên hợp lệ';
          });
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Thẻ không chứa mã nhân viên. Vui lòng ghi lại thẻ.'),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 4),
              ),
            );
          }
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

  Future<bool> _hienThiDialogXacNhan(int thoiGianLamViec) async {
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
                child: Text(
                  'Xác nhận chấm công ra',
                  maxLines: 2,
                  overflow: TextOverflow.visible,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bạn mới chấm công vào được $thoiGianLamViec phút.',
                  style: const TextStyle(fontSize: 15),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Thời gian làm việc chưa đủ 1 giờ (60 phút).',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Bạn có chắc chắn muốn chấm công ra không?',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ],
            ),
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

  Future<void> _xuLyChamCong(int maNV, Map<String, dynamic> nfcData) async {
    try {
      // Kiểm tra nhân viên có đang chấm công hay không
      ChamCong? chamCongHienTai = await _chamCongService.getChamCongHienTai(maNV);

      ChamCong result;
      String message;
      Color bgColor;

      if (chamCongHienTai == null) {
        // Chưa chấm công vào => Chấm công vào
        result = await _chamCongService.chamCongVao(maNV, phuongThuc: 'NFC');
        message = 'Chấm công VÀO thành công!';
        bgColor = Colors.green;
      } else {
        // Đã chấm công vào => Kiểm tra thời gian trước khi chấm công ra
        final gioVao = chamCongHienTai.gioVao;
        if (gioVao != null) {
          final thoiGianLamViec = DateTime.now().difference(gioVao).inMinutes;
          
          if (thoiGianLamViec < 60) {
            // Chưa đủ 60 phút => Hiện dialog xác nhận
            final xacNhan = await _hienThiDialogXacNhan(thoiGianLamViec);
            if (!xacNhan) {
              // User không xác nhận => Hủy chấm công ra
              if (mounted) {
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
              }
              return;
            }
          }
        }
        
        // Xác nhận hoặc đã đủ thời gian => Chấm công ra
        result = await _chamCongService.chamCongRa(maNV);
        message = 'Chấm công RA thành công!';
        bgColor = Colors.blue;
      }

      if (mounted) {
        setState(() {
          _lastChamCong = result;
          _statusMessage = message;
          
          // Thêm vào lịch sử
          _scanHistory.insert(0, {
            'time': DateTime.now(),
            'maNV': maNV,
            'hoTen': nfcData['hoTen'] ?? 'Nhân viên #$maNV',
            'type': chamCongHienTai == null ? 'VÀO' : 'RA',
            'chamCong': result,
          });

          // Giữ tối đa 10 bản ghi lịch sử
          if (_scanHistory.length > 10) {
            _scanHistory = _scanHistory.sublist(0, 10);
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: bgColor,
            duration: const Duration(seconds: 3),
          ),
        );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chấm Công NFC'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _checkNFC,
            tooltip: 'Kiểm tra lại NFC',
          ),
        ],
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
                      _isScanning 
                          ? Icons.nfc 
                          : (_isNFCAvailable ? Icons.nfc : Icons.nfc_outlined),
                      size: 64,
                      color: _isScanning 
                          ? Colors.orange 
                          : (_isNFCAvailable ? Colors.green : Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _statusMessage,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: _isScanning 
                            ? Colors.orange 
                            : (_isNFCAvailable ? Colors.green : Colors.red),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Nút quét thẻ
            ElevatedButton.icon(
              onPressed: (_isScanning || !_isNFCAvailable) ? null : _docTheNFC,
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
                _isScanning ? 'Đang quét...' : 'Quét Thẻ NFC',
                style: const TextStyle(fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
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
                          Text(
                            'Chấm công thành công',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                      const Divider(),
                      _buildInfoRow('Mã chấm công:', '${_lastChamCong!.maChamCong}'),
                      _buildInfoRow('Mã NV:', '${_lastChamCong!.maNV}'),
                      if (_lastChamCong!.nhanVien?.hoTen != null)
                        _buildInfoRow('Họ tên:', _lastChamCong!.nhanVien!.hoTen!),
                      if (_lastChamCong!.gioVao != null)
                        _buildInfoRow('Giờ vào:', _dateFormat.format(_lastChamCong!.gioVao!)),
                      if (_lastChamCong!.gioRa != null)
                        _buildInfoRow('Giờ ra:', _dateFormat.format(_lastChamCong!.gioRa!)),
                      if (_lastChamCong!.thoiGianLamViec != null)
                        _buildInfoRow(
                          'Thời gian làm việc:',
                          '${_lastChamCong!.thoiGianLamViec!.toStringAsFixed(2)} giờ',
                        ),
                      _buildInfoRow('Phương thức:', _lastChamCong!.phuongThuc ?? 'NFC'),
                    ],
                  ),
                ),
              ),
            ],

            // Dữ liệu thẻ NFC (debug)
            if (_lastReadData != null && _lastReadData!.isNotEmpty) ...[
              const SizedBox(height: 16),
              ExpansionTile(
                title: const Text('Thông tin thẻ NFC'),
                leading: const Icon(Icons.info_outline),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _lastReadData!.entries.map((entry) {
                        return _buildInfoRow('${entry.key}:', '${entry.value}');
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ],

            // Lịch sử quét
            if (_scanHistory.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                'Lịch sử chấm công:',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _scanHistory.length,
                itemBuilder: (context, index) {
                  var item = _scanHistory[index];
                  bool isVao = item['type'] == 'VÀO';
                  
                  return Card(
                    elevation: 1,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isVao ? Colors.green : Colors.blue,
                        child: Text(
                          item['type'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        item['hoTen'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Mã NV: ${item['maNV']} - ${_dateFormat.format(item['time'])}',
                      ),
                      trailing: Icon(
                        isVao ? Icons.login : Icons.logout,
                        color: isVao ? Colors.green : Colors.blue,
                      ),
                    ),
                  );
                },
              ),
            ],

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
                    const Text('1. Nhấn nút "Quét Thẻ NFC"'),
                    const Text('2. Đưa thẻ NFC gần mặt sau thiết bị'),
                    const Text('3. Hệ thống tự động chấm công VÀO/RA'),
                    const Text('4. Lần 1: Chấm công VÀO'),
                    const Text('5. Lần 2: Chấm công RA'),
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
