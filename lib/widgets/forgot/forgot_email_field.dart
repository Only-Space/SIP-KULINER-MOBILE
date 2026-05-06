import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app_theme.dart';

class ForgotEmailField extends StatelessWidget {
  final TextEditingController controller;
  final FormFieldValidator<String>? validator;
  const ForgotEmailField({super.key, required this.controller, this.validator});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('ALAMAT EMAIL', style: GoogleFonts.publicSans(
        fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.onSurfaceVariant, letterSpacing:0.6)),
      const SizedBox(height: 8),
      TextFormField(
        controller: controller, validator: validator,
        decoration: _inputDecoration(),
        style: GoogleFonts.publicSans(fontSize: 16), keyboardType: TextInputType.emailAddress,
      ),
      const SizedBox(height: 8),
      Text('Kami akan mengirimkan tautan verifikasi ke email ini.',
          style: GoogleFonts.publicSans(fontSize: 12, color: AppColors.onSurfaceVariant)),
    ]);
  }

  InputDecoration _inputDecoration() => InputDecoration(
        hintText: 'nama@email.com', hintStyle: GoogleFonts.publicSans(color: AppColors.outlineVariant, fontSize: 16),
        prefixIcon: const Icon(Icons.mail_outline, color: AppColors.outlineVariant),
        filled: true, fillColor: AppColors.surfaceContainerLow,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.outlineVariant.withValues(alpha:0.5))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.outlineVariant.withValues(alpha:0.5))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width:2)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.red, width:2)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.red, width:2)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      );
}
