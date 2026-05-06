import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app_theme.dart';

class ForgotCards extends StatelessWidget {
  const ForgotCards({super.key});

  @override
  Widget build(BuildContext context) {
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
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: AppColors.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.secondary, size: 24),
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
                    color: AppColors.onSurfaceVariant,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.publicSans(
                    fontSize: 12,
                    height: 1.3,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
