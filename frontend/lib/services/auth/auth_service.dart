import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../model/nhanvien/nhan_vien.dart';

class AuthService {
  static const String _tokenKey = 'jwt_token';
  static const String _userKey = 'user_data';

  /// Lưu JWT token và thông tin user
  Future<void> saveLoginData(String token, NhanVien nhanVien) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userKey, json.encode(nhanVien.toJson()));
  }

  /// Lấy JWT token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// Lấy thông tin user đã lưu
  Future<NhanVien?> getSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    
    if (userJson != null) {
      try {
        return NhanVien.fromJson(json.decode(userJson));
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Kiểm tra user đã đăng nhập chưa
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Xóa toàn bộ dữ liệu đăng nhập (logout)
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  /// Lấy cả token và user info
  Future<Map<String, dynamic>?> getLoginData() async {
    final token = await getToken();
    final user = await getSavedUser();
    
    if (token != null && user != null) {
      return {
        'token': token,
        'user': user,
      };
    }
    return null;
  }

  /// Cập nhật thông tin user (giữ nguyên token)
  Future<void> updateUserData(NhanVien nhanVien) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, json.encode(nhanVien.toJson()));
  }
}
