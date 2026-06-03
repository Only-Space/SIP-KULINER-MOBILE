class MealItem {
  final String foodName;
  final String warungName;
  final String warungArea;
  final int price;
  final String tips;
  final String? placeId;

  MealItem({
    required this.foodName,
    required this.warungName,
    required this.warungArea,
    required this.price,
    required this.tips,
    this.placeId,
  });

  factory MealItem.fromJson(Map<String, dynamic> json) {
    return MealItem(
      foodName: json['food_name'] as String? ?? 'Makanan',
      warungName: json['warung_name'] as String? ?? 'Warung',
      warungArea: json['warung_area'] as String? ?? 'Area',
      price: (json['price'] as num?)?.toInt() ?? 0,
      tips: json['tips'] as String? ?? '',
      placeId: json['place_id'] as String?,
    );
  }

  /// Buat salinan MealItem dengan field tertentu diganti.
  MealItem copyWith({int? price}) => MealItem(
    foodName: foodName,
    warungName: warungName,
    warungArea: warungArea,
    price: price ?? this.price,
    tips: tips,
    placeId: placeId,
  );

  Map<String, dynamic> toJson() => {
    'food_name': foodName,
    'warung_name': warungName,
    'warung_area': warungArea,
    'price': price,
    'tips': tips,
    if (placeId != null) 'place_id': placeId,
  };
}

class DailyMeal {
  final int day;
  final MealItem breakfast;
  final MealItem lunch;
  final MealItem dinner;

  DailyMeal({
    required this.day,
    required this.breakfast,
    required this.lunch,
    required this.dinner,
  });

  int get totalDailyCost => breakfast.price + lunch.price + dinner.price;

  factory DailyMeal.fromJson(Map<String, dynamic> json) {
    return DailyMeal(
      day: json['day'] as int? ?? 1,
      breakfast: MealItem.fromJson(json['breakfast'] as Map<String, dynamic>? ?? {}),
      lunch: MealItem.fromJson(json['lunch'] as Map<String, dynamic>? ?? {}),
      dinner: MealItem.fromJson(json['dinner'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
    'day': day,
    'breakfast': breakfast.toJson(),
    'lunch': lunch.toJson(),
    'dinner': dinner.toJson(),
  };
}

class MealPlan {
  final List<DailyMeal> days;
  final int totalBudget;
  final int totalEstimatedCost;
  final DateTime generatedAt;

  MealPlan({
    required this.days,
    required this.totalBudget,
    required this.totalEstimatedCost,
    required this.generatedAt,
  });

  int get estimatedSavings => totalBudget - totalEstimatedCost;

  factory MealPlan.fromJson(Map<String, dynamic> json) {
    return MealPlan(
      days: ((json['days'] as List?) ?? [])
          .map((e) => DailyMeal.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalBudget: (json['total_budget'] as num?)?.toInt() ?? 0,
      totalEstimatedCost: (json['total_estimated_cost'] as num?)?.toInt() ?? 0,
      generatedAt: json['generated_at'] != null 
          ? DateTime.parse(json['generated_at'] as String) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'days': days.map((e) => e.toJson()).toList(),
    'total_budget': totalBudget,
    'total_estimated_cost': totalEstimatedCost,
    'generated_at': generatedAt.toIso8601String(),
  };
}
