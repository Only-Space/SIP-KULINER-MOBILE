import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app_theme.dart';
import '../../models/food_item.dart';

class FoodCardImage extends StatelessWidget {
  final FoodItem item;
  const FoodCardImage(this.item, {super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      ClipRRect(
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
        child: AspectRatio(
          aspectRatio: 4/3,
          child: Image.network(item.imageUrl, fit: BoxFit.cover,
            loadingBuilder: (context, child, progress) => progress == null
                ? child : Container(color: AppColors.surfaceVariant, child: const Center(child: CircularProgressIndicator())),
            errorBuilder: (context, error, stack) => Container(color: AppColors.surfaceVariant, child: const Icon(Icons.broken_image, size: 40)),
          ),
        ),
      ),
      if (item.tags.contains('Halal')) _tag(Icons.verified, AppColors.tertiaryContainer, 'Halal', AppColors.primary, AppColors.surfaceContainerLowest),
      if (item.tags.contains('Local Favorite')) _tag(Icons.local_fire_department, AppColors.secondaryContainer, 'Local Favorite', Colors.white, AppColors.primary),
      if (item.tags.contains('Jajanan Bali')) _buildBadge('Jajanan Bali', AppColors.primary, AppColors.surfaceContainerLowest),
      _buildBadge('${item.distance} km', AppColors.onSurface, AppColors.surfaceContainerLowest, icon: Icons.near_me),
    ]);
  }

  Widget _tag(IconData icon, Color iconColor, String text, Color textColor, Color bgColor) =>
      _buildBadge(text, textColor, bgColor, icon: icon, iconColor: iconColor);

  Widget _buildBadge(String text, Color textColor, Color bgColor, {IconData? icon, Color? iconColor}) => Positioned(
        top: 12, left: icon != null ? null : 12, right: icon != null ? 12 : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: bgColor.withValues(alpha: 0.9), borderRadius: BorderRadius.circular(4),
            boxShadow: const [BoxShadow(color: Color(0x1A000000), blurRadius: 4, offset: Offset(0, 1))],
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            if (icon != null) ...[
              Icon(icon, color: iconColor ?? AppColors.onSurfaceVariant, size: 14),
              const SizedBox(width: 4),
            ],
            Text(text, style: GoogleFonts.publicSans(fontSize: 12, fontWeight: FontWeight.w700, color: textColor)),
          ]),
        ),
      );
}
