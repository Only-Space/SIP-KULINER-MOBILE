import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:usada_rare/core/widgets/skeleton_widget.dart';

class AiRecommendationSkeleton extends StatelessWidget {
  const AiRecommendationSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade100,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: List.generate(3, (index) {
            return Container(
              width: 200,
              height: 160,
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    SkeletonBox(height: 90, borderRadius: 12),
                    SizedBox(height: 8),
                    SkeletonBox(height: 14, width: 120),
                    SizedBox(height: 6),
                    SkeletonBox(height: 12, width: 80),
                    SizedBox(height: 6),
                    SkeletonBox(height: 12, width: 150),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
