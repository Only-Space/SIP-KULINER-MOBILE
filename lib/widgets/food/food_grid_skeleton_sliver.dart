import 'package:flutter/material.dart';
import 'food_card_skeleton.dart';

class FoodGridSkeletonSliver extends StatelessWidget {
  final int itemCount;

  const FoodGridSkeletonSliver({super.key, this.itemCount = 6});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (context, index) => const FoodCardSkeleton(),
          childCount: itemCount,
        ),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: MediaQuery.of(context).size.width > 900
              ? 4
              : MediaQuery.of(context).size.width > 600
                  ? 3
                  : 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio:
              MediaQuery.of(context).size.width > 600 ? 0.75 : 0.65,
        ),
      ),
    );
  }
}
