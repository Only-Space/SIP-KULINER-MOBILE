import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';
import '../widgets/profile/profile_header.dart';
import '../widgets/profile/profile_menu_item.dart';
import '../widgets/profile/profile_logout_button.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(backgroundColor: Colors.white, elevation: 1, centerTitle: true,
        title: Text('Profil', style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.primary)),
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.primary), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(child: Column(children: [
        const SizedBox(height: 32), const ProfileHeader(),
        const SizedBox(height: 32), const ProfileMenuSection(),
        const SizedBox(height: 24), const ProfileLogoutButton(),
        const SizedBox(height: 32),
      ])),
    );
  }
}
