import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app_theme.dart';
import '../../models/food_item.dart';
import 'food_card_image.dart';
import 'food_card_info.dart';

class FoodCard extends StatelessWidget {
  final FoodItem item;
  const FoodCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant),
        boxShadow: const [BoxShadow(color: Color(0x05000000), blurRadius: 12, offset: Offset(0, 4))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        FoodCardImage(item),
        Expanded(
          child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(item.name, style: GoogleFonts.publicSans(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.onSurface, height: 1.3), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.storefront, size: 16, color: AppColors.onSurfaceVariant),
              const SizedBox(width: 4),
              Expanded(child: Text(item.merchant, style: GoogleFonts.publicSans(fontSize: 14, color: AppColors.onSurfaceVariant), overflow: TextOverflow.ellipsis)),
            ]),
            const Spacer(),
            FoodCardRating(item),
            const SizedBox(height: 8),
            FoodCardPriceRow(item),
          ])),
        ),
      ]),
    );
  }
}
