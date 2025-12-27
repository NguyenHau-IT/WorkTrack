import 'dart:convert';
import '../../model/lichlamviec/lich_lam_viec.dart';
import '../api/api_service.dart';

class LichLamViecService {
  static const String endpoint = 'lichlamviec';
  final ApiService _apiService = ApiService();

  // Lấy tất cả lịch làm việc
  Future<List<LichLamViec>> getAllLichLamViec() async {
    final response = await _apiService.get(endpoint);
    final List<dynamic> data = json.decode(response.body);
    return data.map((json) => LichLamViec.fromJson(json)).toList();
  }

  // Lấy lịch làm việc theo ID
  Future<LichLamViec?> getLichLamViecById(int maLich) async {
    try {
      final response = await _apiService.get('$endpoint/$maLich');
      return LichLamViec.fromJson(json.decode(response.body));
    } catch (e) {
      return null;
    }
  }

  // Lấy lịch làm việc theo nhân viên
  Future<List<LichLamViec>> getLichLamViecByNhanVien(int maNV) async {
    final response = await _apiService.get('$endpoint/nhanvien/$maNV');
    final List<dynamic> data = json.decode(response.body);
    return data.map((json) => LichLamViec.fromJson(json)).toList();
  }

  // Lấy lịch làm việc theo ngày
  Future<List<LichLamViec>> getLichLamViecByNgay(DateTime ngay) async {
    final ngayStr = ngay.toIso8601String().split('T')[0];
    final response = await _apiService.get('$endpoint/ngay/$ngayStr');
    final List<dynamic> data = json.decode(response.body);
    return data.map((json) => LichLamViec.fromJson(json)).toList();
  }

  // Lấy lịch làm việc theo nhân viên và khoảng thời gian
  Future<List<LichLamViec>> getLichLamViecByNhanVienAndKhoangThoiGian(
      int maNV, DateTime tuNgay, DateTime denNgay) async {
    final tuNgayStr = tuNgay.toIso8601String().split('T')[0];
    final denNgayStr = denNgay.toIso8601String().split('T')[0];
    final response = await _apiService.get(
        '$endpoint/nhanvien/$maNV/khoangthoi?tuNgay=$tuNgayStr&denNgay=$denNgayStr');
    final List<dynamic> data = json.decode(response.body);
    return data.map((json) => LichLamViec.fromJson(json)).toList();
  }

  // Lấy lịch làm việc theo khoảng thời gian
  Future<List<LichLamViec>> getLichLamViecByKhoangThoiGian(
      DateTime tuNgay, DateTime denNgay) async {
    final tuNgayStr = tuNgay.toIso8601String().split('T')[0];
    final denNgayStr = denNgay.toIso8601String().split('T')[0];
    final response = await _apiService.get(
        '$endpoint/khoangthoi?tuNgay=$tuNgayStr&denNgay=$denNgayStr');
    final List<dynamic> data = json.decode(response.body);
    return data.map((json) => LichLamViec.fromJson(json)).toList();
  }

  // Tạo lịch làm việc mới
  Future<LichLamViec> createLichLamViec(LichLamViec lichLamViec) async {
    final response = await _apiService.post(endpoint, body: lichLamViec.toJson());
    return LichLamViec.fromJson(json.decode(response.body));
  }

  // Cập nhật lịch làm việc
  Future<LichLamViec> updateLichLamViec(int maLich, LichLamViec lichLamViec) async {
    final response = await _apiService.put('$endpoint/$maLich', body: lichLamViec.toJson());
    return LichLamViec.fromJson(json.decode(response.body));
  }

  // Xóa lịch làm việc
  Future<void> deleteLichLamViec(int maLich) async {
    await _apiService.delete('$endpoint/$maLich');
  }

  // Lấy lịch làm việc theo trạng thái
  Future<List<LichLamViec>> getLichLamViecByTrangThai(String trangThai) async {
    final response = await _apiService.get('$endpoint/trangthai/$trangThai');
    final List<dynamic> data = json.decode(response.body);
    return data.map((json) => LichLamViec.fromJson(json)).toList();
  }

  // Lấy lịch làm việc tuần này của nhân viên
  Future<List<LichLamViec>> getLichLamViecTuanNay(int maNV) async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(Duration(days: 6));
    
    return getLichLamViecByNhanVienAndKhoangThoiGian(maNV, startOfWeek, endOfWeek);
  }

  // Lấy lịch làm việc tháng này của nhân viên
  Future<List<LichLamViec>> getLichLamViecThangNay(int maNV) async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    
    return getLichLamViecByNhanVienAndKhoangThoiGian(maNV, startOfMonth, endOfMonth);
  }
}