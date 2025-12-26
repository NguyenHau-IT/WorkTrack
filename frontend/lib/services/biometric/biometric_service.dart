import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';

class BiometricService {
  final LocalAuthentication _localAuth = LocalAuthentication();

  /// Kiểm tra thiết bị có hỗ trợ sinh trắc học không
  Future<bool> isDeviceSupported() async {
    try {
      return await _localAuth.isDeviceSupported();
    } on PlatformException {
      return false;
    }
  }

  /// Kiểm tra đã đăng ký sinh trắc học chưa
  Future<bool> canCheckBiometrics() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } on PlatformException {
      return false;
    }
  }

  /// Lấy danh sách loại sinh trắc học có sẵn
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } on PlatformException {
      return <BiometricType>[];
    }
  }

  /// Xác thực sinh trắc học
  Future<bool> authenticate({
    required String localizedReason,
    bool biometricOnly = false,
  }) async {
    try {
      bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: localizedReason,
      );
      return didAuthenticate;
    } on PlatformException catch (e) {
      print('Authentication error: ${e.message}');
      return false;
    }
  }

  /// Dừng xác thực
  Future<void> stopAuthentication() async {
    await _localAuth.stopAuthentication();
  }

  /// Lấy tên loại sinh trắc học
  String getBiometricTypeName(BiometricType type) {
    switch (type) {
      case BiometricType.face:
        return 'Khuôn mặt';
      case BiometricType.fingerprint:
        return 'Vân tay';
      case BiometricType.iris:
        return 'Mống mắt';
      case BiometricType.strong:
        return 'Sinh trắc mạnh';
      case BiometricType.weak:
        return 'Sinh trắc yếu';
    }
  }

  /// Kiểm tra có hỗ trợ vân tay không
  Future<bool> hasFingerprintSupport() async {
    final biometrics = await getAvailableBiometrics();
    return biometrics.contains(BiometricType.fingerprint);
  }

  /// Kiểm tra có hỗ trợ Face ID không
  Future<bool> hasFaceSupport() async {
    final biometrics = await getAvailableBiometrics();
    return biometrics.contains(BiometricType.face);
  }
}
