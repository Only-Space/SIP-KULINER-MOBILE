import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app_theme.dart';

class CategoryFilters extends StatefulWidget {
  final List<String> categories;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const CategoryFilters({
    super.key,
    required this.categories,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  State<CategoryFilters> createState() => _CategoryFiltersState();
}

class _CategoryFiltersState extends State<CategoryFilters> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: widget.categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final isSelected = index == widget.selectedIndex;
          return GestureDetector(
            onTap: () => widget.onChanged(index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(9999),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.outlineVariant,
                ),
                boxShadow: isSelected
                    ? const [
                        BoxShadow(
                          color: Color(0x1A000000),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                widget.categories[index],
                style: GoogleFonts.publicSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
                  letterSpacing: 0.6,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
