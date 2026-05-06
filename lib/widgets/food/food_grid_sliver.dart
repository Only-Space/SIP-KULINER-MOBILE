import 'package:flutter/material.dart';
import '../../models/food_item.dart';
import '../../data/dummy_data.dart';
import 'food_card.dart';

class FoodGridSliver extends StatelessWidget {
  final List<FoodItem> items;

  const FoodGridSliver({super.key, this.items = DummyData.foodItems});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (context, index) => FoodCard(item: items[index]),
          childCount: items.length,
        ),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: MediaQuery.of(context).size.width > 900
              ? 4
              : MediaQuery.of(context).size.width > 600
                  ? 2
                  : 1,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio:
              MediaQuery.of(context).size.width > 600 ? 0.75 : 0.85,
        ),
      ),
    );
  }
}
