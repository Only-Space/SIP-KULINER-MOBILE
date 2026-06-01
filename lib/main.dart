import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'app_theme.dart';
import 'package:usada_rare/pages/login_pages.dart';
import 'package:usada_rare/features/profile/pages/forgot_password_page.dart';
import 'package:usada_rare/pages/dashboard_page.dart';
import 'package:usada_rare/pages/profile_page.dart';
import 'package:usada_rare/features/profile/pages/onboarding_preferences_page.dart';
import 'package:usada_rare/features/profile/pages/register_page.dart';
import 'package:usada_rare/features/place_detail/pages/place_detail_page.dart';
import 'package:usada_rare/features/profile/pages/settings_page.dart';
import 'package:usada_rare/pages/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Status bar transparan agar gradient header mengalir mulus ke atas
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );
  
  // Load .env file as fallback for local development
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Info: .env file not found, relying on --dart-define");
  }

  const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  const supabaseKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  // Initialize Supabase (try --dart-define first, fallback to dotenv)
  await Supabase.initialize(
    url: supabaseUrl.isNotEmpty ? supabaseUrl : (dotenv.env['SUPABASE_URL'] ?? ''),
    anonKey: supabaseKey.isNotEmpty ? supabaseKey : (dotenv.env['SUPABASE_ANON_KEY'] ?? ''),
  );

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
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
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginPages(),
        '/register': (context) => const RegisterPage(),
        '/forgot-password': (context) => const ForgotPasswordPage(),
        '/dashboard': (context) => const DashboardPage(),
        '/profile': (context) => const ProfilePage(),
        '/onboarding': (context) => const OnboardingPreferencesPage(),
        '/detail': (context) => const PlaceDetailPage(),
        '/settings': (context) => const SettingsPage(),
      },
    );
  }
}
