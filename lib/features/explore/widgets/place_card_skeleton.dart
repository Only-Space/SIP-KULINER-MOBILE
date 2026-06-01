import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:usada_rare/core/widgets/skeleton_widget.dart';

class PlaceCardSkeleton extends StatelessWidget {
  final bool isList;
  const PlaceCardSkeleton({super.key, this.isList = false});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade100,
      child: isList ? _buildListSkeleton() : _buildSingleSkeleton(),
    );
  }
  
  Widget _buildSingleSkeleton() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SkeletonBox(height: 120, borderRadius: 12),
            const SizedBox(height: 8),
            const SkeletonBox(height: 16, width: 160),
            const SizedBox(height: 6),
            const SkeletonBox(height: 12, width: 100),
            const SizedBox(height: 6),
            Row(
              children: const [
                SkeletonBox(height: 12, width: 60),
                SizedBox(width: 8),
                SkeletonBox(height: 12, width: 40),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListSkeleton() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 5,
      itemBuilder: (context, index) {
        return _buildSingleSkeleton();
      },
    );
  }
}
