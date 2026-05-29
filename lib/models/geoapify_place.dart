
import 'food_item.dart';
import 'dart:math';

class GeoapifyPlace {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String categoryName;
  final int? distance;
  final String? phone;
  final String? openingHours;
  final String? website;

  GeoapifyPlace({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.categoryName,
    this.distance,
    this.phone,
    this.openingHours,
    this.website,
  });

  factory GeoapifyPlace.fromJson(Map<String, dynamic> json) {
    final properties = json['properties'] ?? {};
    final geometry = json['geometry'] ?? {};
    
    double lat = (properties['lat'] as num?)?.toDouble() ?? 0.0;
    double lng = (properties['lon'] as num?)?.toDouble() ?? 0.0;
    
    // Fallback jika properties tidak memiliki lat/lon (gunakan geometry)
    if (lat == 0.0 && lng == 0.0 && geometry['coordinates'] != null) {
      final type = geometry['type'];
      final coords = geometry['coordinates'] as List;
      
      if (type == 'Point' && coords.length >= 2) {
        lng = (coords[0] as num).toDouble();
        lat = (coords[1] as num).toDouble();
      } else if (type == 'Polygon' && coords.isNotEmpty) {
        final ring = coords[0] as List;
        if (ring.isNotEmpty) {
          lng = (ring[0][0] as num).toDouble();
          lat = (ring[0][1] as num).toDouble();
        }
      }
    }

    String category = 'Restoran';
    if (properties['categories'] != null && (properties['categories'] as List).isNotEmpty) {
      final cats = List<String>.from(properties['categories']);
      if (cats.contains('catering.cafe')) category = 'Kafe';
      else if (cats.contains('catering.fast_food')) category = 'Cepat Saji';
      else if (cats.contains('catering.restaurant')) category = 'Restoran';
    }

    // Gunakan string base fallback alih-alih hashCode karena hashCode Dart berubah setiap kali aplikasi direstart!
    final fallbackId = '${properties['name']}_${lat}_${lng}'.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');

    return GeoapifyPlace(
      id: properties['place_id']?.toString() ?? fallbackId,
      name: properties['name']?.toString() ?? 'Tanpa Nama',
      address: properties['formatted']?.toString() ?? 'Lokasi tidak diketahui',
      latitude: lat,
      longitude: lng,
      categoryName: category,
      distance: (properties['distance'] as num?)?.toInt(),
      phone: properties['contact']?['phone']?.toString(),
      website: properties['website']?.toString(),
      openingHours: properties['opening_hours']?.toString(),
    );
  }

  FoodItem toFoodItem() {
    // Gunakan fungsi hash deterministik buatan sendiri agar konsisten walau aplikasi direstart
    final int stableHash = _generateStableHash(id);

    // Generate dummy rating & photos because Geoapify doesn't have it natively
    final random = Random(stableHash); // Predictable random based on ID
    final dummyRating = 3.5 + (random.nextDouble() * 1.5); // 3.5 - 5.0
    final dummyReviews = 10 + random.nextInt(200);
    
    // Daftar URL gambar makanan berkualitas tinggi dari Unsplash.
    // Karena bug ID yang berubah-ubah (yang menyebabkan spam request) sudah diperbaiki,
    // gambar Unsplash ini sekarang dijamin stabil, masuk cache, dan tidak akan kena limit lagi.
    const dummyImages = [
      'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?q=80&w=600&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1504674900247-0877df9cc836?q=80&w=600&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?q=80&w=600&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1499028344343-cd173ffc68a9?q=80&w=600&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1476224203421-9ac39bcb3327?q=80&w=600&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?q=80&w=600&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1482049016688-2d3e1b311543?q=80&w=600&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1414235077428-33898869228e?q=80&w=600&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1504754524776-8f4f37790ca0?q=80&w=600&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1565958011703-44f9829ba187?q=80&w=600&auto=format&fit=crop',
    ];

    final int imageIndex = stableHash.abs() % dummyImages.length;
    final imgUrl = dummyImages[imageIndex];

    return FoodItem(
      id: id,
      name: name,
      merchant: address, 
      price: 20000 + (random.nextInt(4) * 10000), 
      rating: double.parse(dummyRating.toStringAsFixed(1)), 
      reviews: dummyReviews,
      distance: double.parse(((distance ?? 0) / 1000.0).toStringAsFixed(1)),
      imageUrl: imgUrl,
      tags: [categoryName],
    );
  }

  // Fungsi hash deterministik buatan sendiri untuk menggantikan String.hashCode 
  // karena String.hashCode di Dart berubah-ubah setiap kali aplikasi direstart.
  int _generateStableHash(String str) {
    int hash = 5381;
    for (int i = 0; i < str.length; i++) {
      hash = ((hash << 5) + hash) + str.codeUnitAt(i);
    }
    return hash;
  }
}
