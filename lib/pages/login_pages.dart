import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';
import 'dashboard_page.dart';
import '../widgets/login/login_background.dart';
import '../widgets/login/login_responsive_layout.dart';

class LoginPages extends StatefulWidget {
  const LoginPages({super.key});

  @override
  State<LoginPages> createState() => _LoginPagesState();
}

class _LoginPagesState extends State<LoginPages> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isPasswordVisible = false;
  String? _errorMessage;

  static const _mockEmail = 'admin@test.com';
  static const _mockPassword = 'Admin123';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() => _errorMessage = null);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    if (_emailController.text == _mockEmail &&
        _passwordController.text == _mockPassword) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => DashboardPage(userEmail: _emailController.text),
          ),
        );
      }
    } else {
      if (mounted) {
        setState(() {
          _errorMessage = 'Email atau password salah';
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Login gagal: $_errorMessage',
              style: GoogleFonts.publicSans(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(children: [
        const LoginBackground(),
        LoginResponsiveLayout(
          formKey: _formKey,
          emailController: _emailController,
          passwordController: _passwordController,
          isLoading: _isLoading,
          isPasswordVisible: _isPasswordVisible,
          errorMessage: _errorMessage,
          onLogin: _handleLogin,
          onPasswordVisibilityChanged: (v) =>
              setState(() => _isPasswordVisible = v),
        ),
      ]),
    );
  }
}
