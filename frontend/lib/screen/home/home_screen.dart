import 'package:flutter/material.dart';
import '../vaitro/danh_sach_vai_tro_screen.dart';
import '../nhan_vien/danh_sach_nhan_vien_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
              child: const Text('Login'),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                final arguments = ModalRoute.of(context)?.settings.arguments;
                if (arguments != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DanhSachVaiTroScreen(),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please login first to access Manage Roles!'),
                    ),
                  );
                }
              },
              child: const Text('Manage Roles'),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DanhSachNhanVienScreen(),
                  ),
                );
              },
              child: const Text('Employee List'),
            ),
          ],
        ),
      ),
    );
  }
}