import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../models/geoapify_place.dart';
import 'package:latlong2/latlong.dart';

class RouteData {
  final List<LatLng> points;
  final int distanceMeters;
  final int timeSeconds;
  
  RouteData({required this.points, required this.distanceMeters, required this.timeSeconds});
}

class GeoapifyService {
  final String _baseUrl = 'https://api.geoapify.com/v2/places';

  String get _apiKey {
    const key = String.fromEnvironment('GEOAPIFY_API_KEY');
    if (key.isNotEmpty) return key;

    final fallbackKey = dotenv.env['GEOAPIFY_API_KEY'];
    if (fallbackKey == null || fallbackKey.isEmpty) {
      throw Exception('GEOAPIFY_API_KEY tidak ditemukan (baik dari --dart-define maupun .env)');
    }
    return fallbackKey;
  }

  Future<List<GeoapifyPlace>> searchPlaces({
    required double lat,
    required double lng,
    required double radiusKm,
    String? categoryQuery,
    String? searchQuery,
    int limit = 15,
  }) async {
    final radiusMeters = (radiusKm * 1000).toInt();
    
    // Default categories for 'Semua Kategori'
    String categories = 'catering.restaurant,catering.cafe,catering.fast_food,commercial.food_and_drink';
    
    if (categoryQuery != null && categoryQuery != 'Semua Kategori') {
      final q = categoryQuery.toLowerCase();
      if (q.contains('minuman')) {
        categories = 'catering.cafe';
      } else if (q.contains('oleh-oleh')) {
        categories = 'commercial.food_and_drink,commercial.supermarket';
      } else if (q.contains('jajanan')) {
        categories = 'catering.fast_food,catering.food_court';
      } else if (q.contains('sate')) {
        categories = 'catering.restaurant.barbecue,catering.fast_food';
      } else if (q.contains('nasi campur')) {
        categories = 'catering.restaurant.asian,catering.restaurant';
      } else {
        categories = 'catering.restaurant';
      }
    }
    
    final uri = Uri.parse(_baseUrl).replace(queryParameters: {
      'categories': categories,
      'filter': 'circle:$lng,$lat,$radiusMeters',
      'bias': 'proximity:$lng,$lat',
      'limit': '100', // Fetch more for local filtering
      'apiKey': _apiKey,
    });

    debugPrint('=== [GeoapifyService] Fetching Places ===');
    debugPrint('URL: $uri');

    final response = await http.get(uri);

    debugPrint('Response Status: ${response.statusCode}');

    if (response.statusCode == 200) {
      debugPrint('Response Body: ${response.body}');
      final data = json.decode(response.body);
      final List features = data['features'] ?? [];
      debugPrint('Berhasil memuat ${features.length} tempat mentah dari API.');
      
      List<GeoapifyPlace> places = features.map((json) => GeoapifyPlace.fromJson(json)).toList();
      
      // Menyembunyikan "Warung Pak Wongso" dari hasil pencarian
      places = places.where((p) => !p.name.toLowerCase().contains('wongso')).toList();
      
      // Local name filtering to ensure specific Indonesian foods actually show relevant results
      if (categoryQuery != null && categoryQuery != 'Semua Kategori') {
        final q = categoryQuery.toLowerCase();
        List<GeoapifyPlace> filtered = [];
        
        if (q.contains('nasi campur')) {
          filtered = places.where((p) => p.name.toLowerCase().contains('nasi') || p.name.toLowerCase().contains('warung')).toList();
        } else if (q.contains('sate') || q.contains('panggang')) {
          filtered = places.where((p) => p.name.toLowerCase().contains('sate') || p.name.toLowerCase().contains('panggang') || p.name.toLowerCase().contains('babi')).toList();
        } else if (q.contains('jajanan')) {
          filtered = places.where((p) => p.name.toLowerCase().contains('kue') || p.name.toLowerCase().contains('jajan') || p.name.toLowerCase().contains('pasar')).toList();
        }
        
        // If we found specific matches, use them. Otherwise fallback to the API's categorical results
        if (filtered.isNotEmpty) {
          places = filtered;
          debugPrint('Setelah filter lokal, tersisa ${places.length} tempat.');
        }
      }

      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final sQuery = searchQuery.trim().toLowerCase();
        places = places.where((p) => p.name.toLowerCase().contains(sQuery)).toList();
        debugPrint('Setelah filter pencarian ("$sQuery"), tersisa ${places.length} tempat.');
      }
      
      // Enforce the requested limit
      if (places.length > limit) {
        places = places.sublist(0, limit);
      }
      
      return places;
    } else {
      debugPrint('ERROR Response: ${response.body}');
      throw Exception('Gagal memuat data dari Geoapify: ${response.statusCode}');
    }
  }

  Future<GeoapifyPlace> getPlaceDetails(String placeId) async {
    final uri = Uri.parse('https://api.geoapify.com/v2/place-details').replace(queryParameters: {
      'id': placeId,
      'apiKey': _apiKey,
    });

    debugPrint('=== [GeoapifyService] Fetching Details ===');
    debugPrint('Place ID: $placeId');

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      debugPrint('Detail Response Body: ${response.body}');
      final data = json.decode(response.body);
      final List features = data['features'] ?? [];
      if (features.isNotEmpty) {
         debugPrint('Berhasil memuat detail tempat.');
         return GeoapifyPlace.fromJson(features[0]);
      } else {
         debugPrint('WARNING: Detail tempat kosong.');
         throw Exception('Detail tempat tidak ditemukan.');
      }
    } else {
      debugPrint('ERROR Detail Response: ${response.body}');
      throw Exception('Gagal memuat detail tempat: ${response.statusCode}');
    }
  }

  Future<RouteData> getRoute({
    required List<LatLng> waypoints,
    String mode = 'drive',
  }) async {
    final waypointsString = waypoints.map((p) => '${p.latitude},${p.longitude}').join('|');
    
    final uri = Uri.parse('https://api.geoapify.com/v1/routing').replace(queryParameters: {
      'waypoints': waypointsString,
      'mode': mode,
      'apiKey': _apiKey,
    });

    debugPrint('=== [GeoapifyService] Fetching Route ($mode) ===');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final features = data['features'] as List?;
      if (features != null && features.isNotEmpty) {
        final feature = features[0];
        final geometry = feature['geometry'];
        final properties = feature['properties'] ?? {};
        
        int distance = properties['distance']?.toInt() ?? 0;
        int time = properties['time']?.toInt() ?? 0;

        if (geometry != null && geometry['type'] == 'MultiLineString') {
          final coordinates = geometry['coordinates'] as List;
          if (coordinates.isNotEmpty) {
            final List<LatLng> allPoints = [];
            
            // Loop over all segments/legs in the MultiLineString
            for (var lineString in coordinates) {
              final points = lineString as List;
              allPoints.addAll(points.map((point) {
                final p = point as List;
                return LatLng((p[1] as num).toDouble(), (p[0] as num).toDouble());
              }));
            }
            return RouteData(points: allPoints, distanceMeters: distance, timeSeconds: time);
          }
        }
      }
      throw Exception('Format rute tidak dikenali');
    } else {
      debugPrint('ERROR Route Response: ${response.body}');
      throw Exception('Gagal memuat rute: ${response.statusCode}');
    }
  }
}
