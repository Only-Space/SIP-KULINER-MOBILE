import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app_theme.dart';

class DashboardSearch extends StatelessWidget {
  const DashboardSearch({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(9999),
        border: Border.all(color: AppColors.outlineVariant),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Cari kuliner...',
          hintStyle: GoogleFonts.publicSans(
            color: AppColors.outlineVariant,
            fontSize: 16,
          ),
          prefixIcon: const Icon(Icons.search, color: AppColors.onSurfaceVariant),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        style: GoogleFonts.publicSans(fontSize: 16),
      ),
    );
  }
}
