import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../models/ai_recommendation.dart';
import '../models/geoapify_place.dart';
import '../models/user_preferences.dart';

class AiRecommendationService {
  static const String _baseUrl =
      'https://openrouter.ai/api/v1/chat/completions';
  static const Duration _timeout = Duration(seconds: 15);
  static const int _maxPlacesInPrompt = 15;

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Mengembalikan daftar [AiRecommendation] yang diurutkan dari paling
  /// direkomendasikan.
  ///
  /// **Fallback**: jika AI gagal meng-match ≥ 3 tempat, atau terjadi error
  /// apapun, dikembalikan 5 tempat terdekat dari [nearbyPlaces] dengan
  /// `reason: "Tempat terdekat dari lokasi Anda"` dan `score: 0.5`.
  Future<List<AiRecommendation>> getRecommendations({
    required List<GeoapifyPlace> nearbyPlaces,
    required UserPreferences preferences,
    required LatLng userLocation,
  }) async {
    // --- Guard: API key wajib ada ---
    final apiKey = dotenv.env['OPENROUTER_API_KEY'] ?? '';
    if (apiKey.isEmpty) {
      debugPrint(
        '[AI_RECOMMENDATION] WARNING: OPENROUTER_API_KEY tidak ditemukan di .env. '
        'Melewati pemanggilan AI.',
      );
      return _fallbackRecommendations(nearbyPlaces);
    }

    final model = dotenv.env['AI_MODEL'] ?? 'z-ai/glm-4.5-air:free';

    // Batasi jumlah tempat yang dikirim ke prompt agar hemat token
    final placesForPrompt = nearbyPlaces.length > _maxPlacesInPrompt
        ? nearbyPlaces.sublist(0, _maxPlacesInPrompt)
        : nearbyPlaces;

    try {
      final prompt = _buildPrompt(preferences, placesForPrompt);
      final rawResponse = await _callOpenRouter(
        apiKey: apiKey,
        model: model,
        messages: prompt,
      );

      return _parseResponse(rawResponse, nearbyPlaces);
    } catch (e, st) {
      debugPrint('[AI_RECOMMENDATION] Error saat mendapatkan rekomendasi: $e');
      debugPrint('[AI_RECOMMENDATION] StackTrace: $st');
      return _fallbackRecommendations(nearbyPlaces);
    }
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  /// Membangun pesan system + user untuk dikirim ke LLM.
  List<Map<String, String>> _buildPrompt(
    UserPreferences preferences,
    List<GeoapifyPlace> places,
  ) {
    final suka = preferences.favoriteFoods.isNotEmpty
        ? preferences.favoriteFoods.join(', ')
        : 'tidak ada preferensi';
    final hindari = preferences.avoidFoods.isNotEmpty
        ? preferences.avoidFoods.join(', ')
        : 'tidak ada';

    final placeLines = places.map((p) {
      final distKm = p.distance != null
          ? '${(p.distance! / 1000.0).toStringAsFixed(1)} km'
          : 'jarak tidak diketahui';
      return '${p.name} | $distKm | ${p.categoryName}';
    }).join('\n');

    const systemMessage =
        'Kamu adalah asisten rekomendasi kuliner. '
        'Selalu jawab HANYA dengan JSON array tanpa teks tambahan apapun.';

    final userMessage = '''Berikan rekomendasi tempat makan dari data berikut.

Preferensi pengguna:
- Suka: $suka
- Hindari: $hindari
- Budget harian: Rp ${preferences.dailyBudget}

Daftar tempat (nama | jarak | kategori):
$placeLines

Jawab HANYA dengan JSON array ini, tanpa teks lain:
[{"place_name": "nama tempat", "rank": 1, "reason": "alasan singkat max 15 kata", "score": 0.95}]

Urutkan dari paling direkomendasikan. Sertakan semua tempat.''';

    return [
      {'role': 'system', 'content': systemMessage},
      {'role': 'user', 'content': userMessage},
    ];
  }

  /// Memanggil OpenRouter API dan mengembalikan isi teks dari assistant message.
  Future<String> _callOpenRouter({
    required String apiKey,
    required String model,
    required List<Map<String, String>> messages,
  }) async {
    final body = jsonEncode({
      'model': model,
      'messages': messages,
    });

    debugPrint('[AI_RECOMMENDATION] Memanggil OpenRouter dengan model: $model');

    final response = await http
        .post(
          Uri.parse(_baseUrl),
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
          body: body,
        )
        .timeout(_timeout);

    debugPrint('[AI_RECOMMENDATION] Response status: ${response.statusCode}');

    if (response.statusCode != 200) {
      debugPrint('[AI_RECOMMENDATION] Response body: ${response.body}');
      throw Exception(
        'OpenRouter API gagal dengan status ${response.statusCode}: ${response.body}',
      );
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final choices = decoded['choices'] as List?;
    if (choices == null || choices.isEmpty) {
      throw Exception('OpenRouter API mengembalikan choices kosong.');
    }

    final content =
        (choices[0] as Map<String, dynamic>)['message']?['content']
            as String? ??
        '';
    debugPrint('[AI_RECOMMENDATION] Raw AI content: $content');
    return content;
  }

  /// Mengekstrak substring JSON array `[...]` dari teks mentah.
  /// Dibutuhkan karena GLM-4.5 sering menyisipkan teks di luar JSON.
  String _extractJson(String raw) {
    final start = raw.indexOf('[');
    final end = raw.lastIndexOf(']');
    if (start == -1 || end == -1 || end < start) return '[]';
    return raw.substring(start, end + 1);
  }

  /// Mem-parse response AI dan memetakan ke list [AiRecommendation].
  List<AiRecommendation> _parseResponse(
    String rawContent,
    List<GeoapifyPlace> allPlaces,
  ) {
    final jsonString = _extractJson(rawContent);
    final List<dynamic> parsed;

    try {
      parsed = jsonDecode(jsonString) as List<dynamic>;
    } catch (e) {
      debugPrint(
        '[AI_RECOMMENDATION] Gagal men-decode JSON dari response AI: $e\n'
        'JSON string yang dicoba: $jsonString',
      );
      return [];
    }

    final List<AiRecommendation> results = [];

    for (final item in parsed) {
      if (item is! Map<String, dynamic>) continue;

      final placeName = (item['place_name'] as String? ?? '').toLowerCase();
      final rank = (item['rank'] as num?)?.toInt() ?? 999;
      final reason = item['reason'] as String? ?? '';
      final score = (item['score'] as num?)?.toDouble() ?? 0.0;

      // Match ke GeoapifyPlace dengan contains() case-insensitive
      final matchedPlace = _matchPlace(placeName, allPlaces);
      if (matchedPlace == null) {
        debugPrint(
          '[AI_RECOMMENDATION] Tidak dapat menemukan place untuk: "$placeName"',
        );
        continue;
      }

      results.add(AiRecommendation(
        place: matchedPlace,
        rank: rank,
        reason: reason,
        score: score.clamp(0.0, 1.0),
      ));
    }

    // Urutkan berdasarkan rank ascending (rank 1 = paling direkomendasikan)
    results.sort((a, b) => a.rank.compareTo(b.rank));

    debugPrint(
      '[AI_RECOMMENDATION] Berhasil mem-parse ${results.length} rekomendasi.',
    );

    // Jika AI gagal meng-match setidaknya 3 tempat, gunakan fallback proximity
    if (results.length < 3) {
      debugPrint(
        '[AI_RECOMMENDATION] Hasil matching < 3 tempat '
        '(${results.length} ditemukan). Menggunakan fallback terdekat.',
      );
      return _fallbackRecommendations(allPlaces);
    }

    return results;
  }

  /// Mencocokkan [placeName] dari AI ke [GeoapifyPlace] menggunakan
  /// `contains()` case-insensitive — bukan exact match.
  GeoapifyPlace? _matchPlace(
    String placeName,
    List<GeoapifyPlace> places,
  ) {
    if (placeName.isEmpty) return null;

    // Coba: apakah nama place dari DB mengandung nama dari AI
    GeoapifyPlace? match = places.cast<GeoapifyPlace?>().firstWhere(
          (p) => p!.name.toLowerCase().contains(placeName),
          orElse: () => null,
        );

    // Fallback: apakah nama dari AI mengandung nama place dari DB
    match ??= places.cast<GeoapifyPlace?>().firstWhere(
          (p) => placeName.contains(p!.name.toLowerCase()),
          orElse: () => null,
        );

    return match;
  }

  /// Fallback: kembalikan 5 tempat terdekat dari [places] tanpa AI ranking.
  /// Digunakan saat AI gagal meng-match ≥ 3 tempat, API error, atau key kosong.
  List<AiRecommendation> _fallbackRecommendations(List<GeoapifyPlace> places) {
    const maxFallback = 5;
    const fallbackReason = 'Tempat terdekat dari lokasi Anda';
    const fallbackScore = 0.5;

    final source = places.length > maxFallback
        ? places.sublist(0, maxFallback)
        : places;

    debugPrint(
      '[AI_RECOMMENDATION] Menggunakan fallback proximity '
      '(${source.length} tempat).',
    );

    return source.indexed
        .map(
          (entry) => AiRecommendation(
            place: entry.$2,
            rank: entry.$1 + 1,
            reason: fallbackReason,
            score: fallbackScore,
          ),
        )
        .toList();
  }
}
