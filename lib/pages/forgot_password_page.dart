import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/forgot/forgot_branding.dart';
import '../widgets/forgot/forgot_form.dart';
import '../widgets/forgot/forgot_cards.dart';
import '../widgets/forgot/forgot_footer.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleReset() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Link reset telah dikirim ke email Anda',
            style: GoogleFonts.publicSans(color: Colors.white),
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                children: [
                  const ForgotBranding(),
                  const SizedBox(height: 40),
                  ForgotForm(
                    formKey: _formKey,
                    emailController: _emailController,
                    isLoading: _isLoading,
                    onReset: _handleReset,
                  ),
                  const SizedBox(height: 48),
                  const ForgotCards(),
                  const SizedBox(height: 48),
                  const ForgotFooter(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
