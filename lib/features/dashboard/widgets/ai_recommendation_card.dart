import 'package:flutter/material.dart';

import '../../../app_theme.dart';
import '../../../models/ai_recommendation.dart';
import '../../../features/place_detail/pages/place_detail_page.dart';

class AiRecommendationCard extends StatelessWidget {
  final AiRecommendation recommendation;

  const AiRecommendationCard({super.key, required this.recommendation});

  String _formatDistance(int? distanceMeters) {
    if (distanceMeters == null) return '';
    if (distanceMeters < 1000) return '$distanceMeters m';
    final km = distanceMeters / 1000.0;
    return '${km.toStringAsFixed(1)} km';
  }

  @override
  Widget build(BuildContext context) {
    final place = recommendation.place;
    final distanceText = _formatDistance(place.distance);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const PlaceDetailPage(),
            settings: RouteSettings(arguments: place.id),
          ),
        );
      },
      child: SizedBox(
        width: 200,
        height: 160,
        child: Card(
          elevation: 2,
          shadowColor: const Color(0x14002045),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: AppColors.surfaceContainerLowest,
          child: Stack(
            children: [
              // ── Main content ──────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 36, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Place name
                    Text(
                      place.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.onSurface,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Distance + category row
                    Row(
                      children: [
                        if (distanceText.isNotEmpty) ...[
                          const Icon(
                            Icons.near_me_rounded,
                            size: 12,
                            color: AppColors.accent,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            distanceText,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.accent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Expanded(
                          child: Text(
                            place.categoryName,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    // AI reason — italic, muted
                    Text(
                      recommendation.reason,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                        color: AppColors.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Rank badge ────────────────────────────────────────────
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.amber,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '#${recommendation.rank}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5A3A00),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
