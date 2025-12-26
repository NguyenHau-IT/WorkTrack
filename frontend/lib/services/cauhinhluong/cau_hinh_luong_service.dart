import 'dart:convert';
import '../api/api_service.dart';
import '../../model/cauhinhluong/cau_hinh_luong.dart';

class CauHinhLuongService {
  final ApiService _apiService = ApiService();
  final String endpoint = '/cauhinhluong';

  // Lấy danh sách tất cả cấu hình lương
  Future<List<CauHinhLuong>> getAllCauHinhLuong() async {
    final response = await _apiService.get(endpoint);
    final List<dynamic> data = json.decode(response.body);
    return data.map((json) => CauHinhLuong.fromJson(json)).toList();
  }

  // Lấy cấu hình lương theo ID
  Future<CauHinhLuong> getCauHinhLuongById(int maCauHinh) async {
    final response = await _apiService.get('$endpoint/$maCauHinh');
    return CauHinhLuong.fromJson(json.decode(response.body));
  }

  // Tạo cấu hình lương mới
  Future<CauHinhLuong> createCauHinhLuong(CauHinhLuong cauHinhLuong) async {
    final response = await _apiService.post(endpoint, body: cauHinhLuong.toJson());
    return CauHinhLuong.fromJson(json.decode(response.body));
  }

  // Cập nhật cấu hình lương
  Future<CauHinhLuong> updateCauHinhLuong(int maCauHinh, CauHinhLuong cauHinhLuong) async {
    final response = await _apiService.put('$endpoint/$maCauHinh', body: cauHinhLuong.toJson());
    return CauHinhLuong.fromJson(json.decode(response.body));
  }

  // Xóa cấu hình lương (soft delete)
  Future<void> deleteCauHinhLuong(int maCauHinh) async {
    await _apiService.delete('$endpoint/$maCauHinh');
  }

  // Khôi phục cấu hình lương đã xóa
  Future<CauHinhLuong> restoreCauHinhLuong(int maCauHinh) async {
    final response = await _apiService.put('$endpoint/$maCauHinh/restore', body: {});
    return CauHinhLuong.fromJson(json.decode(response.body));
  }

  // Xóa cứng cấu hình lương (hard delete)
  Future<void> hardDeleteCauHinhLuong(int maCauHinh) async {
    await _apiService.delete('$endpoint/$maCauHinh/hard');
  }

  // Lấy cấu hình lương đang áp dụng hiện tại
  Future<CauHinhLuong> getActiveCauHinhLuong() async {
    final response = await _apiService.get('$endpoint/active');
    return CauHinhLuong.fromJson(json.decode(response.body));
  }

  // Tính lương dựa trên số giờ làm việc
  double calculateSalary({
    required double tongGio,
    required double gioLamThem,
    required CauHinhLuong cauHinhLuong,
  }) {
    final luongCoBan = tongGio * cauHinhLuong.luongGio;
    final luongOvertime = gioLamThem * cauHinhLuong.luongLamThem;
    return luongCoBan + luongOvertime;
  }

  // Tính lương chỉ dựa trên giờ thường
  double calculateBaseSalary({
    required double tongGio,
    required CauHinhLuong cauHinhLuong,
  }) {
    return tongGio * cauHinhLuong.luongGio;
  }

  // Tính lương làm thêm
  double calculateOvertimeSalary({
    required double gioLamThem,
    required CauHinhLuong cauHinhLuong,
  }) {
    return gioLamThem * cauHinhLuong.luongLamThem;
  }
}
