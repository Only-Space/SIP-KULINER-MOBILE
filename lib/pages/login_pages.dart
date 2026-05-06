import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'forgot_password_page.dart';

class LoginPages extends StatefulWidget {
  const LoginPages({super.key});

  @override
  State<LoginPages> createState() => _LoginPagesState();
}

class _LoginPagesState extends State<LoginPages> {
  bool _obscurePassword = true;
  bool _rememberMe = false;

  static const Color primaryColor = Color(0xFF002045);
  static const Color secondaryColor = Color(0xFF875200);
  static const Color surfaceColor = Color(0xFFF9F9FF);
  static const Color outlineVariant = Color(0xFFC4C6CF);
  static const Color onSurfaceVariant = Color(0xFF43474E);
  static const Color primaryFixed = Color(0xFFD6E3FF);
  static const Color secondaryFixed = Color(0xFFFFDDBA);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surfaceColor,
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 700) {
                  return _buildWideLayout();
                }
                return _buildMobileLayout();
              },
            ),
          ),
        ],
      ),
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
              color: primaryFixed,
              borderRadius: BorderRadius.circular(200),
            ),
            child: const SizedBox(),
          ),
        ),
        Positioned(
          bottom: -100,
          left: -100,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              color: secondaryFixed,
              borderRadius: BorderRadius.circular(200),
            ),
            child: const SizedBox(),
          ),
        ),
      ],
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
          border: Border.all(color: outlineVariant.withValues(alpha: 0.3)),
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
                color: primaryColor,
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
                border: Border.all(color: outlineVariant.withValues(alpha: 0.3)),
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
        color: primaryColor,
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
                  colors: [Colors.transparent, primaryColor.withValues(alpha: 0.8)],
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
                    const Icon(Icons.verified_user_outlined,
                        color: secondaryFixed, size: 36),
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
                    color: primaryFixed.withValues(alpha: 0.9),
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Container(height: 4, width: 48, color: secondaryFixed),
                    const SizedBox(width: 8),
                    Container(height: 4, width: 16,
                        color: Colors.white.withValues(alpha: 0.3)),
                    const SizedBox(width: 8),
                    Container(height: 4, width: 16,
                        color: Colors.white.withValues(alpha: 0.3)),
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selamat Datang',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 36,
            fontWeight: FontWeight.w700,
            color: primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Silakan masuk untuk melanjutkan akses ke ekosistem kuliner kami.',
          style: GoogleFonts.publicSans(
            fontSize: 16,
            color: onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 40),
        _buildIdentityField(),
        const SizedBox(height: 24),
        _buildPasswordField(),
        const SizedBox(height: 16),
        _buildRememberRow(),
        const SizedBox(height: 32),
        _buildLoginButton(),
        const SizedBox(height: 32),
        _buildDivider(),
        const SizedBox(height: 24),
        _buildSignupLink(),
      ],
    );
  }

  Widget _buildIdentityField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'EMAIL ATAU NOMOR TELEPON',
          style: GoogleFonts.publicSans(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: onSurfaceVariant,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            hintText: 'Contoh: merchant@denpasar.go.id',
            hintStyle: GoogleFonts.publicSans(
              color: outlineVariant,
              fontSize: 16,
            ),
            prefixIcon: const Icon(Icons.mail_outline, color: outlineVariant),
            filled: true,
            fillColor: const Color(0xFFF0F3FA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: outlineVariant.withValues(alpha: 0.5)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: outlineVariant.withValues(alpha: 0.5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: primaryColor, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          style: GoogleFonts.publicSans(fontSize: 16),
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
            Text(
              'KATA SANDI',
              style: GoogleFonts.publicSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: onSurfaceVariant,
                letterSpacing: 0.6,
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ForgotPasswordPage(),
                  ),
                );
              },
              child: Text(
                'LUPA PASSWORD?',
                style: GoogleFonts.publicSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: primaryColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            hintText: '••••••••',
            hintStyle: GoogleFonts.publicSans(
              color: outlineVariant,
              fontSize: 16,
            ),
            prefixIcon: const Icon(Icons.lock_outline, color: outlineVariant),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: outlineVariant,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
            filled: true,
            fillColor: const Color(0xFFF0F3FA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: outlineVariant.withValues(alpha: 0.5)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: outlineVariant.withValues(alpha: 0.5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: primaryColor, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          style: GoogleFonts.publicSans(fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildRememberRow() {
    return Row(
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: Checkbox(
            value: _rememberMe,
            onChanged: (value) {
              setState(() {
                _rememberMe = value ?? false;
              });
            },
            activeColor: primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            side: BorderSide(color: outlineVariant.withValues(alpha: 0.5)),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'Ingat saya di perangkat ini',
          style: GoogleFonts.publicSans(
            fontSize: 14,
            color: onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 8,
          shadowColor: primaryColor.withValues(alpha: 0.2),
        ),
        child: Row(
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
        Expanded(child: Divider(color: outlineVariant.withValues(alpha: 0.3))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'ATAU',
            style: GoogleFonts.publicSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: outlineVariant,
            ),
          ),
        ),
        Expanded(child: Divider(color: outlineVariant.withValues(alpha: 0.3))),
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
            color: onSurfaceVariant,
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
                    color: secondaryColor,
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
              color: outlineVariant,
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
          color: outlineVariant,
        ),
      ),
    );
  }
}
