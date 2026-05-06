import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app_theme.dart';
import 'dashboard_footer_link.dart';

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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 2, child: _brandColumn()),
          const SizedBox(width: 32),
          Expanded(child: _linkColumn('INFORMASI', ['Privacy Policy', 'Terms of Service'])),
          const SizedBox(width: 32),
          Expanded(child: _linkColumn('BANTUAN', ['Merchant Helpdesk', 'Contact Us'])),
        ],
      ),
    );
  }

  Widget _brandColumn() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('SIPKULINER',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.primary)),
          const SizedBox(height: 12),
          Text(
            'Platform resmi katalog kuliner dan pemberdayaan UMKM lokal Kota Denpasar. Menghubungkan pecinta kuliner dengan cita rasa autentik.',
            style: GoogleFonts.publicSans(
              fontSize: 14, color: AppColors.onSurfaceVariant, height:1.5),
          ),
          const SizedBox(height: 16),
          Text('© 2024 SIPKULINER Denpasar. Supporting Local UMKM.',
              style: GoogleFonts.publicSans(fontSize: 11, color: AppColors.outlineVariant)),
        ],
      );

  Widget _linkColumn(String title, List<String> links) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FooterTitle(title),
          const SizedBox(height: 12),
          ...links.map((l) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: FooterLink(l),
              )),
        ],
      );
}
