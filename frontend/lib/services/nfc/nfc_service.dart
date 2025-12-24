import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:ndef/ndef.dart' as ndef;
import 'dart:convert';

class NFCService {
  /// Kiểm tra thiết bị có hỗ trợ NFC không
  Future<NFCAvailability> checkNFCAvailability() async {
    return await FlutterNfcKit.nfcAvailability;
  }

  /// Đọc thông tin từ thẻ NFC
  /// Trả về Map dữ liệu nếu thành công, null nếu thất bại
  Future<Map<String, dynamic>?> readNFC() async {
    try {
      final availability = await checkNFCAvailability();
      if (availability != NFCAvailability.available) {
        throw Exception('NFC không khả dụng trên thiết bị này');
      }

      final tag = await FlutterNfcKit.poll(
        timeout: const Duration(seconds: 10),
        iosMultipleTagMessage: 'Phát hiện nhiều thẻ NFC',
        iosAlertMessage: 'Đưa thiết bị gần thẻ NFC',
      );

      // Thử đọc NDEF
      final ndefRecords = await FlutterNfcKit.readNDEFRecords();

      if (ndefRecords.isNotEmpty) {
        final record = ndefRecords.first;

        if (record is ndef.TextRecord) {
          final text = record.text;
          try {
            final data = json.decode(text!) as Map<String, dynamic>;
            await FlutterNfcKit.finish(iosAlertMessage: 'Đọc thẻ thành công');
            return data;
          } catch (_) {
            // Không phải JSON → coi như mã nhân viên
            await FlutterNfcKit.finish(iosAlertMessage: 'Đọc thẻ thành công');
            return {'maNV': int.tryParse(text!) ?? 0, 'rawData': text};
          }
        } else {
          // Record không phải Text → trả về raw payload nếu cần
          try {
            final payload = utf8.decode(record.payload as List<int>);
            await FlutterNfcKit.finish(iosAlertMessage: 'Đọc thẻ thành công');
            return {'rawPayload': payload};
          } catch (_) {
            await FlutterNfcKit.finish(iosAlertMessage: 'Đọc thẻ thành công');
            return {'rawPayload': 'Binary data'};
          }
        }
      }

      // Không có NDEF → trả về thông tin thẻ
      await FlutterNfcKit.finish(iosAlertMessage: 'Đọc thẻ thành công');
      return {
        'tagId': tag.id,
        'tagType': tag.type.toString(),
        'standard': tag.standard,
      };
    } catch (e) {
      try {
        await FlutterNfcKit.finish(iosErrorMessage: 'Lỗi đọc thẻ: $e');
      } catch (_) {}
      throw Exception('Lỗi đọc NFC: $e');
    }
  }

  /// Ghi thông tin nhân viên vào thẻ NFC
  Future<bool> writeNFC({
    required int maNV,
    String? hoTen,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final availability = await checkNFCAvailability();
      if (availability != NFCAvailability.available) {
        throw Exception('NFC không khả dụng trên thiết bị này');
      }

      await FlutterNfcKit.poll(
        timeout: const Duration(seconds: 10),
        iosMultipleTagMessage: 'Phát hiện nhiều thẻ NFC',
        iosAlertMessage: 'Đưa thiết bị gần thẻ NFC để ghi dữ liệu',
      );

      // Chuẩn bị dữ liệu
      final data = {
        'maNV': maNV,
        'hoTen': hoTen,
        'ngayGhi': DateTime.now().toIso8601String(),
        ...?additionalData,
      };

      final jsonData = json.encode(data);

      // Tạo Text Record (khuyến nghị - tự xử lý language code)
      final record = ndef.TextRecord(
        text: jsonData,
        language: 'en',
        encoding: ndef.TextEncoding.UTF8,
      );

      // Ghi vào thẻ
      await FlutterNfcKit.writeNDEFRecords([record]);

      await FlutterNfcKit.finish(iosAlertMessage: 'Ghi thẻ thành công!');
      return true;
    } catch (e) {
      try {
        await FlutterNfcKit.finish(iosErrorMessage: 'Lỗi ghi thẻ: $e');
      } catch (_) {}
      throw Exception('Lỗi ghi NFC: $e');
    }
  }

  /// Đọc ID thẻ NFC (không cần NDEF)
  Future<String?> readNFCId() async {
    try {
      final availability = await checkNFCAvailability();
      if (availability != NFCAvailability.available) {
        throw Exception('NFC không khả dụng trên thiết bị này');
      }

      final tag = await FlutterNfcKit.poll(
        timeout: const Duration(seconds: 10),
        iosMultipleTagMessage: 'Phát hiện nhiều thẻ NFC',
        iosAlertMessage: 'Đưa thiết bị gần thẻ NFC',
      );

      await FlutterNfcKit.finish(iosAlertMessage: 'Đọc ID thẻ thành công');
      return tag.id;
    } catch (e) {
      try {
        await FlutterNfcKit.finish(iosErrorMessage: 'Lỗi đọc thẻ');
      } catch (_) {}
      return null;
    }
  }

  /// Xóa toàn bộ NDEF trên thẻ
  Future<bool> eraseNFC() async {
    try {
      final availability = await checkNFCAvailability();
      if (availability != NFCAvailability.available) {
        throw Exception('NFC không khả dụng trên thiết bị này');
      }

      await FlutterNfcKit.poll(
        timeout: const Duration(seconds: 10),
        iosMultipleTagMessage: 'Phát hiện nhiều thẻ NFC',
        iosAlertMessage: 'Đưa thiết bị gần thẻ NFC để xóa',
      );

      await FlutterNfcKit.writeNDEFRecords([]);

      await FlutterNfcKit.finish(iosAlertMessage: 'Xóa dữ liệu thành công!');
      return true;
    } catch (e) {
      try {
        await FlutterNfcKit.finish(iosErrorMessage: 'Lỗi xóa dữ liệu: $e');
      } catch (_) {}
      throw Exception('Lỗi xóa NFC: $e');
    }
  }
}
