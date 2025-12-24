import 'dart:convert';
import '../../model/vaitro/vai_tro.dart';
import '../api/api_service.dart';

class VaiTroService {
  final ApiService _apiService = ApiService();
  final String endpoint = '/api/v1/vaitro';

  // Thêm vai trò mới
  Future<VaiTro> themVaiTro(VaiTro vaiTro) async {
    final response = await _apiService.post(endpoint, body: vaiTro.toJson());
    return VaiTro.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
  }

  // Lấy danh sách vai trò
  Future<List<VaiTro>> layDanhSachVaiTro() async {
    final response = await _apiService.get(endpoint);
    List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
    return data.map((json) => VaiTro.fromJson(json)).toList();
  }

  // Cập nhật vai trò
  Future<VaiTro> capNhatVaiTro(int id, VaiTro vaiTro) async {
    final body = vaiTro.toJson();
    if (vaiTro.daXoa != null) {
      body['daXoa'] = vaiTro.daXoa;
    }
    final response = await _apiService.put('$endpoint/$id', body: body);
    return VaiTro.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
  }

  // Xóa vai trò
  Future<void> xoaVaiTro(int id) async {
    await _apiService.delete('$endpoint/$id');
  }

  // Khôi phục vai trò
  Future<void> khoiPhucVaiTro(int id) async {
    await _apiService.put('$endpoint/restore/$id');
  }

  // Xóa cứng vai trò (hard delete)
  Future<void> hardDeleteVaiTro(int id) async {
    await _apiService.delete('$endpoint/$id/hard');
  }
}
