import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app_theme.dart';
import 'dashboard_notification_badge.dart';
import 'dashboard_cart_badge.dart';

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

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true, floating: true,
      backgroundColor: AppColors.surfaceContainerLowest.withValues(alpha: 0.95),
      elevation: 1, toolbarHeight: 72,
      title: Text('SIPKULINER',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.primary)),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: AppColors.primary),
          onPressed: () {},
        ),
        const DashboardNotificationBadge(),
        const DashboardCartBadge(),
        IconButton(
          icon: const Icon(Icons.logout, color: AppColors.primary),
          tooltip: 'Keluar', onPressed: onLogout),
        Padding(
          padding: const EdgeInsets.only(right: 16, left: 4),
          child: GestureDetector(
            onTap: onProfileTap,
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.outlineVariant),
                image: const DecorationImage(
                  image: NetworkImage(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuBAHD65XDZkfXMU0KcnlMJO5mkQAl0e0DZ-Ymalw19L3eD82owQOXfi9P6FeA2mF7daEwuYa6TNIIF14fBqsQJ0oaYDy53uXZkL952sjf3axogX3OZseRIjz0xUONZHQv4yMbEziEkXZmjQci2kK3iE_Oe7oqSgv_wpZXrBu-YA-qw9oIJ4YcJVyKA5dKq6KKypGzY1bg31Vm87D0XEttKx4UJToChvIKp5w4MZRZmghfNes79V6zDuKeowc4eRVVvEbbtNdM_-pbNt'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
