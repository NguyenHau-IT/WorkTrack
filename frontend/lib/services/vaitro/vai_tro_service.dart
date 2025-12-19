import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../model/vaitro/vai_tro.dart';

class VaiTroService {
  static const String baseUrl = 'http://192.168.1.100:8080/api/v1/vaitro'; // Android Emulator

  // Thêm vai trò mới
  Future<VaiTro> themVaiTro(VaiTro vaiTro) async {
    try {
      print('Đang gửi request đến: $baseUrl');
      final response = await http
          .post(
            Uri.parse(baseUrl),
            headers: {
              'Content-Type': 'application/json; charset=UTF-8',
              'Accept': 'application/json',
              // Thêm token nếu backend yêu cầu authentication:
              // 'Authorization': 'Bearer YOUR_TOKEN',
            },
            body: jsonEncode(vaiTro.toJson()),
          )
          .timeout(const Duration(seconds: 10));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return VaiTro.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
      } else if (response.statusCode == 403) {
        throw Exception('Lỗi 403 - Không có quyền truy cập!\n'
            'Nguyên nhân có thể:\n'
            '1. Spring Security đang bật - cần tắt hoặc cấu hình CORS\n'
            '2. CSRF protection đang bật\n'
            '3. Cần authentication token\n'
            'Chi tiết: ${response.body}');
      } else {
        throw Exception('Lỗi từ server (${response.statusCode}): ${response.body}');
      }
    } on SocketException catch (e) {
      throw Exception('Không thể kết nối tới server. Kiểm tra:\n'
          '1. Backend có đang chạy không?\n'
          '2. URL có đúng không? ($baseUrl)\n'
          '3. Firewall có chặn không?\n'
          'Chi tiết: $e');
    } on http.ClientException catch (e) {
      throw Exception('Lỗi kết nối: $e');
    } on FormatException catch (e) {
      throw Exception('Lỗi định dạng dữ liệu: $e');
    } catch (e) {
      throw Exception('Lỗi không xác định: $e');
    }
  }

  // Lấy danh sách vai trò
  Future<List<VaiTro>> layDanhSachVaiTro() async {
    try {
      print('Đang lấy danh sách từ: $baseUrl');
      final response = await http
          .get(
            Uri.parse(baseUrl),
            headers: {
              'Accept': 'application/json',
              // Thêm token nếu backend yêu cầu authentication:
              // 'Authorization': 'Bearer YOUR_TOKEN',
            },
          )
          .timeout(const Duration(seconds: 10));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        print('Đã tải ${data.length} vai trò');
        return data.map((json) => VaiTro.fromJson(json)).toList();
      } else if (response.statusCode == 403) {
        throw Exception('Lỗi 403 - Không có quyền truy cập!\n'
            'Nguyên nhân có thể:\n'
            '1. Spring Security đang bật - cần tắt hoặc cấu hình CORS\n'
            '2. CSRF protection đang bật\n'
            '3. Cần authentication token\n'
            'Chi tiết: ${response.body}');
      } else {
        throw Exception('Lỗi từ server (${response.statusCode}): ${response.body}');
      }
    } on SocketException catch (e) {
      throw Exception('Không thể kết nối tới server. Kiểm tra:\n'
          '1. Backend có đang chạy không?\n'
          '2. URL có đúng không? ($baseUrl)\n'
          '3. Firewall có chặn không?\n'
          'Chi tiết: $e');
    } on http.ClientException catch (e) {
      throw Exception('Lỗi kết nối: $e');
    } on FormatException catch (e) {
      throw Exception('Lỗi định dạng dữ liệu: $e');
    } catch (e) {
      throw Exception('Lỗi không xác định: $e');
    }
  }

  // Cập nhật vai trò
  Future<VaiTro> capNhatVaiTro(int id, VaiTro vaiTro) async {
    try {
      print('Đang cập nhật vai trò ID $id tại: $baseUrl/$id');
      final body = vaiTro.toJson();
      // Đảm bảo luôn gửi cả trường daXoa khi cập nhật
      if (vaiTro.daXoa != null) {
        body['daXoa'] = vaiTro.daXoa;
      }
      final response = await http
          .put(
            Uri.parse('$baseUrl/$id'),
            headers: {
              'Content-Type': 'application/json; charset=UTF-8',
              'Accept': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 10));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return VaiTro.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
      } else if (response.statusCode == 403) {
        throw Exception('Lỗi 403 - Không có quyền cập nhật!');
      } else if (response.statusCode == 404) {
        throw Exception('Không tìm thấy vai trò với ID: $id');
      } else {
        throw Exception('Lỗi từ server (${response.statusCode}): ${response.body}');
      }
    } on SocketException catch (e) {
      throw Exception('Không thể kết nối tới server: $e');
    } on http.ClientException catch (e) {
      throw Exception('Lỗi kết nối: $e');
    } catch (e) {
      throw Exception('Lỗi không xác định: $e');
    }
  }

  // Xóa vai trò
  Future<void> xoaVaiTro(int id) async {
    try {
      print('Đang xóa vai trò ID $id tại: $baseUrl/$id');
      final response = await http
          .delete(
            Uri.parse('$baseUrl/$id'),
            headers: {
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      print('Response status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('Xóa vai trò thành công');
      } else if (response.statusCode == 403) {
        throw Exception('Lỗi 403 - Không có quyền xóa!');
      } else if (response.statusCode == 404) {
        throw Exception('Không tìm thấy vai trò với ID: $id');
      } else {
        throw Exception('Lỗi từ server (${response.statusCode}): ${response.body}');
      }
    } on SocketException catch (e) {
      throw Exception('Không thể kết nối tới server: $e');
    } on http.ClientException catch (e) {
      throw Exception('Lỗi kết nối: $e');
    } catch (e) {
      throw Exception('Lỗi không xác định: $e');
    }
  }

// Khôi phục vai trò
  Future<void> khoiPhucVaiTro(int id) async {
    try {
      print('Đang khôi phục vai trò ID $id tại: $baseUrl/restore/$id');
      final response = await http
          .put(
            Uri.parse('$baseUrl/restore/$id'),
            headers: {
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      print('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('Khôi phục vai trò thành công');
      } else if (response.statusCode == 403) {
        throw Exception('Lỗi 403 - Không có quyền khôi phục!');
      } else if (response.statusCode == 404) {
        throw Exception('Không tìm thấy vai trò với ID: $id');
      } else {
        throw Exception('Lỗi từ server (${response.statusCode}): ${response.body}');
      }
    } on SocketException catch (e) {
      throw Exception('Không thể kết nối tới server: $e');
    } on http.ClientException catch (e) {
      throw Exception('Lỗi kết nối: $e');
    } catch (e) {
      throw Exception('Lỗi không xác định: $e');
    }
  }
}
