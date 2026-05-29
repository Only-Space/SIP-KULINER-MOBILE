import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../models/foursquare_place.dart';

class FoursquareService {
  final String _baseUrl = 'https://api.foursquare.com/v3/places';

  String get _apiKey {
    final key = dotenv.env['FOURSQUARE_API_KEY'];
    if (key == null || key.isEmpty) {
      throw Exception('FOURSQUARE_API_KEY tidak ditemukan di .env');
    }
    return key;
  }

  Future<List<FoursquarePlace>> searchPlaces({
    required double lat,
    required double lng,
    required double radiusKm,
    String? query,
    int limit = 15,
  }) async {
    // Foursquare API membutuhkan radius dalam satuan meter
    final radius = (radiusKm * 1000).toInt();

    final queryParams = {
      'll': '$lat,$lng',
      'radius': radius.toString(),
      'limit': limit.toString(),
      // Mengambil field yang diperlukan sekaligus (mengurangi request tambahan)
      'fields': 'fsq_id,name,location,categories,geocodes,photos,rating,price,distance',
    };

    if (query != null && query.isNotEmpty) {
      queryParams['query'] = query;
    }

    final uri = Uri.parse('$_baseUrl/search').replace(queryParameters: queryParams);

    final response = await http.get(
      uri,
      headers: {
        'Authorization': _apiKey,
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List results = data['results'] ?? [];
      
      return results.map((json) => FoursquarePlace.fromJson(json)).toList();
    } else {
      throw Exception('Gagal memuat data dari Foursquare: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> getPlaceDetails(String fsqId) async {
    final uri = Uri.parse('$_baseUrl/$fsqId').replace(queryParameters: {
      'fields': 'fsq_id,name,location,categories,geocodes,photos,rating,price,description,tel,hours',
    });

    final response = await http.get(
      uri,
      headers: {
        'Authorization': _apiKey,
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Gagal memuat detail tempat: ${response.statusCode}');
    }
  }

  Future<List<String>> getPlacePhotos(String fsqId) async {
    final uri = Uri.parse('$_baseUrl/$fsqId/photos').replace(queryParameters: {
      'limit': '5',
    });

    final response = await http.get(
      uri,
      headers: {
        'Authorization': _apiKey,
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((photo) {
        return '${photo['prefix']}original${photo['suffix']}';
      }).toList();
    } else {
      throw Exception('Gagal memuat foto tempat: ${response.statusCode}');
    }
  }
}
