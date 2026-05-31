import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:usada_rare/app_theme.dart';
import 'package:usada_rare/models/review_model.dart';
import 'package:usada_rare/core/widgets/cached_image.dart';

class PlaceReviewCard extends StatelessWidget {
  final ReviewModel review;
  const PlaceReviewCard({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: AppColors.outlineVariant.withValues(alpha: 0.35)),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.surfaceContainerHigh,
                backgroundImage: review.userAvatarUrl != null
                    ? NetworkImage(review.userAvatarUrl!)
                    : null,
                child: review.userAvatarUrl == null
                    ? const Icon(Icons.person_rounded,
                        color: AppColors.onSurfaceVariant, size: 20)
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName ?? 'Pengguna',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: List.generate(
                        5,
                        (i) => Icon(
                          i < review.rating
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          size: 14,
                          color: AppColors.amber,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (review.comment != null && review.comment!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              review.comment!,
              style: GoogleFonts.publicSans(
                fontSize: 13,
                color: AppColors.onSurface,
                height: 1.5,
              ),
            ),
          ],
          if (review.photos.isNotEmpty) ...[
            const SizedBox(height: 10),
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: review.photos.length,
                itemBuilder: (ctx, pIdx) => Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedImage(imageUrl: review.photos[pIdx],
                        width: 80, height: 80, fit: BoxFit.cover),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
