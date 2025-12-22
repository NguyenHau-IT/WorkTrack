import 'package:flutter/material.dart';
import '../../services/nhan_vien/nhan_vien_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final NhanVienService _nhanVienService = NhanVienService();

  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _usernameController.text = 'admin';
    _passwordController.text = 'admin123';
  }

  Future<void> _login() async {
    setState(() {
      _errorMessage = null;
    });

    try {
      if (_usernameController.text == 'admin' &&
          _passwordController.text == 'admin123') {
        // Default admin login
        Navigator.pushReplacementNamed(context, '/home', arguments: 'Default Admin');
      } else {
        // Check NhanVien table for other credentials
        final nhanVien = await _nhanVienService.login(
          _usernameController.text,
          _passwordController.text,
        );
        Navigator.pushReplacementNamed(context, '/home', arguments: nhanVien);
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
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
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
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
              onPressed: _login,
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}