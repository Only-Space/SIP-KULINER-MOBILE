import 'food_item.dart';

class FoursquarePlace {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String? imageUrl;
  final String categoryName;
  final double? rating;
  final int? distance;

  FoursquarePlace({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.imageUrl,
    required this.categoryName,
    this.rating,
    this.distance,
  });

  factory FoursquarePlace.fromJson(Map<String, dynamic> json) {
    String? photoUrl;
    if (json['photos'] != null && (json['photos'] as List).isNotEmpty) {
      final photo = json['photos'][0];
      // original size, format: prefix + size + suffix
      photoUrl = '${photo['prefix']}original${photo['suffix']}';
    }

    String category = 'Restoran';
    if (json['categories'] != null && (json['categories'] as List).isNotEmpty) {
      category = json['categories'][0]['name'] ?? 'Restoran';
    }

    String locationAddress = 'Lokasi tidak diketahui';
    if (json['location'] != null) {
      locationAddress = json['location']['formatted_address'] ?? 
                        json['location']['address'] ?? 
                        'Lokasi tidak diketahui';
    }

    double lat = 0.0;
    double lng = 0.0;
    if (json['geocodes'] != null && json['geocodes']['main'] != null) {
      lat = (json['geocodes']['main']['latitude'] ?? 0).toDouble();
      lng = (json['geocodes']['main']['longitude'] ?? 0).toDouble();
    }

    return FoursquarePlace(
      id: json['fsq_id'] ?? '',
      name: json['name'] ?? 'Tanpa Nama',
      address: locationAddress,
      latitude: lat,
      longitude: lng,
      imageUrl: photoUrl,
      categoryName: category,
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      distance: json['distance'],
    );
  }

  FoodItem toFoodItem() {
    return FoodItem(
      id: id,
      name: name,
      merchant: address, 
      price: 25000, // Harga standar sementara karena API tidak memberikan nilai pasti
      rating: rating ?? 4.0, // Default 4.0 jika tidak ada rating
      reviews: (rating != null) ? (rating! * 10).toInt() : 12, // Simulasi jumlah ulasan
      distance: (distance ?? 0).toDouble(),
      imageUrl: imageUrl ?? 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80', // Default image
      tags: [categoryName],
    );
  }
}
