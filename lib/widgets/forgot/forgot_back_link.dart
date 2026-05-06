import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app_theme.dart';

class ForgotBackLink extends StatelessWidget {
  const ForgotBackLink({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: () => Navigator.pop(context), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.arrow_back, size: 16, color: AppColors.primary),
      const SizedBox(width: 8),
      Text('Kembali ke Login', style: GoogleFonts.publicSans(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
    ]));
  }
}
