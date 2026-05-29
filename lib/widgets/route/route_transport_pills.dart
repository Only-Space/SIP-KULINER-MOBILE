import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app_theme.dart';

class RouteTransportPills extends StatelessWidget {
  final String selectedMode;
  final ValueChanged<String> onChanged;

  const RouteTransportPills({
    super.key,
    required this.selectedMode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ModePill(
          icon: Icons.directions_car_rounded,
          label: 'Mobil',
          mode: 'drive',
          selectedMode: selectedMode,
          onTap: onChanged,
        ),
        const SizedBox(width: 8),
        _ModePill(
          icon: Icons.two_wheeler_rounded,
          label: 'Motor',
          mode: 'motorcycle',
          selectedMode: selectedMode,
          onTap: onChanged,
        ),
        const SizedBox(width: 8),
        _ModePill(
          icon: Icons.directions_walk_rounded,
          label: 'Jalan',
          mode: 'walk',
          selectedMode: selectedMode,
          onTap: onChanged,
        ),
      ],
    );
  }
}

class _ModePill extends StatelessWidget {
  final IconData icon;
  final String label;
  final String mode;
  final String selectedMode;
  final ValueChanged<String> onTap;

  const _ModePill({
    required this.icon,
    required this.label,
    required this.mode,
    required this.selectedMode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = mode == selectedMode;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            gradient: isSelected ? AppGradients.chipActiveGradient : null,
            color: isSelected ? null : AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.publicSans(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
