import 'dart:convert';
import '../../model/nghiphep/nghi_phep.dart';
import '../api/api_service.dart';

class NghiPhepService {
  static const String endpoint = 'nghiphep';
  final ApiService _apiService = ApiService();

  // Lấy tất cả đơn nghỉ phép
  Future<List<NghiPhep>> getAllNghiPhep() async {
    final response = await _apiService.get(endpoint);
    final List<dynamic> data = json.decode(response.body);
    return data.map((json) => NghiPhep.fromJson(json)).toList();
  }

  // Lấy đơn nghỉ phép theo ID
  Future<NghiPhep?> getNghiPhepById(int maNghiPhep) async {
    try {
      final response = await _apiService.get('$endpoint/$maNghiPhep');
      return NghiPhep.fromJson(json.decode(response.body));
    } catch (e) {
      return null;
    }
  }

  // Lấy đơn nghỉ phép theo nhân viên
  Future<List<NghiPhep>> getNghiPhepByNhanVien(int maNV) async {
    final response = await _apiService.get('$endpoint/nhanvien/$maNV');
    final List<dynamic> data = json.decode(response.body);
    return data.map((json) => NghiPhep.fromJson(json)).toList();
  }

  // Lấy đơn nghỉ phép theo trạng thái
  Future<List<NghiPhep>> getNghiPhepByTrangThai(String trangThai) async {
    final response = await _apiService.get('$endpoint/trangthai/$trangThai');
    final List<dynamic> data = json.decode(response.body);
    return data.map((json) => NghiPhep.fromJson(json)).toList();
  }

  // Lấy đơn nghỉ phép theo nhân viên và khoảng thời gian
  Future<List<NghiPhep>> getNghiPhepByNhanVienAndKhoangThoiGian(
      int maNV, DateTime tuNgay, DateTime denNgay) async {
    final tuNgayStr = tuNgay.toIso8601String().split('T')[0];
    final denNgayStr = denNgay.toIso8601String().split('T')[0];
    final response = await _apiService.get(
        '$endpoint/nhanvien/$maNV/khoangthoi?tuNgay=$tuNgayStr&denNgay=$denNgayStr');
    final List<dynamic> data = json.decode(response.body);
    return data.map((json) => NghiPhep.fromJson(json)).toList();
  }

  // Lấy đơn nghỉ phép theo khoảng thời gian
  Future<List<NghiPhep>> getNghiPhepByKhoangThoiGian(
      DateTime tuNgay, DateTime denNgay) async {
    final tuNgayStr = tuNgay.toIso8601String().split('T')[0];
    final denNgayStr = denNgay.toIso8601String().split('T')[0];
    final response = await _apiService.get(
        '$endpoint/khoangthoi?tuNgay=$tuNgayStr&denNgay=$denNgayStr');
    final List<dynamic> data = json.decode(response.body);
    return data.map((json) => NghiPhep.fromJson(json)).toList();
  }

  // Lấy đơn nghỉ phép theo nhân viên và loại nghỉ
  Future<List<NghiPhep>> getNghiPhepByNhanVienAndLoai(
      int maNV, String loaiNghi) async {
    final response = await _apiService.get('$endpoint/nhanvien/$maNV/loai/$loaiNghi');
    final List<dynamic> data = json.decode(response.body);
    return data.map((json) => NghiPhep.fromJson(json)).toList();
  }

  // Lấy đơn nghỉ phép chờ duyệt
  Future<List<NghiPhep>> getNghiPhepChoDuyet(int nguoiDuyet) async {
    final response = await _apiService.get('$endpoint/choduyet/$nguoiDuyet');
    final List<dynamic> data = json.decode(response.body);
    return data.map((json) => NghiPhep.fromJson(json)).toList();
  }

  // Tạo đơn nghỉ phép mới
  Future<NghiPhep> createNghiPhep(NghiPhep nghiPhep) async {
    final response = await _apiService.post(endpoint, body: nghiPhep.toJson());
    return NghiPhep.fromJson(json.decode(response.body));
  }

  // Cập nhật đơn nghỉ phép
  Future<NghiPhep> updateNghiPhep(int maNghiPhep, NghiPhep nghiPhep) async {
    final response = await _apiService.put('$endpoint/$maNghiPhep', body: nghiPhep.toJson());
    return NghiPhep.fromJson(json.decode(response.body));
  }

  // Xóa đơn nghỉ phép
  Future<void> deleteNghiPhep(int maNghiPhep) async {
    await _apiService.delete('$endpoint/$maNghiPhep');
  }

  // Duyệt đơn nghỉ phép
  Future<NghiPhep> duyetNghiPhep(
      int maNghiPhep, int nguoiDuyet, bool duyet, String? ghiChu) async {
    final body = {
      'nguoiDuyet': nguoiDuyet,
      'duyet': duyet,
      'ghiChu': ghiChu ?? '',
    };
    final response = await _apiService.put('$endpoint/$maNghiPhep/duyet', body: body);
    return NghiPhep.fromJson(json.decode(response.body));
  }

  // Lấy số ngày phép đã sử dụng trong năm
  Future<int> getSoNgayPhepDaSuDung(int maNV, {int? nam}) async {
    final year = nam ?? DateTime.now().year;
    final startOfYear = DateTime(year, 1, 1);
    final endOfYear = DateTime(year, 12, 31);
    
    final danhSach = await getNghiPhepByNhanVienAndKhoangThoiGian(maNV, startOfYear, endOfYear);
    final daDuyet = danhSach.where((item) => item.isDuocDuyet).toList();
    
    return daDuyet.fold<int>(0, (sum, item) => sum + (item.soNgay ?? 0));
  }

  // Lấy đơn nghỉ phép chờ duyệt (tất cả)
  Future<List<NghiPhep>> getAllNghiPhepChoDuyet() async {
    return getNghiPhepByTrangThai('CHO_DUYET');
  }
}