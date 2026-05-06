import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app_theme.dart';

class ForgotFooter extends StatelessWidget {
  const ForgotFooter({super.key});

  @override
  Widget build(BuildContext context) {
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
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          '© 2024 SIPKULINER Denpasar. Supporting Local UMKM.',
          style: GoogleFonts.publicSans(
            fontSize: 11,
            color: AppColors.outlineVariant,
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
          color: AppColors.outlineVariant,
        ),
      ),
    );
  }
}
