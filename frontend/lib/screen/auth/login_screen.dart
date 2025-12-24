import 'package:flutter/material.dart';
import '../../services/nhan_vien/nhan_vien_service.dart';
import '../../services/auth/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final NhanVienService _nhanVienService = NhanVienService();
  final AuthService _authService = AuthService();

  String? _errorMessage;
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkAutoLogin();
  }

  /// Kiểm tra auto-login khi mở app
  Future<void> _checkAutoLogin() async {
    final loginData = await _authService.getLoginData();
    if (loginData != null && mounted) {
      // Đã có dữ liệu đăng nhập, chuyển sang home
      Navigator.pushReplacementNamed(
        context, 
        '/home', 
        arguments: loginData['user']
      );
    }
  }

  Future<void> _login() async {
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    try {
      // Gọi API login và nhận token + user
      final loginData = await _nhanVienService.login(
        _usernameController.text,
        _passwordController.text,
      );
      
      // Lưu token và user vào shared_preferences
      await _authService.saveLoginData(
        loginData['token'],
        loginData['nhanVien'],
      );
      
      if (mounted) {
        Navigator.pushReplacementNamed(
          context, 
          '/home', 
          arguments: loginData['nhanVien']
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Đăng nhập thất bại. Vui lòng kiểm tra lại tên đăng nhập và mật khẩu.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 16.0),
            if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: TextStyle(color: Colors.red),
              ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _isLoading ? null : _login,
              child: _isLoading 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}