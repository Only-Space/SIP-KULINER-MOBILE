import 'package:flutter/material.dart';
import 'package:usada_rare/pages/login_pages.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SIPKULINER',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF002045),
        ),
        scaffoldBackgroundColor: const Color(0xFFF9F9FF),
      ),
      home: const LoginPages(),
    );
  }
}
