class FoodItem {
  final int id;
  final String name;
  final String merchant;
  final int price;
  final double rating;
  final int reviews;
  final double distance;
  final String imageUrl;
  final List<String> tags;
  final bool isFavorite;

  const FoodItem({
    required this.id,
    required this.name,
    required this.merchant,
    required this.price,
    required this.rating,
    required this.reviews,
    required this.distance,
    required this.imageUrl,
    required this.tags,
    this.isFavorite = false,
  });
}
