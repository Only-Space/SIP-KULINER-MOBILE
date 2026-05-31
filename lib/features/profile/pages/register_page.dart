import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../app_theme.dart';
import '../../../widgets/login/login_background.dart';
import '../../../widgets/login/login_email_field.dart';
import '../../../widgets/login/login_password_field.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    setState(() => _errorMessage = null);
    if (!_formKey.currentState!.validate()) return;

    if (_nameController.text.trim().isEmpty) {
      setState(() => _errorMessage = "Nama tidak boleh kosong");
      return;
    }

    setState(() => _isLoading = true);

    try {
      await Supabase.instance.client.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        data: {
          'name': _nameController.text.trim(),
          'avatar_url': '',
        },
      );
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registrasi berhasil!'),
          backgroundColor: Colors.green,
        ),
      );
      // Pindah ke login setelah sukses (atau AuthWrapper otomatis mendeteksi session baru)
      Navigator.pop(context); 
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registrasi gagal: $_errorMessage'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          const LoginBackground(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 450),
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [
                      BoxShadow(color: Color(0x1A002045), blurRadius: 32, offset: Offset(0, 16)),
                    ],
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Buat Akun',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.primary)),
                        const SizedBox(height: 8),
                        Text('Bergabunglah untuk menemukan kuliner favoritmu.',
                            style: GoogleFonts.publicSans(fontSize: 16, color: AppColors.onSurfaceVariant)),
                        const SizedBox(height: 32),
                        
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Nama Lengkap',
                            prefixIcon: const Icon(Icons.person_outline),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          validator: (value) => value == null || value.isEmpty ? 'Nama tidak boleh kosong' : null,
                        ),
                        const SizedBox(height: 16),
                        
                        LoginEmailField(controller: _emailController),
                        const SizedBox(height: 16),
                        
                        LoginPasswordField(
                          controller: _passwordController,
                          isPasswordVisible: _isPasswordVisible,
                          onVisibilityChanged: (v) => setState(() => _isPasswordVisible = v),
                        ),
                        
                        if (_errorMessage != null) ...[
                          const SizedBox(height: 12),
                          Text(_errorMessage!, style: GoogleFonts.publicSans(fontSize: 14, color: Colors.red)),
                        ],
                        
                        const SizedBox(height: 24),
                        
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleRegister,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                            ),
                            child: _isLoading 
                                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : Text('Daftar', style: GoogleFonts.publicSans(fontSize: 16, fontWeight: FontWeight.w700)),
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        Center(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('Sudah punya akun? Masuk di sini', style: GoogleFonts.publicSans(color: AppColors.secondary, fontWeight: FontWeight.w700)),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
