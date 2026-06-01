import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/review_model.dart';

class ReviewService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Mengambil semua ulasan untuk suatu tempat
  Future<List<ReviewModel>> getReviews(String placeId) async {
    debugPrint('[REVIEW] Fetching dengan place_id: $placeId');
    final response = await _supabase
        .from('reviews')
        .select('*, profiles(name, avatar_url), review_photos(storage_url)')
        .eq('place_id', placeId)
        .order('created_at', ascending: false);

    return response.map((json) => ReviewModel.fromJson(json)).toList();
  }

  /// Menambahkan ulasan baru beserta foto (opsional)
  Future<void> submitReview({
    required String placeId,
    required double rating,
    String? comment,
    File? photo,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Anda harus login untuk memberikan ulasan.');

    debugPrint('[REVIEW] Insert dengan place_id: $placeId');

    // 1. Simpan Ulasan ke tabel reviews
    final reviewResponse = await _supabase.from('reviews').insert({
      'user_id': userId,
      'place_id': placeId,
      'rating': rating,
      'comment': comment,
    }).select().single();

    final reviewId = reviewResponse['id'];

    // 2. Jika ada foto, upload ke bucket dan simpan ke tabel review_photos
    if (photo != null) {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_$userId.jpg';
      final storagePath = '$placeId/$fileName';

      // Upload ke bucket 'review_images'
      await _supabase.storage.from('review_images').upload(storagePath, photo);
      
      // Dapatkan public URL
      final photoUrl = _supabase.storage.from('review_images').getPublicUrl(storagePath);

      // Simpan URL ke tabel review_photos
      await _supabase.from('review_photos').insert({
        'review_id': reviewId,
        'storage_url': photoUrl,
      });
    }
  }
}
