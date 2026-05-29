import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app_theme.dart';

class DashboardAppBar extends StatelessWidget {
  final String userEmail;
  final VoidCallback? onLogout;
  final VoidCallback? onProfileTap;

  const DashboardAppBar({
    super.key,
    required this.userEmail,
    this.onLogout,
    this.onProfileTap,
  });

  String _getInitials(String email) {
    final name = email.split('@').first;
    final parts = name.split(RegExp(r'[._\-]'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      floating: true,
      toolbarHeight: 64,
      elevation: 0,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: AppGradients.headerGradient,
        ),
      ),
      title: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Icon(Icons.restaurant_menu, color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'SIPKULINER',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.exit_to_app_rounded, color: Colors.white, size: 22),
          tooltip: 'Keluar',
          onPressed: onLogout,
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16, left: 4),
          child: GestureDetector(
            onTap: onProfileTap,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.8), width: 2),
                gradient: const LinearGradient(
                  colors: [Color(0xFF3D7EF0), Color(0xFF1A3D6B)],
                ),
              ),
              child: Center(
                child: Text(
                  _getInitials(userEmail),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
