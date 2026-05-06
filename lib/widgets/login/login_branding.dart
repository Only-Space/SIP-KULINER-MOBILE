import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app_theme.dart';

class LoginBranding extends StatelessWidget {
  const LoginBranding({super.key});

  @override
  Widget build(BuildContext context) {
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
                    const Icon(Icons.verified_user_outlined,
                        color: AppColors.secondaryFixed, size: 36),
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
                    Container(height: 4, width: 48, color: AppColors.secondaryFixed),
                    const SizedBox(width: 8),
                    Container(
                        height: 4,
                        width: 16,
                        color: Colors.white.withValues(alpha: 0.3)),
                    const SizedBox(width: 8),
                    Container(
                        height: 4,
                        width: 16,
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
}
