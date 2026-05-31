import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app_theme.dart';
import 'package:usada_rare/models/review_model.dart';
import 'package:usada_rare/core/widgets/skeleton_loader.dart';
import '../reviews/review_form_sheet.dart';
import 'place_review_card.dart';

class PlaceReviewsList extends StatelessWidget {
  final String placeId;
  final List<ReviewModel> reviews;
  final bool isLoadingReviews;
  final VoidCallback onReviewSubmitted;

  const PlaceReviewsList({
    super.key,
    required this.placeId,
    required this.reviews,
    required this.isLoadingReviews,
    required this.onReviewSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.star_rounded, size: 18, color: AppColors.amber),
              const SizedBox(width: 8),
              Text(
                'Ulasan Pengguna',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => ReviewFormSheet(
                      placeId: placeId,
                      onReviewSubmitted: onReviewSubmitted,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryFixed,
                  foregroundColor: AppColors.primary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.edit_rounded, size: 14),
                label: Text(
                  'Tulis Ulasan',
                  style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          if (reviews.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '${reviews.length} ulasan',
              style: GoogleFonts.publicSans(
                fontSize: 12,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: 16),
         if (isLoadingReviews)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: List.generate(3, (index) => const Padding(
                padding: EdgeInsets.only(bottom: 12.0),
                child: SkeletonLoader(width: double.infinity, height: 100, borderRadius: 16),
              )),
            ),
          )else if (reviews.isEmpty)
            _buildEmptyReview()
          else
            ...reviews.map((r) => PlaceReviewCard(review: r)),
          const SizedBox(height: 140),
        ],
      ),
    );
  }

  Widget _buildEmptyReview() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          const Icon(Icons.rate_review_outlined, size: 40, color: AppColors.outlineVariant),
          const SizedBox(height: 10),
          Text(
            'Belum ada ulasan',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Jadilah yang pertama menulis ulasan!',
            style: GoogleFonts.publicSans(
              fontSize: 12,
              color: AppColors.outlineVariant,
            ),
          ),
        ],
      ),
    );
  }
}
