import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app_theme.dart';
import 'login_email_field.dart';
import 'login_password_field.dart';
import 'login_button.dart';

class LoginFormContent extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isLoading;
  final bool isPasswordVisible;
  final String? errorMessage;
  final VoidCallback onLogin;
  final ValueChanged<bool> onPasswordVisibilityChanged;

  const LoginFormContent({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.isLoading,
    required this.isPasswordVisible,
    this.errorMessage,
    required this.onLogin,
    required this.onPasswordVisibilityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Selamat Datang',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 36, fontWeight: FontWeight.w700, color: AppColors.primary)),
          const SizedBox(height: 8),
          Text('Silakan masuk untuk melanjutkan akses ke ekosistem kuliner kami.',
              style: GoogleFonts.publicSans(fontSize: 16, color: AppColors.onSurfaceVariant)),
          const SizedBox(height: 40),
          LoginEmailField(controller: emailController),
          const SizedBox(height: 24),
          LoginPasswordField(
            controller: passwordController,
            isPasswordVisible: isPasswordVisible,
            onVisibilityChanged: onPasswordVisibilityChanged,
          ),
          if (errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(errorMessage!,
                style: GoogleFonts.publicSans(fontSize: 14, color: Colors.red)),
          ],
          const SizedBox(height: 16),
          LoginButton(isLoading: isLoading, onLogin: onLogin),
          const SizedBox(height: 24),
          const _DividerWithText('ATAU'),
          const SizedBox(height: 24),
          const _SignupLink(),
        ],
      ),
    );
  }
}

class _DividerWithText extends StatelessWidget {
  final String text;
  const _DividerWithText(this.text);
  @override
  Widget build(BuildContext context) => Row(children: [
    Expanded(child: Divider(color: AppColors.outlineVariant.withValues(alpha: 0.3))),
    Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text(text, style: GoogleFonts.publicSans(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.outlineVariant))),
    Expanded(child: Divider(color: AppColors.outlineVariant.withValues(alpha: 0.3))),
  ]);
}

class _SignupLink extends StatelessWidget {
  const _SignupLink();
  @override
  Widget build(BuildContext context) => Center(child: RichText(text: TextSpan(
    text: 'Belum memiliki akun? ', style: GoogleFonts.publicSans(fontSize: 16, color: AppColors.onSurfaceVariant),
    children: [WidgetSpan(child: GestureDetector(onTap: () {}, child: Text('Daftar Sekarang', style: GoogleFonts.publicSans(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.secondary))))],
  )));
}
