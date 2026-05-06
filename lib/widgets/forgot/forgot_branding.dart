import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app_theme.dart';

class ForgotBranding extends StatelessWidget {
  const ForgotBranding({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(40),
          ),
          child: const Icon(
            Icons.lock_reset,
            size: 40,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Lupa Password?',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 32,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: 280,
          child: Text(
            'Masukkan email terdaftar untuk menerima instruksi reset',
            style: GoogleFonts.publicSans(
              fontSize: 16,
              color: AppColors.onSurfaceVariant,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
