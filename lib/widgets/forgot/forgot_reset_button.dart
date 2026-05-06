import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app_theme.dart';

class ForgotResetButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onReset;
  const ForgotResetButton({super.key, required this.isLoading, required this.onReset});

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: double.infinity, child: ElevatedButton(
      onPressed: isLoading ? null : onReset,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary, foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4, shadowColor: AppColors.primary.withValues(alpha:0.2),
        disabledBackgroundColor: AppColors.primary.withValues(alpha:0.6),
      ),
      child: isLoading
          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
          : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('Kirim Instruksi', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(width: 8), const Icon(Icons.send, size: 18),
            ]),
    ));
  }
}
