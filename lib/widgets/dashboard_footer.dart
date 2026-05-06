import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';

class DashboardFooter extends StatelessWidget {
  const DashboardFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 32),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        border: Border(top: BorderSide(color: AppColors.outlineVariant)),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SIPKULINER',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Platform resmi katalog kuliner dan pemberdayaan UMKM lokal Kota Denpasar. Menghubungkan pecinta kuliner dengan cita rasa autentik.',
                      style: GoogleFonts.publicSans(
                        fontSize: 14,
                        color: AppColors.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '© 2024 SIPKULINER Denpasar. Supporting Local UMKM.',
                      style: GoogleFonts.publicSans(
                        fontSize: 11,
                        color: AppColors.outlineVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 32),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _footerTitle('INFORMASI'),
                    const SizedBox(height: 12),
                    _footerLink('Privacy Policy'),
                    const SizedBox(height: 8),
                    _footerLink('Terms of Service'),
                  ],
                ),
              ),
              const SizedBox(width: 32),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _footerTitle('BANTUAN'),
                    const SizedBox(height: 12),
                    _footerLink('Merchant Helpdesk'),
                    const SizedBox(height: 8),
                    _footerLink('Contact Us'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _footerTitle(String text) {
    return Text(
      text,
      style: GoogleFonts.publicSans(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
        letterSpacing: 0.6,
      ),
    );
  }

  Widget _footerLink(String text) {
    return GestureDetector(
      onTap: () {},
      child: Text(
        text,
        style: GoogleFonts.publicSans(
          fontSize: 14,
          color: AppColors.onSurfaceVariant,
        ),
      ),
    );
  }
}
