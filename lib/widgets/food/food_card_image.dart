import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app_theme.dart';
import '../../models/food_item.dart';

class FoodCardImage extends StatelessWidget {
  final FoodItem item;
  const FoodCardImage(this.item, {super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: AspectRatio(
            aspectRatio: 4 / 3,
            child: Image.network(
              item.imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) => progress == null
                  ? child
                  : Container(
                      color: AppColors.surfaceVariant,
                      child: Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary.withValues(alpha: 0.4),
                          ),
                        ),
                      ),
                    ),
              errorBuilder: (context, error, stack) => Container(
                color: AppColors.surfaceContainerLow,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image_outlined, size: 28, color: AppColors.outlineVariant),
                    const SizedBox(height: 4),
                    Text(
                      'Foto tidak tersedia',
                      style: GoogleFonts.publicSans(
                        fontSize: 10,
                        color: AppColors.outlineVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        // Top badges (Halal, Local Favorite)
        Positioned(
          top: 8,
          left: 8,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (item.tags.contains('Halal'))
                _glassBadge(Icons.verified_rounded, 'Halal', Colors.green.shade700),
              if (item.tags.contains('Local Favorite')) ...[
                const SizedBox(height: 4),
                _glassBadge(Icons.local_fire_department_rounded, 'Favorit', Colors.deepOrange),
              ],
            ],
          ),
        ),
        // Distance badge — bottom right with glassmorphism
        Positioned(
          bottom: 0,
          right: 0,
          left: 0,
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.zero),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
              child: Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 8, bottom: 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.near_me_rounded, size: 11, color: Colors.white),
                            const SizedBox(width: 3),
                            Text(
                              item.distance < 1.0
                                  ? '${(item.distance * 1000).toInt()} m'
                                  : '${item.distance.toStringAsFixed(1)} km',
                              style: GoogleFonts.publicSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _glassBadge(IconData icon, String text, Color color) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 12, color: color),
              const SizedBox(width: 4),
              Text(
                text,
                style: GoogleFonts.publicSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
