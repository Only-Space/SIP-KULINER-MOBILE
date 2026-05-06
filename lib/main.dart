import 'package:flutter/material.dart';
import 'package:usada_rare/pages/login_pages.dart';
import 'package:usada_rare/pages/forgot_password_page.dart';
import 'package:usada_rare/pages/dashboard_page.dart';
import 'package:usada_rare/pages/profile_page.dart';

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
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPages(),
        '/forgot-password': (context) => const ForgotPasswordPage(),
        '/dashboard': (context) => const DashboardPage(userEmail: 'Guest'),
        '/profile': (context) => const ProfilePage(),
      },
    );
  }
}
