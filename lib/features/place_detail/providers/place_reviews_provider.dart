import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/review_model.dart';
import '../../../../data/services/review_service.dart';
import '../../../../core/errors/app_exception.dart';

final placeReviewsProvider = FutureProvider.autoDispose.family<List<ReviewModel>, String>((ref, placeId) async {
  final reviewService = ReviewService();
  try {
    return await reviewService.getReviews(placeId);
  } catch (e) {
    throw parseException(e);
  }
});
