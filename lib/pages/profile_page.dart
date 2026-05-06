import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';
import 'login_pages.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        title: Text(
          'Profil',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 32),
            _buildProfileHeader(),
            const SizedBox(height: 32),
            _buildMenuSection(context),
            const SizedBox(height: 24),
            _buildLogoutButton(context),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.outlineVariant, width: 2),
            image: const DecorationImage(
              image: NetworkImage(
                'https://lh3.googleusercontent.com/aida-public/AB6AXuBAHD65XDZkfXMU0KcnlMJO5mkQAl0e0DZ-Ymalw19L3eD82owQOXfi9P6FeA2mF7daEwuYa6TNIIF14fBqsQJ0oaYDy53uXZkL952sjf3axogX3OZseRIjz0xUONZHQv4yMbEziEkXZmjQci2kK3iE_Oe7oqSgv_wpZXrBu-YA-qw9oIJ4YcJVyKA5dKq6KKypGzY1bg31Vm87D0XEttKx4UJToChvIKp5w4MZRZmghfNes79V6zDuKeowc4eRVVvEbbtNdM_-pbNt',
              ),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Admin SIPKULINER',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'admin@test.com',
          style: GoogleFonts.publicSans(
            fontSize: 16,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.secondaryContainer,
            borderRadius: BorderRadius.circular(9999),
          ),
          child: Text(
            'Merchant Terverifikasi',
            style: GoogleFonts.publicSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.onSecondaryContainer,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          _menuItem(Icons.person_outline, 'Informasi Akun', () {}),
          _divider(),
          _menuItem(Icons.history, 'Riwayat Pesanan', () {}),
          _divider(),
          _menuItem(Icons.favorite_border, 'Favorit Saya', () {}),
          _divider(),
          _menuItem(Icons.settings_outlined, 'Pengaturan', () {}),
          _divider(),
          _menuItem(Icons.help_outline, 'Bantuan', () {}),
        ],
      ),
    );
  }

  Widget _menuItem(IconData icon, String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.publicSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.onSurface,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.outlineVariant,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: AppColors.outlineVariant.withValues(alpha: 0.2),
      indent: 60,
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginPages()),
              (route) => false,
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.logout, size: 20),
              const SizedBox(width: 8),
              Text(
                'Keluar',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
