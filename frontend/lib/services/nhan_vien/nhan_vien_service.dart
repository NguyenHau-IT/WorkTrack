import 'dart:convert';
import '../api/api_service.dart';
import '../../model/nhanvien/nhan_vien.dart';

class NhanVienService {
  final ApiService _apiService = const ApiService();
  final String endpoint = '/api/v1/nhanvien';

  Future<List<NhanVien>> getAllNhanVien() async {
    final response = await _apiService.get(endpoint);
    final List<dynamic> data = json.decode(response.body);
    return data.map((json) => NhanVien.fromJson(json)).toList();
  }

  Future<NhanVien> getNhanVienById(int maNV) async {
    final response = await _apiService.get('$endpoint/$maNV');
    return NhanVien.fromJson(json.decode(response.body));
  }

  Future<NhanVien> createNhanVien(NhanVien nhanVien) async {
    final response = await _apiService.post(endpoint, body: nhanVien.toJson());
    return NhanVien.fromJson(json.decode(response.body));
  }

  Future<NhanVien> updateNhanVien(int maNV, NhanVien nhanVien) async {
    final response = await _apiService.put('$endpoint/$maNV', body: nhanVien.toJson());
    return NhanVien.fromJson(json.decode(response.body));
  }

  Future<void> deleteNhanVien(int maNV) async {
    await _apiService.delete('$endpoint/$maNV');
  }

  Future<bool> checkEmailExists(String email) async {
    final response = await _apiService.get('$endpoint/check-email/$email');
    return json.decode(response.body)['exists'];
  }

  Future<bool> checkTheNFCExists(String theNFC) async {
    final response = await _apiService.get('$endpoint/check-nfc/$theNFC');
    return json.decode(response.body)['exists'];
  }

  Future<NhanVien> login(String tenDangNhap, String matKhau) async {
    final response = await _apiService.post('$endpoint/login', body: {
      'tenDangNhap': tenDangNhap,
      'matKhau': matKhau,
    });
    return NhanVien.fromJson(json.decode(response.body)['nhanVien']);
  }

  Future<void> changePassword(String tenDangNhap, String oldPassword, String newPassword) async {
    await _apiService.put('$endpoint/change-password', body: {
      'tenDangNhap': tenDangNhap,
      'oldPassword': oldPassword,
      'newPassword': newPassword,
    });
  }

  Future<void> forgotPassword(String email, String newPassword) async {
    await _apiService.post('$endpoint/forgot-password', body: {
      'email': email,
      'newPassword': newPassword,
    });
  }

  Future<void> logout() async {
    await _apiService.post('$endpoint/logout');
  }
}