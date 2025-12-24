import 'dart:convert';
import '../api/api_service.dart';
import '../../model/chamcong/cham_cong.dart';

class ChamCongService {
  final ApiService _apiService = ApiService();
  final String endpoint = '/api/v1/chamcong';

  /// Lấy tất cả bản ghi chấm công
  Future<List<ChamCong>> getAllChamCong() async {
    final response = await _apiService.get(endpoint);
    final List<dynamic> data = json.decode(response.body);
    return data.map((json) => ChamCong.fromJson(json)).toList();
  }

  /// Lấy bản ghi chấm công theo mã
  Future<ChamCong> getChamCongById(int maChamCong) async {
    final response = await _apiService.get('$endpoint/$maChamCong');
    return ChamCong.fromJson(json.decode(response.body));
  }

  /// Lấy danh sách chấm công theo mã nhân viên
  Future<List<ChamCong>> getChamCongByNhanVien(int maNV) async {
    final response = await _apiService.get('$endpoint/nhanvien/$maNV');
    final List<dynamic> data = json.decode(response.body);
    return data.map((json) => ChamCong.fromJson(json)).toList();
  }

  /// Lấy chấm công theo ngày
  Future<List<ChamCong>> getChamCongByDate(DateTime date) async {
    final dateStr = date.toIso8601String().split('T')[0]; // Format: yyyy-MM-dd
    final response = await _apiService.get('$endpoint/date/$dateStr');
    final List<dynamic> data = json.decode(response.body);
    return data.map((json) => ChamCong.fromJson(json)).toList();
  }

  /// Lấy chấm công theo khoảng thời gian
  Future<List<ChamCong>> getChamCongByDateRange(DateTime startDate, DateTime endDate) async {
    final startStr = startDate.toIso8601String().split('T')[0];
    final endStr = endDate.toIso8601String().split('T')[0];
    final response = await _apiService.get('$endpoint/range?startDate=$startStr&endDate=$endStr');
    final List<dynamic> data = json.decode(response.body);
    return data.map((json) => ChamCong.fromJson(json)).toList();
  }

  /// Lấy chấm công của nhân viên theo khoảng thời gian
  Future<List<ChamCong>> getChamCongByNhanVienAndDateRange(int maNV, DateTime startDate, DateTime endDate) async {
    final startStr = startDate.toIso8601String().split('T')[0];
    final endStr = endDate.toIso8601String().split('T')[0];
    final response = await _apiService.get('$endpoint/nhanvien/$maNV/range?startDate=$startStr&endDate=$endStr');
    final List<dynamic> data = json.decode(response.body);
    return data.map((json) => ChamCong.fromJson(json)).toList();
  }

  /// Tạo bản ghi chấm công mới
  Future<ChamCong> createChamCong(ChamCong chamCong) async {
    final response = await _apiService.post(endpoint, body: chamCong.toJson());
    return ChamCong.fromJson(json.decode(response.body));
  }

  /// Chấm công vào (check-in)
  Future<ChamCong> chamCongVao(int maNV, {String phuongThuc = 'ThuCong', String? ghiChu}) async {
    final response = await _apiService.post('$endpoint/checkin', body: {
      'maNV': maNV,
      'phuongThuc': phuongThuc,
      'ghiChu': ghiChu,
    });
    return ChamCong.fromJson(json.decode(response.body));
  }

  /// Chấm công ra (check-out)
  Future<ChamCong> chamCongRa(int maNV, {String? ghiChu}) async {
    final response = await _apiService.post('$endpoint/checkout', body: {
      'maNV': maNV,
      'ghiChu': ghiChu,
    });
    return ChamCong.fromJson(json.decode(response.body));
  }

  /// Cập nhật bản ghi chấm công
  Future<ChamCong> updateChamCong(int maChamCong, ChamCong chamCong) async {
    final response = await _apiService.put('$endpoint/$maChamCong', body: chamCong.toJson());
    return ChamCong.fromJson(json.decode(response.body));
  }

  /// Xóa bản ghi chấm công (soft delete)
  Future<void> deleteChamCong(int maChamCong) async {
    await _apiService.delete('$endpoint/$maChamCong');
  }

  /// Khôi phục bản ghi chấm công đã xóa
  Future<void> khoiPhucChamCong(int maChamCong) async {
    await _apiService.put('$endpoint/restore/$maChamCong');
  }

  /// Xóa cứng bản ghi chấm công (hard delete)
  Future<void> hardDeleteChamCong(int maChamCong) async {
    await _apiService.delete('$endpoint/$maChamCong/hard');
  }

  /// Lấy bản ghi chấm công hiện tại của nhân viên (đang chấm công)
  Future<ChamCong?> getChamCongHienTai(int maNV) async {
    try {
      final response = await _apiService.get('$endpoint/nhanvien/$maNV/status');
      final data = json.decode(response.body);
      if (data['status'] == 'checked-in' && data['chamCong'] != null) {
        return ChamCong.fromJson(data['chamCong']);
      }
      return null;
    } catch (e) {
      return null; // Không có bản ghi chấm công hiện tại
    }
  }

  /// Thống kê số giờ làm việc theo nhân viên trong khoảng thời gian
  Future<Map<String, dynamic>> thongKeSoGioLamViec(int maNV, DateTime startDate, DateTime endDate) async {
    final startStr = startDate.toIso8601String().split('T')[0];
    final endStr = endDate.toIso8601String().split('T')[0];
    final response = await _apiService.get('$endpoint/thongke/$maNV?startDate=$startStr&endDate=$endStr');
    return json.decode(response.body);
  }

  /// Kiểm tra nhân viên đã chấm công trong ngày chưa
  Future<bool> kiemTraDaChamCong(int maNV, DateTime date) async {
    final dateStr = date.toIso8601String().split('T')[0];
    final response = await _apiService.get('$endpoint/kiemtra/$maNV/$dateStr');
    return json.decode(response.body)['daChamCong'];
  }
}
