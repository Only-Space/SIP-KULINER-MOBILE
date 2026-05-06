import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  static const Color primaryColor = Color(0xFF002045);
  static const Color secondaryColor = Color(0xFF875200);
  static const Color surfaceColor = Color(0xFFF9F9FF);
  static const Color outlineVariant = Color(0xFFC4C6CF);
  static const Color onSurfaceVariant = Color(0xFF43474E);
  static const Color surfaceContainerHighest = Color(0xFFD9E3F9);
  static const Color surfaceContainerLow = Color(0xFFF0F3FA);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surfaceColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                children: [
                  _buildBranding(),
                  const SizedBox(height: 40),
                  _buildRecoveryForm(),
                  const SizedBox(height: 48),
                  _buildDecorativeCards(),
                  const SizedBox(height: 48),
                  _buildFooter(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBranding() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: surfaceContainerHighest,
            borderRadius: BorderRadius.circular(40),
          ),
          child: const Icon(
            Icons.lock_reset,
            size: 40,
            color: primaryColor,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Lupa Password?',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 32,
            fontWeight: FontWeight.w600,
            color: primaryColor,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: 280,
          child: Text(
            'Masukkan email terdaftar untuk menerima instruksi reset',
            style: GoogleFonts.publicSans(
              fontSize: 16,
              color: onSurfaceVariant,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildRecoveryForm() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: outlineVariant),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ALAMAT EMAIL',
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
              hintText: 'nama@email.com',
              hintStyle: GoogleFonts.publicSans(
                color: outlineVariant,
                fontSize: 16,
              ),
              prefixIcon: const Icon(Icons.mail_outline, color: outlineVariant),
              filled: true,
              fillColor: surfaceContainerLow,
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
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 4),
          Text(
            'Kami akan mengirimkan tautan verifikasi ke email ini.',
            style: GoogleFonts.publicSans(
              fontSize: 12,
              color: onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                shadowColor: primaryColor.withValues(alpha: 0.2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Kirim Instruksi',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.send, size: 18),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          Divider(color: outlineVariant.withValues(alpha: 0.3)),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.arrow_back, size: 16, color: primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Kembali ke Login',
                  style: GoogleFonts.publicSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDecorativeCards() {
    return Row(
      children: [
        Expanded(
          child: _infoCard(
            icon: Icons.verified_user,
            label: 'KEAMANAN',
            description: 'Enkripsi tingkat bank untuk data Anda.',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _infoCard(
            icon: Icons.support_agent,
            label: 'BANTUAN',
            description: 'Hubungi pusat bantuan 24/7 kami.',
          ),
        ),
      ],
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String label,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: secondaryColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.publicSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: onSurfaceVariant,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.publicSans(
                    fontSize: 12,
                    height: 1.3,
                    color: onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'SIPKULINER',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          '© 2024 SIPKULINER Denpasar. Supporting Local UMKM.',
          style: GoogleFonts.publicSans(
            fontSize: 11,
            color: outlineVariant,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _footerLink('Privacy Policy'),
            const SizedBox(width: 24),
            _footerLink('Terms of Service'),
            const SizedBox(width: 24),
            _footerLink('Contact Us'),
          ],
        ),
      ],
    );
  }

  Widget _footerLink(String text) {
    return GestureDetector(
      onTap: () {},
      child: Text(
        text,
        style: GoogleFonts.publicSans(
          fontSize: 11,
          color: outlineVariant,
        ),
      ),
    );
  }
}
