import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';
import '../utils/validators.dart';
import 'dashboard_page.dart';

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
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => DashboardPage(userEmail: _emailController.text),
        ),
      );
    } else {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(children: [_buildBackground(), _buildBody()]),
    );
  }

  Widget _buildBackground() {
    return Stack(
      children: [
        Positioned(
          top: -100,
          right: -100,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              color: AppColors.primaryFixed,
              borderRadius: BorderRadius.circular(200),
            ),
          ),
        ),
        Positioned(
          bottom: -100,
          left: -100,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              color: AppColors.secondaryFixed,
              borderRadius: BorderRadius.circular(200),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return constraints.maxWidth > 700
              ? _buildWideLayout()
              : _buildMobileLayout();
        },
      ),
    );
  }

  Widget _buildWideLayout() {
    return Center(
      child: Container(
        width: 1100,
        height: 700,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A002045),
              blurRadius: 64,
              offset: Offset(0, 32),
            ),
          ],
          border: Border.all(
            color: AppColors.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Expanded(child: _buildBrandingSide()),
            Expanded(child: _buildLoginForm()),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 40),
            Text(
              'SIPKULINER',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 32),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1A002045),
                    blurRadius: 32,
                    offset: Offset(0, 16),
                  ),
                ],
                border: Border.all(
                  color: AppColors.outlineVariant.withValues(alpha: 0.3),
                ),
              ),
              padding: const EdgeInsets.all(24),
              child: _buildLoginFormContent(),
            ),
            const SizedBox(height: 24),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandingSide() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          bottomLeft: Radius.circular(32),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppColors.primary.withValues(alpha: 0.8),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(48),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.verified_user_outlined,
                      color: AppColors.secondaryFixed,
                      size: 36,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'SIPKULINER',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Pusat Digitalisasi Kuliner &\nPemberdayaan UMKM Kota\nDenpasar.',
                  style: GoogleFonts.publicSans(
                    fontSize: 18,
                    color: AppColors.primaryFixed.withValues(alpha: 0.9),
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Container(
                      height: 4,
                      width: 48,
                      color: AppColors.secondaryFixed,
                    ),
                    const SizedBox(width: 8),
                    Container(
                      height: 4,
                      width: 16,
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      height: 4,
                      width: 16,
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 48),
      child: _buildLoginFormContent(),
    );
  }

  Widget _buildLoginFormContent() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selamat Datang',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 36,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Silakan masuk untuk melanjutkan akses ke ekosistem kuliner kami.',
            style: GoogleFonts.publicSans(
              fontSize: 16,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 40),
          _buildEmailField(),
          const SizedBox(height: 24),
          _buildPasswordField(),
          if (_errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              _errorMessage!,
              style: GoogleFonts.publicSans(fontSize: 14, color: Colors.red),
            ),
          ],
          const SizedBox(height: 16),
          _buildRememberRow(),
          const SizedBox(height: 32),
          _buildLoginButton(),
          const SizedBox(height: 32),
          _buildDivider(),
          const SizedBox(height: 24),
          _buildSignupLink(),
        ],
      ),
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('EMAIL ATAU NOMOR TELEPON'),
        const SizedBox(height: 8),
        TextFormField(
          controller: _emailController,
          validator: FormValidators.validateEmail,
          decoration: _inputDecoration(
            hint: 'Contoh: merchant@denpasar.go.id',
            icon: Icons.mail_outline,
          ),
          style: GoogleFonts.publicSans(fontSize: 16),
          keyboardType: TextInputType.emailAddress,
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildLabel('KATA SANDI'),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/forgot-password'),
              child: Text(
                'LUPA PASSWORD?',
                style: GoogleFonts.publicSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _passwordController,
          obscureText: !_isPasswordVisible,
          validator: FormValidators.validatePassword,
          decoration: _inputDecoration(
            hint: '••••••••',
            icon: Icons.lock_outline,
            suffix: IconButton(
              icon: Icon(
                _isPasswordVisible
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: AppColors.outlineVariant,
              ),
              onPressed: () =>
                  setState(() => _isPasswordVisible = !_isPasswordVisible),
            ),
          ),
          style: GoogleFonts.publicSans(fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.publicSans(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: AppColors.onSurfaceVariant,
        letterSpacing: 0.6,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.publicSans(
        color: AppColors.outlineVariant,
        fontSize: 16,
      ),
      prefixIcon: Icon(icon, color: AppColors.outlineVariant),
      suffixIcon: suffix,
      filled: true,
      fillColor: AppColors.surfaceContainerLow,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: AppColors.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: AppColors.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  Widget _buildRememberRow() {
    return Row(
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: Checkbox(
            value: false,
            onChanged: (value) {},
            activeColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            side: BorderSide(
              color: AppColors.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'Ingat saya di perangkat ini',
          style: GoogleFonts.publicSans(
            fontSize: 14,
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 8,
          shadowColor: AppColors.primary.withValues(alpha: 0.2),
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.6),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Masuk',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward, size: 20),
                ],
              ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: AppColors.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'ATAU',
            style: GoogleFonts.publicSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.outlineVariant,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: AppColors.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
      ],
    );
  }

  Widget _buildSignupLink() {
    return Center(
      child: RichText(
        text: TextSpan(
          text: 'Belum memiliki akun? ',
          style: GoogleFonts.publicSans(
            fontSize: 16,
            color: AppColors.onSurfaceVariant,
          ),
          children: [
            WidgetSpan(
              child: GestureDetector(
                onTap: () {},
                child: Text(
                  'Daftar Sekarang',
                  style: GoogleFonts.publicSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.secondary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        children: [
          Text(
            '© 2024 SIPKULINER DENPASAR. DUKUNG LOKAL UMKM.',
            style: GoogleFonts.publicSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.outlineVariant,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _footerLink('PRIVACY POLICY'),
              const SizedBox(width: 24),
              _footerLink('TERMS OF SERVICE'),
              const SizedBox(width: 24),
              _footerLink('CONTACT US'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _footerLink(String text) {
    return GestureDetector(
      onTap: () {},
      child: Text(
        text,
        style: GoogleFonts.publicSans(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.outlineVariant,
        ),
      ),
    );
  }
}
