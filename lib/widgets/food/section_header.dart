import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app_theme.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeMap;

  const SectionHeader({
    super.key,
    required this.title,
    this.onSeeMap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
            height: 1.3,
          ),
        ),
        if (onSeeMap != null)
          GestureDetector(
            onTap: onSeeMap,
            child: Text(
              'Lihat Peta',
              style: GoogleFonts.publicSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.secondary,
              ),
            ),
          ),
      ],
    );
  }
}
