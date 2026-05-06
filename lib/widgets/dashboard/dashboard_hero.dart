import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app_theme.dart';

class DashboardHero extends StatelessWidget {
  final String userEmail;
  const DashboardHero({super.key, required this.userEmail});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Selamat Datang, $userEmail',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
            height: 1.2,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'Jelajahi kuliner autentik Denpasar dan dukung UMKM lokal.',
          style: GoogleFonts.publicSans(
            fontSize: 16,
            color: AppColors.onSurfaceVariant,
            height: 1.6,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
