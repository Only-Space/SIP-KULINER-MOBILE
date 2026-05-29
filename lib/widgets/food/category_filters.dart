import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app_theme.dart';

class CategoryFilters extends StatelessWidget {
  final List<String> categories;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const CategoryFilters({
    super.key,
    required this.categories,
    required this.selectedIndex,
    required this.onChanged,
  });

  static const _categoryEmojis = [
    '🍽️', // Semua Kategori
    '🌺', // Jajanan Bali
    '🍚', // Nasi Campur
    '🍖', // Sate & Panggang
    '🥤', // Minuman Segar
    '🛍️', // Oleh-Oleh
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = index == selectedIndex;
          final emoji = index < _categoryEmojis.length ? _categoryEmojis[index] : '';
          return GestureDetector(
            onTap: () => onChanged(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                gradient: isSelected ? AppGradients.chipActiveGradient : null,
                color: isSelected ? null : AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.outlineVariant.withValues(alpha: 0.6),
                  width: isSelected ? 0 : 1,
                ),
                boxShadow: isSelected ? AppShadows.soft : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (emoji.isNotEmpty) ...[
                    Text(emoji, style: const TextStyle(fontSize: 13)),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    categories[index],
                    style: GoogleFonts.publicSans(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
