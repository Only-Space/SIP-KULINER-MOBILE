import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app_theme.dart';

class LoginFooter extends StatelessWidget {
  const LoginFooter({super.key});

  @override
  Widget build(BuildContext context) {
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
