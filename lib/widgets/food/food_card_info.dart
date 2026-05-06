import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app_theme.dart';
import '../../models/food_item.dart';

class FoodCardRating extends StatelessWidget {
  final FoodItem item;
  const FoodCardRating(this.item, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      const Icon(Icons.star, color: AppColors.secondaryContainer, size: 18),
      const SizedBox(width: 4),
      Text('${item.rating}', style: GoogleFonts.publicSans(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.onSurface)),
      const SizedBox(width: 4),
      Text('(${item.reviews} ulasan)', style: GoogleFonts.publicSans(fontSize: 14, color: AppColors.outlineVariant)),
    ]);
  }
}

class FoodCardPriceRow extends StatelessWidget {
  final FoodItem item;
  const FoodCardPriceRow(this.item, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text('Rp ${_formatPrice(item.price)}', style: GoogleFonts.publicSans(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.primary)),
      GestureDetector(
        onTap: () {},
        child: Container(width: 32, height: 32, decoration: BoxDecoration(
            color: AppColors.secondaryContainer, shape: BoxShape.circle,
            boxShadow: const [BoxShadow(color: Color(0x1A000000), blurRadius: 4, offset: Offset(0, 2))]),
          child: const Icon(Icons.add, size: 20, color: AppColors.onSecondaryContainer)),
      ),
    ]);
  }

  String _formatPrice(int price) => price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
}
