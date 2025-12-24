import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screen/auth/login_screen.dart';
import 'screen/home/home_screen.dart';
import 'screen/biometric/biometric_setup_screen.dart';
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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/biometric-setup') {
          final nhanVien = settings.arguments as NhanVien;
          return MaterialPageRoute(
            builder: (context) => BiometricSetupScreen(nhanVien: nhanVien),
          );
        }
        return null;
      },
    );
  }
}
