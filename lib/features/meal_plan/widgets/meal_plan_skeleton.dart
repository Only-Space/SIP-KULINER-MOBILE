import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:usada_rare/core/widgets/skeleton_widget.dart';

class MealPlanSkeleton extends StatelessWidget {
  const MealPlanSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade100,
      child: Column(
        children: [
          const SizedBox(height: 16),
          // Summary card skeleton
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 24, top: 8),
              itemCount: 3, // 3 card hari
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(color: Colors.white, width: 2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            SkeletonBox(width: 80, height: 16),
                            SkeletonBox(width: 60, height: 16),
                          ],
                        ),
                      ),
                      Container(height: 1, color: Colors.white),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _buildMealSectionSkeleton(),
                            const SizedBox(height: 12),
                            Container(height: 1, color: Colors.white),
                            const SizedBox(height: 12),
                            _buildMealSectionSkeleton(),
                            const SizedBox(height: 12),
                            Container(height: 1, color: Colors.white),
                            const SizedBox(height: 12),
                            _buildMealSectionSkeleton(),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealSectionSkeleton() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SkeletonBox(width: 24, height: 24, isCircle: true),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              SkeletonBox(width: 140, height: 14),
              SizedBox(height: 6),
              SkeletonBox(width: 100, height: 12),
            ],
          ),
        ),
        const SizedBox(width: 8),
        const SkeletonBox(width: 50, height: 14),
      ],
    );
  }
}
