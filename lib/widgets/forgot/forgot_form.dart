import 'package:flutter/material.dart';
import '../../app_theme.dart';
import '../../utils/validators.dart';
import 'forgot_email_field.dart';
import 'forgot_reset_button.dart';
import 'forgot_back_link.dart';

class ForgotForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final bool isLoading;
  final VoidCallback onReset;

  const ForgotForm({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.isLoading,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant),
        boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2))],
      ),
      padding: const EdgeInsets.all(32),
      child: Form(key: formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ForgotEmailField(controller: emailController, validator: FormValidators.validateEmail),
        const SizedBox(height: 24),
        ForgotResetButton(isLoading: isLoading, onReset: onReset),
        const SizedBox(height: 32),
        Divider(color: AppColors.outlineVariant.withValues(alpha:0.3)),
        const SizedBox(height: 24),
        const ForgotBackLink(),
      ])),
    );
  }
}
