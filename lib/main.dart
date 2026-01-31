import 'package:flutter/material.dart';
import 'login_page.dart';

void main() {
  runApp(const QuietSpaceApp());
}

class QuietSpaceApp extends StatelessWidget {
  const QuietSpaceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QuietSpace',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const LoginPage(),
    );
  }
}
