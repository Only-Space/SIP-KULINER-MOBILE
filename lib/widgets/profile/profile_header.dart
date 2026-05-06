import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app_theme.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(width: 100, height: 100, decoration: BoxDecoration(
          shape: BoxShape.circle, border: Border.all(color: AppColors.outlineVariant, width: 2),
          image: const DecorationImage(
            image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuBAHD65XDZkfXMU0KcnlMJO5mkQAl0e0DZ-Ymalw19L3eD82owQOXfi9P6FeA2mF7daEwuYa6TNIIF14fBqsQJ0oaYDy53uXZkL952sjf3axogX3OZseRIjz0xUONZHQv4yMbEziEkXZmjQci2kK3iE_Oe7oqSgv_wpZXrBu-YA-qw9oIJ4YcJVyKA5dKq6KKypGzY1bg31Vm87D0XEttKx4UJToChvIKp5w4MZRZmghfNes79V6zDuKeowc4eRVVvEbbtNdM_-pbNt'),
            fit: BoxFit.cover))),
      const SizedBox(height: 16),
      Text('Admin SIPKULINER', style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.primary)),
      const SizedBox(height: 4),
      Text('admin@test.com', style: GoogleFonts.publicSans(fontSize: 16, color: AppColors.onSurfaceVariant)),
      const SizedBox(height: 12),
      Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(color: AppColors.secondaryContainer, borderRadius: BorderRadius.circular(9999)),
        child: Text('Merchant Terverifikasi', style: GoogleFonts.publicSans(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.onSecondaryContainer))),
    ]);
  }
}
