import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app_theme.dart';

class LoginButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onLogin;
  const LoginButton({super.key, required this.isLoading, required this.onLogin});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary, foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 8, shadowColor: AppColors.primary.withValues(alpha: 0.2),
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.6),
        ),
        child: isLoading
            ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
            : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('Masuk', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward, size: 20),
              ]),
      ),
    );
  }
}

class LoginRememberRow extends StatelessWidget {
  const LoginRememberRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      SizedBox(width: 20, height: 20, child: Checkbox(
        value: false, onChanged: (value) {},
        activeColor: AppColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        side: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
      )),
      const SizedBox(width: 12),
      Text('Ingat saya di perangkat ini',
          style: GoogleFonts.publicSans(fontSize: 14, color: AppColors.onSurfaceVariant)),
    ]);
  }
}
