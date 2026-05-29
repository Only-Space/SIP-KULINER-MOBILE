import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app_theme.dart';
import '../../pages/saved_routes_page.dart';

class ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  const ProfileMenuItem({super.key, required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: onTap, child: Padding(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(children: [
        Icon(icon, color: AppColors.primary, size: 24), const SizedBox(width: 16),
        Expanded(child: Text(title, style: GoogleFonts.publicSans(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.onSurface))),
        Icon(Icons.chevron_right, color: AppColors.outlineVariant, size: 20),
      ])));
  }
}

class ProfileMenuSection extends StatelessWidget {
  const ProfileMenuSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3))),
      child: Column(children: [
        ProfileMenuItem(icon: Icons.person_outline, title: 'Informasi Akun', onTap: () => _showComingSoon(context)),
        _divider(),
        ProfileMenuItem(icon: Icons.favorite_border, title: 'Favorit Saya', onTap: () => _showComingSoon(context)),
        _divider(),
        ProfileMenuItem(
          icon: Icons.map_outlined,
          title: 'Rute Tersimpan',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SavedRoutesPage()),
            );
          },
        ),
        _divider(),
        ProfileMenuItem(icon: Icons.settings_outlined, title: 'Pengaturan', onTap: () => _showComingSoon(context)),
        _divider(),
        ProfileMenuItem(icon: Icons.help_outline, title: 'Bantuan', onTap: () => _showComingSoon(context)),
      ]));
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Fitur ini segera hadir!'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _divider() => Divider(height: 1, thickness: 1, color: AppColors.outlineVariant.withValues(alpha: 0.2), indent: 60);
}
