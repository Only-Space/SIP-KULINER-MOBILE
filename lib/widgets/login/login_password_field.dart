import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app_theme.dart';
import '../../utils/validators.dart';

class LoginPasswordField extends StatelessWidget {
  final TextEditingController controller;
  final bool isPasswordVisible;
  final ValueChanged<bool> onVisibilityChanged;

  const LoginPasswordField({
    super.key,
    required this.controller,
    required this.isPasswordVisible,
    required this.onVisibilityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('KATA SANDI',
                style: GoogleFonts.publicSans(
                  fontSize: 12, fontWeight: FontWeight.w700,
                  color: AppColors.onSurfaceVariant, letterSpacing: 0.6)),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/forgot-password'),
              child: Text('LUPA PASSWORD?',
                  style: GoogleFonts.publicSans(
                    fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: !isPasswordVisible,
          validator: FormValidators.validatePassword,
          decoration: _inputDecoration(context),
          style: GoogleFonts.publicSans(fontSize: 16),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(BuildContext context) => InputDecoration(
        hintText: '••••••••',
        hintStyle: GoogleFonts.publicSans(color: AppColors.outlineVariant, fontSize: 16),
        prefixIcon: const Icon(Icons.lock_outline, color: AppColors.outlineVariant),
        suffixIcon: IconButton(
          icon: Icon(isPasswordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: AppColors.outlineVariant),
          onPressed: () => onVisibilityChanged(!isPasswordVisible),
        ),
        filled: true,
        fillColor: AppColors.surfaceContainerLow,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.5))),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.5))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 2)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 2)),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 2)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      );
}
