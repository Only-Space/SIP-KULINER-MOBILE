import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../data/providers/supabase_provider.dart';
import '../../../../data/services/geoapify_service.dart';
import '../../../../models/ai_recommendation.dart';
import '../../../../models/geoapify_place.dart';
import '../../../../models/user_preferences.dart';
import '../../../../services/ai_recommendation_service.dart';
import 'preferences_provider.dart';

// ---------------------------------------------------------------------------
// Cache TTL
// ---------------------------------------------------------------------------

/// Cache dianggap valid selama 30 menit.
const _cacheTtl = Duration(minutes: 30);

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final aiRecommendationProvider = AsyncNotifierProvider<
    AiRecommendationNotifier,
    List<AiRecommendation>>(AiRecommendationNotifier.new);

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

class AiRecommendationNotifier
    extends AsyncNotifier<List<AiRecommendation>> {
  final GeoapifyService _geoapify = GeoapifyService();
  final AiRecommendationService _aiService = AiRecommendationService();

  @override
  Future<List<AiRecommendation>> build() async {
    final supabase = ref.read(supabaseProvider);
    final userId = supabase.auth.currentUser?.id;

    if (userId == null) {
      debugPrint('[AI_RECOMMENDATION_PROVIDER] User belum login, return []');
      return [];
    }

    // --- Cek cache ---
    try {
      final cached = await supabase
          .from('ai_recommendation_cache')
          .select('recommendations_json, created_at')
          .eq('user_id', userId)
          .maybeSingle();

      if (cached != null) {
        final createdAt =
            DateTime.tryParse(cached['created_at'] as String? ?? '');
        final isValid = createdAt != null &&
            DateTime.now().difference(createdAt) < _cacheTtl;

        if (isValid) {
          debugPrint('[AI_RECOMMENDATION_PROVIDER] Cache hit, usia: '
              '${DateTime.now().difference(createdAt).inMinutes} menit.');
          return _decodeCache(
            cached['recommendations_json'],
            userId: userId,
          );
        } else {
          debugPrint('[AI_RECOMMENDATION_PROVIDER] Cache expired, fetch ulang.');
        }
      } else {
        debugPrint('[AI_RECOMMENDATION_PROVIDER] Cache kosong, fetch pertama kali.');
      }
    } catch (e) {
      debugPrint('[AI_RECOMMENDATION_PROVIDER] Gagal membaca cache: $e');
    }

    return _fetchFresh(userId: userId);
  }

  // ---------------------------------------------------------------------------
  // Public methods
  // ---------------------------------------------------------------------------

  /// Paksa refresh: hapus cache lama, lalu ambil data baru dari AI.
  Future<void> refresh() async {
    final supabase = ref.read(supabaseProvider);
    final userId = supabase.auth.currentUser?.id;

    if (userId == null) return;

    state = const AsyncLoading();

    try {
      await supabase
          .from('ai_recommendation_cache')
          .delete()
          .eq('user_id', userId);
      debugPrint('[AI_RECOMMENDATION_PROVIDER] Cache dihapus untuk refresh.');
    } catch (e) {
      debugPrint('[AI_RECOMMENDATION_PROVIDER] Gagal hapus cache: $e');
    }

    state = await AsyncValue.guard(() => _fetchFresh(userId: userId));
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  /// Ambil data segar: preferensi → lokasi → places → AI → upsert cache.
  Future<List<AiRecommendation>> _fetchFresh({required String userId}) async {
    final supabase = ref.read(supabaseProvider);

    // 1. Preferensi user
    UserPreferences preferences;
    try {
      preferences = await ref.read(preferencesProvider.future);
    } catch (_) {
      preferences = const UserPreferences();
    }

    // 2. Lokasi user
    Position position;
    try {
      // Pastikan permission sudah diberikan (tanpa BuildContext, request langsung)
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
      }
      position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      debugPrint('[AI_RECOMMENDATION_PROVIDER] Gagal dapat lokasi: $e');
      throw LocationException('Tidak dapat mengakses lokasi. $e');
    }

    final userLatLng = LatLng(position.latitude, position.longitude);

    // 3. Ambil tempat terdekat dari Geoapify
    List<GeoapifyPlace> nearbyPlaces;
    try {
      nearbyPlaces = await _geoapify.searchPlaces(
        lat: userLatLng.latitude,
        lng: userLatLng.longitude,
        radiusKm: preferences.maxRadiusKm,
        limit: 15,
      );
    } catch (e) {
      debugPrint('[AI_RECOMMENDATION_PROVIDER] Gagal fetch places: $e');
      nearbyPlaces = [];
    }

    if (nearbyPlaces.isEmpty) {
      debugPrint('[AI_RECOMMENDATION_PROVIDER] Tidak ada tempat ditemukan, return []');
      return [];
    }

    // 4. Panggil AI
    final recommendations = await _aiService.getRecommendations(
      nearbyPlaces: nearbyPlaces,
      preferences: preferences,
      userLocation: userLatLng,
    );

    // 5. Simpan ke cache (upsert)
    try {
      final cacheJson = _encodeCache(recommendations);
      await supabase.from('ai_recommendation_cache').upsert({
        'user_id': userId,
        'recommendations_json': cacheJson,
        'created_at': DateTime.now().toUtc().toIso8601String(),
      });
      debugPrint(
        '[AI_RECOMMENDATION_PROVIDER] Cache di-upsert '
        '(${recommendations.length} item).',
      );
    } catch (e) {
      // Cache gagal tidak boleh throw — data tetap dikembalikan
      debugPrint('[AI_RECOMMENDATION_PROVIDER] Gagal upsert cache: $e');
    }

    return recommendations;
  }

  /// Encode [AiRecommendation] list ke format JSON yang bisa disimpan di Supabase.
  List<Map<String, dynamic>> _encodeCache(
      List<AiRecommendation> recommendations) {
    return recommendations.map((r) {
      final p = r.place;
      return {
        'rank': r.rank,
        'reason': r.reason,
        'score': r.score,
        'place': {
          'id': p.id,
          'name': p.name,
          'address': p.address,
          'latitude': p.latitude,
          'longitude': p.longitude,
          'categoryName': p.categoryName,
          'distance': p.distance,
          'phone': p.phone,
          'openingHours': p.openingHours,
          'website': p.website,
        },
      };
    }).toList();
  }

  /// Decode JSON dari cache Supabase kembali ke [AiRecommendation] list.
  List<AiRecommendation> _decodeCache(
    dynamic rawJson, {
    required String userId,
  }) {
    try {
      final List<dynamic> list = rawJson is String
          ? jsonDecode(rawJson) as List<dynamic>
          : rawJson as List<dynamic>;

      return list.map((item) {
        final m = item as Map<String, dynamic>;
        final pm = m['place'] as Map<String, dynamic>;

        final place = GeoapifyPlace(
          id: pm['id'] as String? ?? '',
          name: pm['name'] as String? ?? '',
          address: pm['address'] as String? ?? '',
          latitude: (pm['latitude'] as num?)?.toDouble() ?? 0.0,
          longitude: (pm['longitude'] as num?)?.toDouble() ?? 0.0,
          categoryName: pm['categoryName'] as String? ?? '',
          distance: (pm['distance'] as num?)?.toInt(),
          phone: pm['phone'] as String?,
          openingHours: pm['openingHours'] as String?,
          website: pm['website'] as String?,
        );

        return AiRecommendation(
          place: place,
          rank: (m['rank'] as num?)?.toInt() ?? 999,
          reason: m['reason'] as String? ?? '',
          score: (m['score'] as num?)?.toDouble() ?? 0.5,
        );
      }).toList();
    } catch (e) {
      debugPrint('[AI_RECOMMENDATION_PROVIDER] Gagal decode cache: $e');
      return [];
    }
  }
}
