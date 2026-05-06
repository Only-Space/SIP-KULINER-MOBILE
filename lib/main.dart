import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_theme.dart';
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
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          surface: AppColors.surface,
        ),
        scaffoldBackgroundColor: AppColors.surface,
        textTheme: GoogleFonts.publicSansTextTheme(),
        primaryTextTheme: GoogleFonts.plusJakartaSansTextTheme(),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPages(),
        '/forgot-password': (context) => const ForgotPasswordPage(),
        '/dashboard': (context) => const DashboardPage(),
        '/profile': (context) => const ProfilePage(),
      },
    );
  }
}
