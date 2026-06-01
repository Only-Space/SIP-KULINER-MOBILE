class UserPreferences {
  final List<String> favoriteFoods;
  final List<String> avoidFoods;
  final double maxRadiusKm;
  final int dailyBudget;

  const UserPreferences({
    this.favoriteFoods = const [],
    this.avoidFoods = const [],
    this.maxRadiusKm = 5.0,
    this.dailyBudget = 50000,
  });

  UserPreferences copyWith({
    List<String>? favoriteFoods,
    List<String>? avoidFoods,
    double? maxRadiusKm,
    int? dailyBudget,
  }) {
    return UserPreferences(
      favoriteFoods: favoriteFoods ?? this.favoriteFoods,
      avoidFoods: avoidFoods ?? this.avoidFoods,
      maxRadiusKm: maxRadiusKm ?? this.maxRadiusKm,
      dailyBudget: dailyBudget ?? this.dailyBudget,
    );
  }

  Map<String, dynamic> toJson() => {
        'favoriteFoods': favoriteFoods,
        'avoidFoods': avoidFoods,
        'maxRadiusKm': maxRadiusKm,
        'dailyBudget': dailyBudget,
      };

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      favoriteFoods: List<String>.from(json['favoriteFoods'] ?? []),
      avoidFoods: List<String>.from(json['avoidFoods'] ?? []),
      maxRadiusKm: (json['maxRadiusKm'] as num?)?.toDouble() ?? 5.0,
      dailyBudget: (json['dailyBudget'] as num?)?.toInt() ?? 50000,
    );
  }
}
