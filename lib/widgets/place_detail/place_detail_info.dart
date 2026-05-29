import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app_theme.dart';
import '../../models/geoapify_place.dart';

class PlaceDetailInfo extends StatelessWidget {
  final GeoapifyPlace place;
  final double avgRating;

  const PlaceDetailInfo({
    super.key,
    required this.place,
    required this.avgRating,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  place.name,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.onSurface,
                    height: 1.2,
                  ),
                ),
              ),
              if (avgRating > 0) ...[
                const SizedBox(width: 12),
                _RatingBadge(rating: avgRating),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on_rounded, size: 14, color: AppColors.error),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  place.address,
                  style: GoogleFonts.publicSans(
                    fontSize: 13,
                    color: AppColors.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Info chips
          _buildInfoChips(place),
        ],
      ),
    );
  }

  Widget _buildInfoChips(GeoapifyPlace place) {
    final chips = <_ChipData>[];

    if (place.phone != null) {
      chips.add(_ChipData(
        icon: Icons.phone_rounded,
        label: place.phone!,
        color: AppColors.success,
      ));
    }

    chips.add(_ChipData(
      icon: Icons.access_time_rounded,
      label: place.openingHours ?? 'Info jam tidak tersedia',
      color: AppColors.accent,
    ));

    if (place.website != null) {
      chips.add(_ChipData(
        icon: Icons.language_rounded,
        label: 'Website',
        color: AppColors.secondary,
      ));
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: chips.map(_buildChip).toList(),
    );
  }

  Widget _buildChip(_ChipData data) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: data.color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: data.color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(data.icon, size: 14, color: data.color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              data.label,
              style: GoogleFonts.publicSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: data.color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChipData {
  final IconData icon;
  final String label;
  final Color color;
  _ChipData({required this.icon, required this.label, required this.color});
}

class _RatingBadge extends StatelessWidget {
  final double rating;
  const _RatingBadge({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.amber.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.amber.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, size: 16, color: AppColors.amber),
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.secondary,
            ),
          ),
        ],
      ),
    );
  }
}
