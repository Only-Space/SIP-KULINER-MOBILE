import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';
import 'dashboard_page.dart';
import '../widgets/login/login_background.dart';
import '../widgets/login/login_responsive_layout.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    try {
      final res = await Supabase.instance.client.auth.signInWithPassword(
          email: email,
          password: password,
        );
        
        if (!mounted) return;
        
        if (res.session != null) {
          // Tampilkan pop up sukses
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Login berhasil! Mengambil data...'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 1),
            ),
          );

          final prefs = await Supabase.instance.client
              .from('preferences')
              .select()
              .eq('user_id', res.session!.user.id)
              .maybeSingle();
              
          if (!mounted) return;
          
          if (prefs == null) {
            Navigator.pushReplacementNamed(context, '/onboarding');
          } else {
            Navigator.pushReplacementNamed(context, '/dashboard');
          }
        } else {
          // Tambahkan notifikasi jika session ternyata null
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Login berhasil, namun session kosong (Membutuhkan verifikasi lanjutan)'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } on AuthException catch (e) {
        if (mounted) {
          String userFriendlyMessage = 'Terjadi kesalahan saat masuk.';
          final msg = e.message.toLowerCase();
          
          if (msg.contains('invalid login credentials')) {
            userFriendlyMessage = 'Email atau kata sandi salah.';
          } else if (msg.contains('email not confirmed')) {
            userFriendlyMessage = 'Silakan verifikasi email Anda terlebih dahulu.';
          } else {
            userFriendlyMessage = e.message;
          }

          setState(() {
            _errorMessage = userFriendlyMessage;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                userFriendlyMessage,
                style: GoogleFonts.publicSans(color: Colors.white),
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _errorMessage = 'Terjadi kesalahan sistem.';
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Terjadi kesalahan sistem.',
                style: GoogleFonts.publicSans(color: Colors.white),
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } finally {
      if (mounted) {
        setState(() => _isLoading = false);
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
