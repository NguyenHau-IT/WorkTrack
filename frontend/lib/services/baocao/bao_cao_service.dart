import 'dart:convert';
import '../api/api_service.dart';
import '../../model/baocao/bao_cao.dart';

class BaoCaoService {
  final ApiService _apiService = const ApiService();
  final String endpoint = '/api/v1/baocao';

  // Lấy danh sách tất cả báo cáo
  Future<List<BaoCao>> getAllBaoCao() async {
    final response = await _apiService.get(endpoint);
    final List<dynamic> data = json.decode(response.body);
    return data.map((json) => BaoCao.fromJson(json)).toList();
  }

  // Lấy báo cáo theo ID
  Future<BaoCao> getBaoCaoById(int maBaoCao) async {
    final response = await _apiService.get('$endpoint/$maBaoCao');
    return BaoCao.fromJson(json.decode(response.body));
  }

  // Lấy báo cáo theo mã nhân viên
  Future<List<BaoCao>> getBaoCaoByNhanVien(int maNV) async {
    final response = await _apiService.get('$endpoint/nhanvien/$maNV');
    final List<dynamic> data = json.decode(response.body);
    return data.map((json) => BaoCao.fromJson(json)).toList();
  }

  // Lấy báo cáo theo khoảng thời gian
  Future<List<BaoCao>> getBaoCaoByDateRange(DateTime tuNgay, DateTime denNgay) async {
    final fromDate = tuNgay.toIso8601String().split('T')[0];
    final toDate = denNgay.toIso8601String().split('T')[0];
    final response = await _apiService.get('$endpoint/date-range?tuNgay=$fromDate&denNgay=$toDate');
    final List<dynamic> data = json.decode(response.body);
    return data.map((json) => BaoCao.fromJson(json)).toList();
  }

  // Lấy báo cáo của nhân viên theo khoảng thời gian
  Future<List<BaoCao>> getBaoCaoByNhanVienAndDateRange(
    int maNV, 
    DateTime tuNgay, 
    DateTime denNgay
  ) async {
    final fromDate = tuNgay.toIso8601String().split('T')[0];
    final toDate = denNgay.toIso8601String().split('T')[0];
    final response = await _apiService.get('$endpoint/nhanvien/$maNV/date-range?tuNgay=$fromDate&denNgay=$toDate');
    final List<dynamic> data = json.decode(response.body);
    return data.map((json) => BaoCao.fromJson(json)).toList();
  }

  // Tạo báo cáo mới
  Future<BaoCao> createBaoCao(BaoCao baoCao) async {
    final response = await _apiService.post(endpoint, body: baoCao.toJson());
    return BaoCao.fromJson(json.decode(response.body));
  }

  // Tạo báo cáo tự động cho nhân viên theo khoảng thời gian
  Future<BaoCao> generateBaoCao(int maNV, DateTime tuNgay, DateTime denNgay) async {
    final fromDate = tuNgay.toIso8601String().split('T')[0];
    final toDate = denNgay.toIso8601String().split('T')[0];
    final response = await _apiService.post(
      '$endpoint/generate',
      body: {
        'maNV': maNV,
        'tuNgay': fromDate,
        'denNgay': toDate,
      },
    );
    return BaoCao.fromJson(json.decode(response.body));
  }

  // Cập nhật báo cáo
  Future<BaoCao> updateBaoCao(int maBaoCao, BaoCao baoCao) async {
    final response = await _apiService.put('$endpoint/$maBaoCao', body: baoCao.toJson());
    return BaoCao.fromJson(json.decode(response.body));
  }

  // Xóa báo cáo (soft delete)
  Future<void> deleteBaoCao(int maBaoCao) async {
    await _apiService.delete('$endpoint/$maBaoCao');
  }

  // Khôi phục báo cáo đã xóa
  Future<BaoCao> restoreBaoCao(int maBaoCao) async {
    final response = await _apiService.put('$endpoint/$maBaoCao/restore', body: {});
    return BaoCao.fromJson(json.decode(response.body));
  }

  // Tính toán thống kê từ báo cáo
  Map<String, dynamic> calculateStatistics(BaoCao baoCao) {
    return {
      'tongGio': baoCao.tongGio,
      'gioLamThem': baoCao.gioLamThem,
      'soNgayDiTre': baoCao.soNgayDiTre,
      'soNgayVeSom': baoCao.soNgayVeSom,
      'luong': baoCao.luong,
      'gioTrungBinhMoiNgay': baoCao.tongGio / _calculateDaysBetween(baoCao.tuNgay, baoCao.denNgay),
    };
  }

  // Tính số ngày giữa 2 ngày
  int _calculateDaysBetween(DateTime from, DateTime to) {
    return to.difference(from).inDays + 1;
  }

  // Format lương thành chuỗi tiền tệ
  String formatCurrency(double amount) {
    return '${amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    )} ₫';
  }

  // Kiểm tra báo cáo có hợp lệ không
  bool validateBaoCao(BaoCao baoCao) {
    if (baoCao.tuNgay.isAfter(baoCao.denNgay)) {
      return false;
    }
    if (baoCao.tongGio < 0 || baoCao.gioLamThem < 0) {
      return false;
    }
    if (baoCao.soNgayDiTre < 0 || baoCao.soNgayVeSom < 0) {
      return false;
    }
    return true;
  }
}
