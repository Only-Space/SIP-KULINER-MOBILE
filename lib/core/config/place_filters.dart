class PlaceFilters {
  // TODO: pindahkan ke Supabase tabel blacklisted_places di iterasi berikutnya
  static const List<String> blacklistedNames = [
    'wongso',
  ];

  static const Map<String, String> categoryMappings = {
    'minuman': 'catering.cafe',
    'oleh-oleh': 'commercial.food_and_drink,commercial.supermarket',
    'jajanan': 'catering.fast_food,catering.food_court',
    'sate': 'catering.restaurant.barbecue,catering.fast_food',
    'nasi campur': 'catering.restaurant.asian,catering.restaurant',
  };

  static const String defaultCategoryMapping = 'catering.restaurant';
  static const String baseCategories = 'catering.restaurant,catering.cafe,catering.fast_food,commercial.food_and_drink';

  static const Map<String, List<String>> localKeywords = {
    'nasi campur': ['nasi', 'warung'],
    'sate': ['sate', 'panggang', 'babi'],
    'panggang': ['sate', 'panggang', 'babi'],
    'jajanan': ['kue', 'jajan', 'pasar'],
  };
}
