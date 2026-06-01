import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:usada_rare/core/widgets/skeleton_widget.dart';

class ReviewSkeleton extends StatelessWidget {
  const ReviewSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade100,
      child: Column(
        children: List.generate(3, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SkeletonBox(width: 40, height: 40, isCircle: true),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          SkeletonBox(width: 100, height: 14),
                          SizedBox(height: 6),
                          SkeletonBox(width: 60, height: 12),
                          SizedBox(height: 8),
                          SkeletonBox(width: double.infinity, height: 12),
                          SizedBox(height: 4),
                          SkeletonBox(width: 200, height: 12),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(height: 1, color: Colors.white),
              ],
            ),
          );
        }),
      ),
    );
  }
}
