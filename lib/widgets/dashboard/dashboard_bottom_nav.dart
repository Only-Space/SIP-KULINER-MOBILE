import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app_theme.dart';

class DashboardBottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int>? onChanged;

  const DashboardBottomNav({
    super.key,
    required this.selectedIndex,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest.withValues(alpha: 0.9),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 12,
            offset: Offset(0, -4),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(Icons.home_outlined, 'Home', 0),
              _navItem(Icons.search, 'Explore', 1, isActive: true),
              _navItem(Icons.receipt_long_outlined, 'My Orders', 2),
              _navItem(Icons.person_outline, 'Profile', 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index, {bool isActive = false}) {
    final color = isActive ? AppColors.secondaryContainer : AppColors.outlineVariant;
    return GestureDetector(
      onTap: () => onChanged?.call(index),
      child: Container(
        width: 64,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: isActive ? AppColors.surfaceContainerLow : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Transform.scale(
              scale: isActive ? 1.1 : 1.0,
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.publicSans(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
