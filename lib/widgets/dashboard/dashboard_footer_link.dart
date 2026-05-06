import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app_theme.dart';

class FooterTitle extends StatelessWidget {
  final String text;
  const FooterTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(text,
      style: GoogleFonts.publicSans(
        fontSize: 12, fontWeight: FontWeight.w700,
        color: AppColors.primary, letterSpacing: 0.6));
  }
}

class FooterLink extends StatelessWidget {
  final String text;
  const FooterLink(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Text(text,
          style: GoogleFonts.publicSans(fontSize: 14, color: AppColors.onSurfaceVariant)),
    );
  }
}
