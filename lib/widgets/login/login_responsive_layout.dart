import 'package:flutter/material.dart';
import 'login_branding.dart';
import 'login_form_content.dart';
import 'login_footer.dart';

class LoginResponsiveLayout extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isLoading;
  final bool isPasswordVisible;
  final String? errorMessage;
  final VoidCallback onLogin;
  final ValueChanged<bool> onPasswordVisibilityChanged;

  const LoginResponsiveLayout({
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
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) => constraints.maxWidth > 700
            ? _wideLayout(context)
            : _mobileLayout(context),
      ),
    );
  }

  Widget _wideLayout(BuildContext context) {
    return Center(
      child: Container(
        width: 1100, height: 700,
        decoration: _boxDecoration(),
        child: Row(children: [
          const Expanded(child: LoginBranding()),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 48),
              child: _formContent(),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _mobileLayout(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          const SizedBox(height: 40),
          const Text('SIPKULINER',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: Colors.blue)),
          const SizedBox(height: 32),
          Container(decoration: _boxDecoration(), padding: const EdgeInsets.all(24), child: _formContent()),
          const SizedBox(height: 24),
          const LoginFooter(),
        ]),
      ),
    );
  }

  Widget _formContent() => LoginFormContent(
        formKey: formKey,
        emailController: emailController,
        passwordController: passwordController,
        isLoading: isLoading,
        isPasswordVisible: isPasswordVisible,
        errorMessage: errorMessage,
        onLogin: onLogin,
        onPasswordVisibilityChanged: onPasswordVisibilityChanged,
      );

  BoxDecoration _boxDecoration() => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(color: Color(0x1A002045), blurRadius: 32, offset: Offset(0, 16)),
        ],
        border: Border.all(color: Colors.grey.shade300),
      );
}
