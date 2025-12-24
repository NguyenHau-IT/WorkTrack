import 'package:flutter/material.dart';
import '../../services/biometric/biometric_service.dart';
import '../../services/nhan_vien/nhan_vien_service.dart';
import '../../model/nhanvien/nhan_vien.dart';
import 'package:local_auth/local_auth.dart';
import 'dart:convert';

class BiometricSetupScreen extends StatefulWidget {
  final NhanVien nhanVien;

  const BiometricSetupScreen({super.key, required this.nhanVien});

  @override
  State<BiometricSetupScreen> createState() => _BiometricSetupScreenState();
}

class _BiometricSetupScreenState extends State<BiometricSetupScreen> {
  final BiometricService _biometricService = BiometricService();
  final NhanVienService _nhanVienService = NhanVienService();
  
  bool _isSupported = false;
  bool _canCheckBiometrics = false;
  List<BiometricType> _availableBiometrics = [];
  bool _isLoading = true;
  bool _isRegistering = false;

  @override
  void initState() {
    super.initState();
    print('BiometricSetupScreen opened for: ${widget.nhanVien.hoTen}');
    _checkBiometricSupport();
    
    // Hiển thị snackbar khi màn hình mở
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đang kiểm tra hỗ trợ sinh trắc học...'),
          duration: const Duration(seconds: 2),
        ),
      );
    });
  }

  Future<void> _checkBiometricSupport() async {
    setState(() => _isLoading = true);

    try {
      final isSupported = await _biometricService.isDeviceSupported();
      print('Device supported: $isSupported');
      
      final canCheck = await _biometricService.canCheckBiometrics();
      print('Can check biometrics: $canCheck');
      
      final biometrics = await _biometricService.getAvailableBiometrics();
      print('Available biometrics: $biometrics');

      setState(() {
        _isSupported = isSupported;
        _canCheckBiometrics = canCheck;
        _availableBiometrics = biometrics;
        _isLoading = false;
      });
    } catch (e) {
      print('Error checking biometric support: $e');
      setState(() {
        _isSupported = false;
        _canCheckBiometrics = false;
        _availableBiometrics = [];
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi kiểm tra hỗ trợ sinh trắc học: $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> _registerFingerprint() async {
    print('Starting fingerprint registration...');
    print('Available biometrics: $_availableBiometrics');
    
    if (!_availableBiometrics.contains(BiometricType.fingerprint)) {
      _showErrorDialog('Thiết bị không hỗ trợ vân tay.\nSố loại sinh trắc có sẵn: ${_availableBiometrics.length}');
      return;
    }

    setState(() => _isRegistering = true);

    try {
      print('Requesting biometric authentication...');
      
      // Hiển thị thông báo trước khi quét
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng đặt vân tay lên cảm biến...'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      
      // Chờ một chút để snackbar hiện
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Yêu cầu xác thực vân tay
      final didAuthenticate = await _biometricService.authenticate(
        localizedReason: 'Đặt vân tay của bạn lên cảm biến để đăng ký',
        biometricOnly: false,  // Thử false để cho phép PIN/Pattern backup
      );

      print('Authentication result: $didAuthenticate');

      if (didAuthenticate) {
        // Tạo fingerprint hash (trong thực tế nên dùng template thật)
        final fingerprintHash = base64Encode(
          utf8.encode('${widget.nhanVien.maNV}_fingerprint_${DateTime.now().millisecondsSinceEpoch}')
        );
        
        print('Sending fingerprint to server...');
        // Gửi lên server
        await _nhanVienService.updateVanTay(
          widget.nhanVien.maNV!,
          fingerprintHash,
        );

        print('Fingerprint registered successfully!');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đăng ký vân tay thành công!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
          await Future.delayed(const Duration(seconds: 1));
          Navigator.pop(context, true);
        }
      } else {
        _showErrorDialog('Xác thực vân tay thất bại. Vui lòng thử lại.');
      }
    } catch (e) {
      print('Error during fingerprint registration: $e');
      _showErrorDialog('Lỗi: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isRegistering = false);
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Lỗi'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  Future<void> _testBiometric() async {
    print('Testing biometric authentication...');
    try {
      final result = await _biometricService.authenticate(
        localizedReason: 'Test xác thực sinh trắc học',
        biometricOnly: false,
      );
      
      print('Test result: $result');
      
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(result ? '✅ Thành công' : '❌ Thất bại'),
            content: Text(
              result 
                ? 'Xác thực sinh trắc học hoạt động bình thường!'
                : 'Không thể xác thực. Vui lòng kiểm tra cài đặt thiết bị.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Đóng'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print('Test error: $e');
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('❌ Lỗi'),
            content: Text('Lỗi test: ${e.toString()}'),
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Đăng ký vân tay - ${widget.nhanVien.hoTen}'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Đang kiểm tra thiết bị...'),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thông tin thiết bị
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Trạng thái thiết bị',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildStatusRow(
                            'Hỗ trợ sinh trắc học',
                            _isSupported,
                            Icons.devices,
                          ),
                          const Divider(),
                          _buildStatusRow(
                            'Đã đăng ký sinh trắc',
                            _canCheckBiometrics,
                            Icons.check_circle,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Danh sách sinh trắc có sẵn
                  const Text(
                    'Loại sinh trắc học có sẵn',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (_availableBiometrics.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Icon(Icons.warning, color: Colors.orange),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text('Không có sinh trắc học nào được đăng ký trên thiết bị'),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ..._availableBiometrics.map((type) => Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue.withOpacity(0.1),
                              child: Icon(
                                _getBiometricIcon(type),
                                color: Colors.blue,
                              ),
                            ),
                            title: Text(_biometricService.getBiometricTypeName(type)),
                            trailing: const Icon(Icons.check_circle, color: Colors.green),
                          ),
                        )),

                  const SizedBox(height: 32),

                  // Thông tin debug
                  if (!_availableBiometrics.contains(BiometricType.fingerprint))
                    Card(
                      color: Colors.orange.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.warning, color: Colors.orange),
                                const SizedBox(width: 8),
                                const Text(
                                  'Không thể đăng ký vân tay',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text('• Hỗ trợ thiết bị: ${_isSupported ? "Có" : "Không"}'),
                            Text('• Đã đăng ký sinh trắc: ${_canCheckBiometrics ? "Có" : "Không"}'),
                            Text('• Số loại sinh trắc: ${_availableBiometrics.length}'),
                            const SizedBox(height: 8),
                            const Text(
                              'Vui lòng đảm bảo:\n'
                              '1. Thiết bị có cảm biến vân tay\n'
                              '2. Đã đăng ký ít nhất 1 vân tay trong cài đặt hệ thống\n'
                              '3. Đã cấp quyền sinh trắc học cho ứng dụng\n'
                              '4. Nếu dùng emulator: Đăng ký vân tay ảo trong Settings',
                              style: TextStyle(fontSize: 12),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              onPressed: _checkBiometricSupport,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Kiểm tra lại'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Nút test đơn giản (hiện luôn)
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: _testBiometric,
                    icon: const Icon(Icons.bug_report),
                    label: const Text('Test xác thực sinh trắc học'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.purple,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Nút đăng ký vân tay
                  if (_availableBiometrics.contains(BiometricType.fingerprint))
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isRegistering ? null : _registerFingerprint,
                        icon: _isRegistering
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.fingerprint),
                        label: Text(_isRegistering ? 'Đang đăng ký...' : 'Đăng ký vân tay'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Hướng dẫn
                  Card(
                    color: Colors.blue.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info, color: Colors.blue),
                              const SizedBox(width: 8),
                              const Text(
                                'Hướng dẫn',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text('1. Đảm bảo ngón tay sạch và khô'),
                          const SizedBox(height: 4),
                          const Text('2. Đặt ngón tay lên cảm biến khi được yêu cầu'),
                          const SizedBox(height: 4),
                          const Text('3. Giữ nguyên cho đến khi hoàn tất'),
                          const SizedBox(height: 4),
                          const Text('4. Vân tay sẽ được lưu để sử dụng cho chấm công'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatusRow(String label, bool status, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: status ? Colors.green : Colors.grey,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
        ),
        Icon(
          status ? Icons.check_circle : Icons.cancel,
          color: status ? Colors.green : Colors.red,
        ),
      ],
    );
  }

  IconData _getBiometricIcon(BiometricType type) {
    switch (type) {
      case BiometricType.face:
        return Icons.face;
      case BiometricType.fingerprint:
        return Icons.fingerprint;
      case BiometricType.iris:
        return Icons.remove_red_eye;
      default:
        return Icons.security;
    }
  }
}
