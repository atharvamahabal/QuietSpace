import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'login_page.dart';
import 'dashboard_page.dart';
import 'auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final isLoggedIn = await AuthService.isLoggedIn();
  runApp(QuietSpaceApp(isLoggedIn: isLoggedIn));
}

class QuietSpaceApp extends StatelessWidget {
  final bool isLoggedIn;

  const QuietSpaceApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QuietSpace',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: isLoggedIn ? const DashboardPage() : const LoginPage(),
    );
  }
}
