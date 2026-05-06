import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app_theme.dart';

class DashboardCartBadge extends StatelessWidget {
  const DashboardCartBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        IconButton(
          icon: const Icon(Icons.shopping_cart_outlined, color: AppColors.primary),
          onPressed: () {},
        ),
        Positioned(
          top: 8, right: 8,
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: AppColors.secondaryContainer,
              borderRadius: BorderRadius.circular(9),
            ),
            constraints: const BoxConstraints(minWidth: 18),
            child: Text('3',
                style: GoogleFonts.publicSans(
                  fontSize: 10, fontWeight: FontWeight.bold,
                  color: AppColors.onSecondaryContainer),
                textAlign: TextAlign.center),
          ),
        ),
      ],
    );
  }
}
