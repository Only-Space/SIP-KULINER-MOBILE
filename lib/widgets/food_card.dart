import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';
import '../models/food_item.dart';

class FoodCard extends StatelessWidget {
  final FoodItem item;

  const FoodCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImage(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: GoogleFonts.publicSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.storefront,
                        size: 16,
                        color: AppColors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          item.merchant,
                          style: GoogleFonts.publicSans(
                            fontSize: 14,
                            color: AppColors.onSurfaceVariant,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  _buildRating(),
                  const SizedBox(height: 8),
                  _buildPriceRow(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
          child: AspectRatio(
            aspectRatio: 4 / 3,
            child: Image.network(
              item.imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: AppColors.surfaceVariant,
                  child: const Center(child: CircularProgressIndicator()),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: AppColors.surfaceVariant,
                  child: const Icon(Icons.broken_image, size: 40),
                );
              },
            ),
          ),
        ),
        if (item.tags.contains('Halal'))
          _buildTag(
            icon: Icons.verified,
            iconColor: AppColors.tertiaryContainer,
            text: 'Halal',
            textColor: AppColors.primary,
            bgColor: AppColors.surfaceContainerLowest,
          ),
        if (item.tags.contains('Local Favorite'))
          _buildTag(
            icon: Icons.local_fire_department,
            iconColor: AppColors.secondaryContainer,
            text: 'Local Favorite',
            textColor: Colors.white,
            bgColor: AppColors.primary,
          ),
        if (item.tags.contains('Jajanan Bali'))
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(4),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1A000000),
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: Text(
                'Jajanan Bali',
                style: GoogleFonts.publicSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        Positioned(
          top: 12,
          right: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(4),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1A000000),
                  blurRadius: 4,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.near_me,
                  size: 14,
                  color: AppColors.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  '${item.distance} km',
                  style: GoogleFonts.publicSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTag({
    required IconData icon,
    required Color iconColor,
    required String text,
    required Color textColor,
    required Color bgColor,
  }) {
    return Positioned(
      top: 12,
      left: 12,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: bgColor.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(4),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 4,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor, size: 14),
            const SizedBox(width: 4),
            Text(
              text,
              style: GoogleFonts.publicSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRating() {
    return Row(
      children: [
        const Icon(Icons.star, color: AppColors.secondaryContainer, size: 18),
        const SizedBox(width: 4),
        Text(
          '${item.rating}',
          style: GoogleFonts.publicSans(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '(${item.reviews} ulasan)',
          style: GoogleFonts.publicSans(
            fontSize: 14,
            color: AppColors.outlineVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Rp ${_formatPrice(item.price)}',
          style: GoogleFonts.publicSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        GestureDetector(
          onTap: () {},
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.secondaryContainer,
              shape: BoxShape.circle,
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1A000000),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.add,
              size: 20,
              color: AppColors.onSecondaryContainer,
            ),
          ),
        ),
      ],
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );
  }
}
