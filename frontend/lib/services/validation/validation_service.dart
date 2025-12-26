import 'dart:convert';
import '../api/api_service.dart';

class ValidationService {
  final ApiService _apiService = ApiService();
  static const String endpoint = '/nhanvien';
  static const String utilEndpoint = '/util';

  // Validate thông tin nhân viên
  Future<Map<String, dynamic>> validateNhanVien(Map<String, dynamic> nhanVien, {int? existingMaNV}) async {
    String url = '$endpoint/validate';
    if (existingMaNV != null) {
      url += '?existingMaNV=${existingMaNV.toString()}';
    }
    final response = await _apiService.post(url, body: nhanVien);
    return json.decode(response.body);
  }

  // Validate email
  Future<Map<String, dynamic>> validateEmail(String email) async {
    final response = await _apiService.get('$endpoint/validate-email/$email');
    return json.decode(response.body);
  }

  // Validate số điện thoại
  Future<Map<String, dynamic>> validatePhoneNumber(String phoneNumber) async {
    final response = await _apiService.get('$endpoint/validate-phone/$phoneNumber');
    return json.decode(response.body);
  }

  // Validate số điện thoại Việt Nam (sử dụng util API)
  Future<Map<String, dynamic>> validateVietnamesePhone(String phoneNumber) async {
    final response = await _apiService.post(
      '$utilEndpoint/validate-phone',
      body: {'phone': phoneNumber},
    );
    return json.decode(response.body);
  }

  // Format tiền tệ
  Future<Map<String, dynamic>> formatCurrency(double amount) async {
    final response = await _apiService.post(
      '$utilEndpoint/format-currency',
      body: {'amount': amount},
    );
    return json.decode(response.body);
  }

  // Tính số ngày giữa hai ngày
  Future<Map<String, dynamic>> calculateDaysBetween(DateTime fromDate, DateTime toDate) async {
    final response = await _apiService.post(
      '$utilEndpoint/calculate-days',
      body: {
        'fromDate': fromDate.toIso8601String().split('T')[0],
        'toDate': toDate.toIso8601String().split('T')[0],
      },
    );
    return json.decode(response.body);
  }

  // Format ngày giờ
  Future<Map<String, dynamic>> formatDateTime(DateTime dateTime, {String pattern = 'dd/MM/yyyy HH:mm'}) async {
    final response = await _apiService.post(
      '$utilEndpoint/format-datetime',
      body: {
        'datetime': dateTime.toIso8601String(),
        'pattern': pattern,
      },
    );
    return json.decode(response.body);
  }

  // Lấy thời gian hiện tại
  Future<Map<String, dynamic>> getCurrentTime() async {
    final response = await _apiService.get('$utilEndpoint/current-time');
    return json.decode(response.body);
  }

  // Tính phần trăm
  Future<Map<String, dynamic>> calculatePercentage(double part, double total) async {
    final response = await _apiService.post(
      '$utilEndpoint/calculate-percentage',
      body: {
        'part': part,
        'total': total,
      },
    );
    return json.decode(response.body);
  }

  // Client-side validation helpers (backup cho khi không có internet)
  bool isValidEmailFormat(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  bool isValidPhoneFormat(String phone) {
    final phoneRegex = RegExp(r'^[0-9]{10,11}$');
    return phoneRegex.hasMatch(phone);
  }

  String formatCurrencyLocal(double amount) {
    return '${amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    )} ₫';
  }
}