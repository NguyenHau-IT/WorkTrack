import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screen/auth/login_screen.dart';
import 'screen/home/admin_home_screen.dart';
import 'screen/home/manager_home_screen.dart';
import 'screen/home/employee_home_screen.dart'; // Import mới
import 'screen/nhan_vien/cap_nhat_nhan_vien_screen.dart'; // Import mới
import 'screen/biometric/biometric_setup_screen.dart';
// Import mới
import 'model/nhanvien/nhan_vien.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WorkTrack',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
        ),
      ),
      initialRoute: '/login',
      onGenerateRoute: (settings) {
        // Xử lý các route động ở đây
        switch (settings.name) {
          case '/login':
            return MaterialPageRoute(builder: (_) => const LoginScreen());

          case '/home':
            final user = settings.arguments as NhanVien;
            // Phân luồng dựa trên vai trò của người dùng
            if (user.isAdmin) {
              return MaterialPageRoute(builder: (_) => AdminHomeScreen(admin: user));
            } else if (user.isManager) {
              return MaterialPageRoute(builder: (_) => ManagerHomeScreen(manager: user));
            } else {
              return MaterialPageRoute(builder: (_) => EmployeeHomeScreen(employee: user));
            }

          case '/cap-nhat-nhan-vien':
             final args = settings.arguments as Map<String, dynamic>;
             final nhanVien = args['nhanVien'] as NhanVien;
             final currentUser = args['currentUser'] as NhanVien?;
             return MaterialPageRoute(
               builder: (_) => CapNhatNhanVienScreen(
                 nhanVien: nhanVien,
                 currentUser: currentUser,
               ),
             );

          case '/biometric-setup':
            final nhanVien = settings.arguments as NhanVien;
            return MaterialPageRoute(
              builder: (context) => BiometricSetupScreen(nhanVien: nhanVien),
            );

          default:
            // Nếu không tìm thấy route, có thể hiển thị trang lỗi
            return MaterialPageRoute(
              builder: (_) => Scaffold(
                body: Center(
                  child: Text('Không tìm thấy trang: ${settings.name}'),
                ),
              ),
            );
        }
      },
      // Xóa routes tĩnh để ưu tiên onGenerateRoute
      // routes: {
      //   '/login': (context) => LoginScreen(),
      //   '/home': (context) => HomeScreen(),
      // },
    );
  }
}
